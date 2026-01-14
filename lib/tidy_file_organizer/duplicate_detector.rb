require 'digest'
require 'fileutils'

module TidyFileOrganizer
  class DuplicateDetector
    attr_reader :target_dir

    def initialize(target_dir)
      @target_dir = File.expand_path(target_dir)
    end

    # 重複ファイルを検出
    # recursive: サブディレクトリも検索
    # 戻り値: { hash => [file_paths] } のハッシュ（同じハッシュ値を持つファイルのリスト）
    def find_duplicates(recursive: false)
      puts "--- 重複ファイルの検出を開始します (#{@target_dir}) ---"

      files = collect_files(recursive: recursive)

      if files.empty?
        puts '検索対象のファイルが見つかりませんでした。'
        return {}
      end

      puts "ファイル数: #{files.size}"
      puts "ハッシュ値を計算中..."

      file_hashes = calculate_file_hashes(files)
      duplicates = find_duplicate_groups(file_hashes)

      display_duplicates(duplicates)

      duplicates
    end

    # 重複ファイルを削除（最初のファイルを残し、残りを削除）
    def remove_duplicates(dry_run: true, recursive: false, interactive: true)
      duplicates = find_duplicates(recursive: recursive)

      if duplicates.empty?
        puts "\n重複ファイルは見つかりませんでした。"
        return
      end

      # 削除対象のファイルリストを作成
      deletion_plan = build_deletion_plan(duplicates)

      if interactive && !dry_run
        # インタラクティブモード: 削除の確認を求める
        return unless confirm_deletion(deletion_plan)
      end

      mode_label = dry_run ? '[Dry-run モード]' : ''
      puts "\n--- 重複ファイルの削除を開始します #{mode_label} ---"

      total_removed = 0
      total_size_saved = 0

      duplicates.each do |_hash, file_paths|
        # 最初のファイルを残し、残りを削除対象とする
        kept_file = file_paths.first
        files_to_remove = file_paths[1..]

        puts "\n保持: #{relative_path(kept_file)}"

        files_to_remove.each do |file_path|
          file_size = File.size(file_path)
          relative = relative_path(file_path)

          if dry_run
            puts "[Dry-run] 削除: #{relative} (#{human_readable_size(file_size)})"
          else
            File.delete(file_path)
            puts "削除: #{relative} (#{human_readable_size(file_size)})"
          end

          total_removed += 1
          total_size_saved += file_size
        end
      end

      puts "\n--- サマリー ---"
      puts "削除されたファイル数: #{total_removed}"
      puts "節約されたディスク容量: #{human_readable_size(total_size_saved)}"
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

    def calculate_file_hashes(files)
      file_hashes = {}

      files.each_with_index do |file_path, index|
        print "\r進捗: #{index + 1}/#{files.size}" if (index + 1) % 10 == 0 || index == files.size - 1

        begin
          hash = Digest::SHA256.file(file_path).hexdigest
          file_hashes[file_path] = hash
        rescue StandardError => e
          puts "\n⚠️  エラー: #{file_path} - #{e.message}"
        end
      end

      puts "\n"
      file_hashes
    end

    def find_duplicate_groups(file_hashes)
      # ハッシュ値でグループ化
      hash_groups = file_hashes.group_by { |_path, hash| hash }

      # 2つ以上のファイルを持つグループのみを重複として抽出
      hash_groups.select { |_hash, entries| entries.size > 1 }
                 .transform_values { |entries| entries.map(&:first) }
    end

    def display_duplicates(duplicates)
      if duplicates.empty?
        puts "\n重複ファイルは見つかりませんでした。"
        return
      end

      puts "\n=== 重複ファイルの検出結果 ==="
      puts "重複グループ数: #{duplicates.size}"

      total_duplicates = duplicates.values.sum(&:size) - duplicates.size
      puts "重複ファイル数: #{total_duplicates}"

      total_waste = 0
      duplicates.each_with_index do |(hash, file_paths), index|
        file_size = File.size(file_paths.first)
        waste_size = file_size * (file_paths.size - 1)
        total_waste += waste_size

        puts "\n--- グループ #{index + 1} (#{file_paths.size} 件, ハッシュ: #{hash[0..7]}...) ---"
        puts "ファイルサイズ: #{human_readable_size(file_size)}"
        puts "無駄な容量: #{human_readable_size(waste_size)}"

        file_paths.each do |path|
          puts "  - #{relative_path(path)}"
        end
      end

      puts "\n合計無駄容量: #{human_readable_size(total_waste)}"
    end

    def relative_path(file_path)
      file_path.sub("#{@target_dir}/", '')
    end

    def human_readable_size(size)
      units = %w[B KB MB GB TB]
      unit_index = 0
      size_float = size.to_f

      while size_float >= 1024.0 && unit_index < units.size - 1
        size_float /= 1024.0
        unit_index += 1
      end

      format('%.2f %s', size_float, units[unit_index])
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
      puts "\n" + "=" * 60
      puts "  重複ファイル削除の確認"
      puts "=" * 60
      puts "削除対象のファイル数: #{deletion_plan[:total_count]}"
      puts "節約されるディスク容量: #{human_readable_size(deletion_plan[:total_size])}"
      puts ""
      puts "削除対象のファイル:"
      puts ""

      deletion_plan[:files].each_with_index do |file_info, index|
        puts "#{index + 1}. #{relative_path(file_info[:path])} (#{human_readable_size(file_info[:size])})"
        puts "   保持されるファイル: #{relative_path(file_info[:kept_file])}"
        puts "" if (index + 1) % 5 == 0 && index < deletion_plan[:files].size - 1
      end

      puts ""
      puts "=" * 60
      print "これらのファイルを削除してもよろしいですか? [yes/no]: "

      response = $stdin.gets.chomp.downcase

      case response
      when 'yes', 'y'
        puts "削除を実行します..."
        true
      when 'no', 'n'
        puts "削除をキャンセルしました。"
        false
      else
        puts "無効な入力です。削除をキャンセルしました。"
        false
      end
    end
  end
end
