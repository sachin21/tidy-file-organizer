module TidyFileOrganizer
  class DuplicateDisplay
    include FileHelper

    CONFIRMATION_SEPARATOR = "=" * 60
    GROUP_DISPLAY_INTERVAL = 5

    def initialize(target_dir)
      @target_dir = target_dir
    end

    def display_duplicates(duplicates)
      return display_no_duplicates if duplicates.empty?

      print_summary(duplicates)
      total_waste = display_groups(duplicates)
      print_total_waste(total_waste)
    end

    def display_deletion_confirmation(deletion_plan)
      print_confirmation_header(deletion_plan)
      display_files_to_delete(deletion_plan[:files])
      print_confirmation_footer
    end

    private

    def display_no_duplicates
      puts "\n#{I18n.t('duplicate_detector.no_duplicates')}"
    end

    def print_summary(duplicates)
      puts "\n#{I18n.t('duplicate_detector.result_title')}"
      puts I18n.t('duplicate_detector.duplicate_groups', count: duplicates.size)

      total_duplicates = duplicates.values.sum(&:size) - duplicates.size
      puts I18n.t('duplicate_detector.duplicate_files', count: total_duplicates)
    end

    def display_groups(duplicates)
      total_waste = 0

      duplicates.each_with_index do |(hash, file_paths), index|
        waste_size = display_group(hash, file_paths, index)
        total_waste += waste_size
      end

      total_waste
    end

    def display_group(hash, file_paths, index)
      file_size = File.size(file_paths.first)
      waste_size = file_size * (file_paths.size - 1)

      puts "\n#{I18n.t('duplicate_detector.group_title', num: index + 1, count: file_paths.size, hash: hash[0..7])}"
      puts I18n.t('duplicate_detector.file_size', size: human_readable_size(file_size))
      puts I18n.t('duplicate_detector.wasted_space', size: human_readable_size(waste_size))

      file_paths.each do |path|
        puts "  - #{relative_path(path, @target_dir)}"
      end

      waste_size
    end

    def print_total_waste(total_waste)
      puts "\n#{I18n.t('duplicate_detector.total_wasted', size: human_readable_size(total_waste))}"
    end

    def print_confirmation_header(deletion_plan)
      puts "\n#{I18n.t('duplicate_detector.confirm_separator')}"
      puts "  #{I18n.t('duplicate_detector.confirm_header')}"
      puts I18n.t('duplicate_detector.confirm_separator')
      puts I18n.t('duplicate_detector.files_to_delete', count: deletion_plan[:total_count])
      puts I18n.t('duplicate_detector.space_to_save', size: human_readable_size(deletion_plan[:total_size]))
      puts ""
      puts I18n.t('duplicate_detector.files_list_title')
      puts ""
    end

    def display_files_to_delete(files)
      files.each_with_index do |file_info, index|
        display_file_info(file_info, index)
        add_spacing(index, files.size)
      end
    end

    def display_file_info(file_info, index)
      puts "#{index + 1}. #{relative_path(file_info[:path], @target_dir)} (#{human_readable_size(file_info[:size])})"
      puts I18n.t('duplicate_detector.kept_file', file: relative_path(file_info[:kept_file], @target_dir))
    end

    def add_spacing(index, total)
      current = index + 1
      puts "" if (current % GROUP_DISPLAY_INTERVAL).zero? && current < total
    end

    def print_confirmation_footer
      puts ""
      puts I18n.t('duplicate_detector.confirm_separator')
      print I18n.t('duplicate_detector.confirm_deletion')
    end
  end
end
