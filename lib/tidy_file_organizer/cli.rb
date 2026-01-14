module TidyFileOrganizer
  class CLI
    COMMANDS = %w[setup run organize-by-date find-duplicates remove-duplicates].freeze

    def initialize(args)
      @args = args
      @command = args[0]
      # Treat first non-option argument as directory
      @target_dir = args[1..-1]&.find { |arg| !arg.start_with?('-') }
    end

    def run
      unless valid_command?
        show_usage
        exit 1
      end

      # For setup and run commands, use current directory if not specified
      target_dir = @target_dir
      if (@command == 'run' || @command == 'setup') && target_dir.nil?
        target_dir = Dir.pwd
      end

      # For other commands, directory specification is required
      unless target_dir
        puts I18n.t('cli.error_directory_required')
        puts ''
        show_usage
        exit 1
      end

      case @command
      when 'setup'
        organizer = Organizer.new(target_dir)
        organizer.setup
      when 'run'
        organizer = Organizer.new(target_dir)
        dry_run = @args.include?('--dry-run')
        recursive = @args.include?('--recursive') || @args.include?('-r')
        organizer.run(dry_run: dry_run, recursive: recursive)
      when 'organize-by-date'
        date_organizer = DateOrganizer.new(target_dir)
        dry_run = @args.include?('--dry-run')
        recursive = @args.include?('--recursive') || @args.include?('-r')
        pattern = extract_pattern || 'year-month'
        date_organizer.organize_by_date(pattern: pattern, dry_run: dry_run, recursive: recursive)
      when 'find-duplicates'
        detector = DuplicateDetector.new(target_dir)
        recursive = @args.include?('--recursive') || @args.include?('-r')
        detector.find_duplicates(recursive: recursive)
      when 'remove-duplicates'
        detector = DuplicateDetector.new(target_dir)
        dry_run = @args.include?('--dry-run')
        recursive = @args.include?('--recursive') || @args.include?('-r')
        # Default is interactive mode (with confirmation)
        # --no-confirm option skips confirmation
        interactive = !@args.include?('--no-confirm')
        detector.remove_duplicates(dry_run: dry_run, recursive: recursive, interactive: interactive)
      end
    end

    private

    def valid_command?
      COMMANDS.include?(@command)
    end

    def extract_pattern
      pattern_arg = @args.find { |arg| arg.start_with?('--pattern=') }
      return nil unless pattern_arg

      pattern_arg.split('=')[1]
    end

    def show_usage
      puts I18n.t('cli.usage')
      puts "\n#{I18n.t('cli.commands')}"
      puts I18n.t('cli.cmd_setup')
      puts I18n.t('cli.cmd_run')
      puts I18n.t('cli.cmd_organize_date')
      puts I18n.t('cli.cmd_find_dup')
      puts I18n.t('cli.cmd_remove_dup')
      puts "\n#{I18n.t('cli.options')}"
      puts I18n.t('cli.opt_dry_run')
      puts I18n.t('cli.opt_recursive')
      puts I18n.t('cli.opt_pattern')
      puts I18n.t('cli.opt_no_confirm')
      puts "\n#{I18n.t('cli.examples')}"
      puts I18n.t('cli.ex_setup')
      puts I18n.t('cli.ex_run_current')
      puts I18n.t('cli.ex_run_dry')
      puts I18n.t('cli.ex_run_exec')
      puts I18n.t('cli.ex_organize_date')
      puts I18n.t('cli.ex_find_dup')
      puts I18n.t('cli.ex_remove_dup')
      puts I18n.t('cli.ex_remove_no_confirm')
    end
  end
end
