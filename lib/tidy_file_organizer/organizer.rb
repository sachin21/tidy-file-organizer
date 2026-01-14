require 'fileutils'

module TidyFileOrganizer
  class Organizer
    attr_reader :target_dir

    def initialize(target_dir)
      @target_dir = File.expand_path(target_dir)
      @config_manager = Config.new(@target_dir)
      @organized_dirs = []
    end

    def setup
      SetupPrompt.new(@config_manager).run(@target_dir)
    end

    def run(dry_run: true, recursive: false)
      config = @config_manager.load

      unless config
        puts "設定が見つかりません。先に 'setup' コマンドを実行してください。"
        return
      end

      mode_label = dry_run ? '[Dry-run モード]' : ''
      recursive_label = recursive ? '[再帰モード]' : ''
      puts "--- 整理を開始します (#{@target_dir}) #{mode_label} #{recursive_label} ---"

      # 整理先として使用されるディレクトリ名を収集
      @organized_dirs = (config[:extensions].keys + config[:keywords].keys).uniq

      files = collect_files(recursive: recursive)

      if files.empty?
        puts '整理対象のファイルが見つかりませんでした。'
        return
      end

      organize_files(files, config, dry_run)

      # 空ディレクトリのクリーンアップ
      cleanup_empty_directories if recursive && !dry_run

      puts "\n整理が完了しました。"
    end

    private

    def collect_files(recursive: false)
      if recursive
        collect_files_recursively(@target_dir)
      else
        Dir.children(@target_dir)
          .map { |entry| File.join(@target_dir, entry) }
          .select { |path| File.file?(path) }
      end
    end

    def collect_files_recursively(dir)
      files = []
      Dir.children(dir).each do |entry|
        # 整理先ディレクトリはスキップ
        next if @organized_dirs.include?(entry)

        path = File.join(dir, entry)
        if File.file?(path)
          files << path
        elsif File.directory?(path)
          files.concat(collect_files_recursively(path))
        end
      end
      files
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
      relative_path = file_path.sub("#{@target_dir}/", '')
      dest_dir = File.join(@target_dir, dest_dir_name)
      dest_path = File.join(dest_dir, filename)

      # ファイル名の重複チェック
      if File.exist?(dest_path) && file_path != dest_path
        conflict_msg = "⚠️  Conflict: #{relative_path} -> #{dest_dir_name}/ (ファイル名が重複しています)"
        puts dry_run ? "[Dry-run] #{conflict_msg}" : conflict_msg
        return
      end

      # 移動元と移動先が同じ場合はスキップ
      if file_path == dest_path
        puts "[Skip] #{relative_path} (既に正しい場所にあります)" if dry_run
        return
      end

      if dry_run
        puts "[Dry-run] #{relative_path} -> #{dest_dir_name}/"
      else
        FileUtils.mkdir_p(dest_dir)
        FileUtils.mv(file_path, dest_path)
        puts "Moved: #{relative_path} -> #{dest_dir_name}/"
      end
    end

    def cleanup_empty_directories
      Dir.glob(File.join(@target_dir, '**/*')).reverse_each do |path|
        next unless File.directory?(path)
        next if path == @target_dir
        next if @organized_dirs.include?(File.basename(path))

        next unless Dir.empty?(path)

        Dir.rmdir(path)
        relative_path = path.sub("#{@target_dir}/", '')
        puts "Cleaned up: #{relative_path}/ (空ディレクトリを削除)"
      end
    end
  end
end
