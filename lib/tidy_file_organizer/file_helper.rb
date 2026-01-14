module TidyFileOrganizer
  module FileHelper
    BYTE_UNITS = %w[B KB MB GB TB].freeze
    BYTES_PER_UNIT = 1024.0

    # ファイルを収集する
    def collect_files(target_dir, recursive: false, exclude_dirs: [])
      if recursive
        collect_files_recursively(target_dir, exclude_dirs)
      else
        collect_files_in_directory(target_dir)
      end
    end

    # 相対パスを取得
    def relative_path(file_path, base_dir)
      file_path.sub("#{base_dir}/", '')
    end

    # ファイルサイズを人間が読める形式に変換
    def human_readable_size(size)
      unit_index = 0
      size_float = size.to_f

      while size_float >= BYTES_PER_UNIT && unit_index < BYTE_UNITS.size - 1
        size_float /= BYTES_PER_UNIT
        unit_index += 1
      end

      format('%.2f %s', size_float, BYTE_UNITS[unit_index])
    end

    private

    def collect_files_in_directory(target_dir)
      Dir.children(target_dir)
        .map { |entry| File.join(target_dir, entry) }
        .select { |path| File.file?(path) }
    end

    def collect_files_recursively(target_dir, exclude_dirs)
      pattern = File.join(target_dir, '**', '*')
      Dir.glob(pattern).select do |path|
        File.file?(path) && !excluded_path?(path, target_dir, exclude_dirs)
      end
    end

    def excluded_path?(path, target_dir, exclude_dirs)
      return false if exclude_dirs.empty?

      relative = path.sub("#{target_dir}/", '')
      path_parts = relative.split('/')

      exclude_dirs.any? { |dir| path_parts.include?(dir) }
    end
  end
end
