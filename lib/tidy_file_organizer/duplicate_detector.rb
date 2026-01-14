require 'digest'
require 'fileutils'

module TidyFileOrganizer
  class DuplicateDetector
    include FileHelper

    PROGRESS_UPDATE_INTERVAL = 10

    attr_reader :target_dir

    def initialize(target_dir)
      @target_dir = File.expand_path(target_dir)
      @display = DuplicateDisplay.new(@target_dir)
    end

    # Detect duplicate files
    # recursive: also search subdirectories
    # Returns: Hash of { hash => [file_paths] } (list of files with same hash)
    def find_duplicates(recursive: false)
      print_header

      files = collect_files(@target_dir, recursive: recursive)
      return handle_empty_files if files.empty?

      print_file_count(files.size)

      file_hashes = calculate_file_hashes(files)
      duplicates = find_duplicate_groups(file_hashes)

      @display.display_duplicates(duplicates)

      duplicates
    end

    # Remove duplicate files (keep first file, delete others)
    def remove_duplicates(dry_run: false, recursive: false, interactive: true)
      duplicates = find_duplicates(recursive: recursive)
      return handle_no_duplicates if duplicates.empty?

      deletion_plan = build_deletion_plan(duplicates)
      return unless should_proceed_with_deletion?(deletion_plan, dry_run, interactive)

      execute_deletion(duplicates, dry_run)
    end

    private

    def print_header
      puts I18n.t('duplicate_detector.starting', dir: @target_dir)
    end

    def print_file_count(count)
      puts I18n.t('duplicate_detector.file_count', count: count)
      puts I18n.t('duplicate_detector.calculating')
    end

    def handle_empty_files
      puts I18n.t('organizer.no_files')
      {}
    end

    def handle_no_duplicates
      puts "\n#{I18n.t('duplicate_detector.no_duplicates')}"
    end

    def should_proceed_with_deletion?(deletion_plan, dry_run, interactive)
      return true unless interactive && !dry_run

      confirm_deletion(deletion_plan)
    end

    def execute_deletion(duplicates, dry_run)
      print_deletion_header(dry_run)

      stats = delete_duplicate_files(duplicates, dry_run)

      print_deletion_summary(stats)
    end

    def print_deletion_header(dry_run)
      mode_label = dry_run ? I18n.t('organizer.dry_run_mode') : ''
      puts I18n.t('duplicate_detector.deletion_starting', mode: mode_label)
    end

    def delete_duplicate_files(duplicates, dry_run)
      total_removed = 0
      total_size_saved = 0

      duplicates.each do |_hash, file_paths|
        kept_file = file_paths.first
        files_to_remove = file_paths[1..]

        puts "\n#{I18n.t('duplicate_detector.kept', file: relative_path(kept_file, @target_dir))}"

        files_to_remove.each do |file_path|
          file_size = File.size(file_path)
          delete_file(file_path, file_size, dry_run)

          total_removed += 1
          total_size_saved += file_size
        end
      end

      { removed: total_removed, size_saved: total_size_saved }
    end

    def delete_file(file_path, file_size, dry_run)
      relative = relative_path(file_path, @target_dir)

      if dry_run
        puts "[Dry-run] #{I18n.t('duplicate_detector.deleted', file: relative, size: human_readable_size(file_size))}"
      else
        File.delete(file_path)
        puts I18n.t('duplicate_detector.deleted', file: relative, size: human_readable_size(file_size))
      end
    end

    def print_deletion_summary(stats)
      puts "\n#{I18n.t('duplicate_detector.summary')}"
      puts I18n.t('duplicate_detector.deleted_count', count: stats[:removed])
      puts I18n.t('duplicate_detector.saved_space', size: human_readable_size(stats[:size_saved]))
    end

    def calculate_file_hashes(files)
      file_hashes = {}

      files.each_with_index do |file_path, index|
        print_progress(index, files.size)

        begin
          file_hashes[file_path] = Digest::SHA256.file(file_path).hexdigest
        rescue StandardError => e
          puts "\n⚠️  エラー: #{file_path} - #{e.message}"
        end
      end

      puts "\n"
      file_hashes
    end

    def print_progress(index, total)
      current = index + 1
      return unless (current % PROGRESS_UPDATE_INTERVAL).zero? || current == total

      print "\r#{I18n.t('duplicate_detector.progress', current: current, total: total)}"
    end

    def find_duplicate_groups(file_hashes)
      # Group by hash value
      hash_groups = file_hashes.group_by { |_path, hash| hash }

      # Extract only groups with 2 or more files as duplicates
      hash_groups.select { |_hash, entries| entries.size > 1 }
                 .transform_values { |entries| entries.map(&:first) }
    end

    def build_deletion_plan(duplicates)
      plan = { files: [], total_count: 0, total_size: 0 }

      duplicates.each do |_hash, file_paths|
        kept_file = file_paths.first
        files_to_remove = file_paths[1..]

        files_to_remove.each do |file_path|
          file_size = File.size(file_path)
          plan[:files] << { path: file_path, size: file_size, kept_file: kept_file }
          plan[:total_count] += 1
          plan[:total_size] += file_size
        end
      end

      plan
    end

    def confirm_deletion(deletion_plan)
      @display.display_deletion_confirmation(deletion_plan)
      handle_user_response
    end

    def handle_user_response
      response = $stdin.gets.chomp.downcase

      case response
      when 'yes', 'y'
        puts I18n.t('duplicate_detector.executing_deletion')
        true
      when 'no', 'n'
        puts I18n.t('duplicate_detector.deletion_cancelled')
        false
      else
        puts I18n.t('duplicate_detector.invalid_response')
        false
      end
    end
  end
end
