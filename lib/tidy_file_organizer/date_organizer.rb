require 'fileutils'
require 'time'

module TidyFileOrganizer
  class DateOrganizer
    include FileHelper

    DATE_PATTERNS = {
      'year' => '%Y',
      'year-month' => '%Y-%m',
      'year-month-day' => '%Y-%m-%d',
    }.freeze

    attr_reader :target_dir

    def initialize(target_dir)
      @target_dir = File.expand_path(target_dir)
      @file_mover = FileMover.new(@target_dir)
    end

    # ファイルを日付ベースで整理
    # pattern: 'year', 'year-month', 'year-month-day'のいずれか
    def organize_by_date(pattern: 'year-month', dry_run: true, recursive: false)
      validate_pattern!(pattern)

      print_header(pattern, dry_run, recursive)

      files = collect_files(@target_dir, recursive: recursive)
      return handle_empty_files if files.empty?

      organize_files(files, pattern, dry_run)

      print_completion_message
    end

    private

    def validate_pattern!(pattern)
      return if DATE_PATTERNS.key?(pattern)

      raise ArgumentError, "不正なパターンです: #{pattern}"
    end

    def print_header(pattern, dry_run, recursive)
      mode_label = dry_run ? '[Dry-run モード]' : ''
      recursive_label = recursive ? '[再帰モード]' : ''
      puts "--- 日付ベースの整理を開始します (#{@target_dir}) #{mode_label} #{recursive_label} ---"
      puts "整理パターン: #{pattern}"
    end

    def handle_empty_files
      puts '整理対象のファイルが見つかりませんでした。'
    end

    def organize_files(files, pattern, dry_run)
      files.each do |file_path|
        dest_dir_name = determine_date_folder(file_path, pattern)
        @file_mover.move_file(file_path, dest_dir_name, dry_run: dry_run)
      end
    end

    def print_completion_message
      puts "\n整理が完了しました。"
    end

    def determine_date_folder(file_path, pattern)
      mtime = File.mtime(file_path)
      format_string = DATE_PATTERNS[pattern]
      mtime.strftime(format_string)
    end
  end
end
