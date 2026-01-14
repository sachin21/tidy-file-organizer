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
      puts "\n重複ファイルは見つかりませんでした。"
    end

    def print_summary(duplicates)
      puts "\n=== 重複ファイルの検出結果 ==="
      puts "重複グループ数: #{duplicates.size}"

      total_duplicates = duplicates.values.sum(&:size) - duplicates.size
      puts "重複ファイル数: #{total_duplicates}"
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

      puts "\n--- グループ #{index + 1} (#{file_paths.size} 件, ハッシュ: #{hash[0..7]}...) ---"
      puts "ファイルサイズ: #{human_readable_size(file_size)}"
      puts "無駄な容量: #{human_readable_size(waste_size)}"

      file_paths.each do |path|
        puts "  - #{relative_path(path, @target_dir)}"
      end

      waste_size
    end

    def print_total_waste(total_waste)
      puts "\n合計無駄容量: #{human_readable_size(total_waste)}"
    end

    def print_confirmation_header(deletion_plan)
      puts "\n#{CONFIRMATION_SEPARATOR}"
      puts "  重複ファイル削除の確認"
      puts CONFIRMATION_SEPARATOR
      puts "削除対象のファイル数: #{deletion_plan[:total_count]}"
      puts "節約されるディスク容量: #{human_readable_size(deletion_plan[:total_size])}"
      puts ""
      puts "削除対象のファイル:"
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
      puts "   保持されるファイル: #{relative_path(file_info[:kept_file], @target_dir)}"
    end

    def add_spacing(index, total)
      current = index + 1
      puts "" if (current % GROUP_DISPLAY_INTERVAL).zero? && current < total
    end

    def print_confirmation_footer
      puts ""
      puts CONFIRMATION_SEPARATOR
      print "これらのファイルを削除してもよろしいですか? [yes/no]: "
    end
  end
end
