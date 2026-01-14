module TidyFileOrganizer
  class CLI
    COMMANDS = %w[setup run].freeze

    def initialize(args)
      @args = args
      @command = args[0]
      @target_dir = args[1] || "."
    end

    def run
      unless valid_command?
        show_usage
        exit 1
      end

      organizer = Organizer.new(@target_dir)

      case @command
      when "setup"
        organizer.setup
      when "run"
        dry_run = !@args.include?("--force")
        organizer.run(dry_run: dry_run)
      end
    end

    private

    def valid_command?
      COMMANDS.include?(@command)
    end

    def show_usage
      puts "Usage: tidy-file-organizer [setup|run] [target_directory] [options]"
      puts "\nCommands:"
      puts "  setup    整理ルールをインタラクティブに設定します"
      puts "  run      設定に基づいてファイルを整理します"
      puts "\nOptions:"
      puts "  --force  Dry-runを無効にして実際にファイルを移動します"
    end
  end
end
