require 'fileutils'

module TidyFileOrganizer
  class FileMover
    attr_reader :target_dir

    def initialize(target_dir)
      @target_dir = File.expand_path(target_dir)
    end

    # Move file to specified directory
    def move_file(file_path, dest_dir_name, dry_run: false)
      filename = File.basename(file_path)
      relative = relative_path(file_path)
      dest_dir = File.join(@target_dir, dest_dir_name)
      dest_path = File.join(dest_dir, filename)

      return handle_conflict(relative, dest_dir_name, dry_run) if conflicting?(file_path, dest_path)
      return handle_skip(relative, dry_run) if already_in_place?(file_path, dest_path)

      perform_move(file_path, dest_dir, dest_path, relative, dest_dir_name, dry_run)
    end

    private

    def relative_path(file_path)
      file_path.sub("#{@target_dir}/", '')
    end

    def conflicting?(file_path, dest_path)
      File.exist?(dest_path) && file_path != dest_path
    end

    def already_in_place?(file_path, dest_path)
      file_path == dest_path
    end

    def handle_conflict(relative, dest_dir_name, dry_run)
      message = "⚠️  Conflict: #{relative} -> #{dest_dir_name}/ (filename conflict)"
      puts dry_run ? "[Dry-run] #{message}" : message
    end

    def handle_skip(relative, dry_run)
      puts I18n.t('organizer.skip', file: relative) if dry_run
    end

    def perform_move(file_path, dest_dir, dest_path, relative, dest_dir_name, dry_run)
      if dry_run
        puts "[Dry-run] #{relative} -> #{dest_dir_name}/"
      else
        FileUtils.mkdir_p(dest_dir)
        FileUtils.mv(file_path, dest_path)
        puts "Moved: #{relative} -> #{dest_dir_name}/"
      end
    end
  end
end
