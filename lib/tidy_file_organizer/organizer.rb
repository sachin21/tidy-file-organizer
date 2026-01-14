require 'fileutils'

module TidyFileOrganizer
  class Organizer
    attr_reader :target_dir

    def initialize(target_dir)
      @target_dir = File.expand_path(target_dir)
      @config_manager = Config.new(@target_dir)
    end

    def setup
      SetupPrompt.new(@config_manager).run(@target_dir)
    end

    def run(dry_run: true)
      config = @config_manager.load

      unless config
        puts "設定が見つかりません。先に 'setup' コマンドを実行してください。"
        return
      end

      puts "--- 整理を開始します (#{@target_dir}) #{dry_run ? '[Dry-run モード]' : ''} ---"

      files = collect_files

      if files.empty?
        puts "整理対象のファイルが見つかりませんでした。"
        return
      end

      organize_files(files, config, dry_run)

      puts "\n整理が完了しました。"
    end

    private

    def collect_files
      Dir.children(@target_dir)
         .map { |entry| File.join(@target_dir, entry) }
         .select { |path| File.file?(path) }
    end

    def organize_files(files, config, dry_run)
      files.each do |file_path|
        destination_dir = determine_destination(file_path, config)
        next unless destination_dir

        move_file(file_path, destination_dir, dry_run: dry_run)
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

    def move_file(file_path, dest_dir_name, dry_run:)
      filename = File.basename(file_path)
      dest_dir = File.join(@target_dir, dest_dir_name)
      dest_path = File.join(dest_dir, filename)

      if dry_run
        puts "[Dry-run] #{filename} -> #{dest_dir_name}/"
      else
        FileUtils.mkdir_p(dest_dir) unless Dir.exist?(dest_dir)
        FileUtils.mv(file_path, dest_path)
        puts "Moved: #{filename} -> #{dest_dir_name}/"
      end
    end
  end
end
