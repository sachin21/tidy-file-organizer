require 'fileutils'
require 'time'

module TidyFileOrganizer
  class DateOrganizer
    attr_reader :target_dir

    def initialize(target_dir)
      @target_dir = File.expand_path(target_dir)
    end

    # ファイルを日付ベースで整理
    # pattern: 'year', 'year-month', 'year-month-day'のいずれか
    def organize_by_date(pattern: 'year-month', dry_run: true, recursive: false)
      mode_label = dry_run ? '[Dry-run モード]' : ''
      recursive_label = recursive ? '[再帰モード]' : ''
      puts "--- 日付ベースの整理を開始します (#{@target_dir}) #{mode_label} #{recursive_label} ---"
      puts "整理パターン: #{pattern}"

      files = collect_files(recursive: recursive)

      if files.empty?
        puts '整理対象のファイルが見つかりませんでした。'
        return
      end

      files.each do |file_path|
        dest_dir_name = determine_date_folder(file_path, pattern)
        move_file_to_date_folder(file_path, dest_dir_name, dry_run: dry_run)
      end

      puts "\n整理が完了しました。"
    end

    private

    def collect_files(recursive: false)
      if recursive
        Dir.glob(File.join(@target_dir, '**', '*')).select { |path| File.file?(path) }
      else
        Dir.children(@target_dir)
          .map { |entry| File.join(@target_dir, entry) }
          .select { |path| File.file?(path) }
      end
    end

    def determine_date_folder(file_path, pattern)
      # ファイルの更新日時を取得
      mtime = File.mtime(file_path)

      case pattern
      when 'year'
        mtime.strftime('%Y')
      when 'year-month'
        mtime.strftime('%Y-%m')
      when 'year-month-day'
        mtime.strftime('%Y-%m-%d')
      else
        raise ArgumentError, "不正なパターンです: #{pattern}"
      end
    end

    def move_file_to_date_folder(file_path, dest_dir_name, dry_run:)
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
  end
end
