require 'fileutils'

module TidyFileOrganizer
  class Organizer
    include FileHelper

    attr_reader :target_dir

    def initialize(target_dir)
      @target_dir = File.expand_path(target_dir)
      @config_manager = Config.new(@target_dir)
      @file_mover = FileMover.new(@target_dir)
      @organized_dirs = []
    end

    def setup
      SetupPrompt.new(@config_manager).run(@target_dir)
    end

    def run(dry_run: true, recursive: false)
      config = @config_manager.load
      return handle_missing_config unless config

      print_header(dry_run, recursive)

      @organized_dirs = extract_organized_dirs(config)

      files = collect_files(@target_dir, recursive: recursive, exclude_dirs: @organized_dirs)
      return handle_empty_files if files.empty?

      organize_files(files, config, dry_run)
      cleanup_empty_directories if recursive && !dry_run

      print_completion_message
    end

    private

    def handle_missing_config
      puts "設定が見つかりません。先に 'setup' コマンドを実行してください。"
    end

    def print_header(dry_run, recursive)
      mode_label = dry_run ? '[Dry-run モード]' : ''
      recursive_label = recursive ? '[再帰モード]' : ''
      puts "--- 整理を開始します (#{@target_dir}) #{mode_label} #{recursive_label} ---"
    end

    def extract_organized_dirs(config)
      (config[:extensions].keys + config[:keywords].keys).uniq
    end

    def handle_empty_files
      puts '整理対象のファイルが見つかりませんでした。'
    end

    def print_completion_message
      puts "\n整理が完了しました。"
    end

    def organize_files(files, config, dry_run)
      files.each do |file_path|
        destination_dir = determine_destination(file_path, config)
        next unless destination_dir

        @file_mover.move_file(file_path, destination_dir, dry_run: dry_run)
      end
    end

    def determine_destination(file_path, config)
      filename = File.basename(file_path)
      extension = extract_extension(file_path)

      find_by_keyword(filename, config[:keywords]) ||
        find_by_extension(extension, config[:extensions])
    end

    def extract_extension(file_path)
      File.extname(file_path).delete('.').downcase
    end

    def find_by_keyword(filename, keywords_config)
      keywords_config.each do |dir, keywords|
        return dir if keywords.any? { |kw| filename.include?(kw) }
      end
      nil
    end

    def find_by_extension(extension, extensions_config)
      extensions_config.each do |dir, extensions|
        return dir if extensions.include?(extension)
      end
      nil
    end

    def cleanup_empty_directories
      Dir.glob(File.join(@target_dir, '**/*')).reverse_each do |path|
        next unless should_cleanup?(path)

        remove_empty_directory(path)
      end
    end

    def should_cleanup?(path)
      File.directory?(path) &&
        path != @target_dir &&
        !@organized_dirs.include?(File.basename(path)) &&
        Dir.empty?(path)
    end

    def remove_empty_directory(path)
      Dir.rmdir(path)
      relative = relative_path(path, @target_dir)
      puts "Cleaned up: #{relative}/ (空ディレクトリを削除)"
    end
  end
end
