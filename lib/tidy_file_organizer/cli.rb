module TidyFileOrganizer
  class CLI
    COMMANDS = %w[setup run organize-by-date find-duplicates remove-duplicates].freeze

    def initialize(args)
      @args = args
      @command = args[0]
      # オプションではない最初の引数をディレクトリとして扱う
      @target_dir = args[1..-1]&.find { |arg| !arg.start_with?('-') }
    end

    def run
      unless valid_command?
        show_usage
        exit 1
      end

      # runコマンドの場合、ディレクトリ指定がなければカレントディレクトリを使用
      target_dir = @target_dir
      if @command == 'run' && target_dir.nil?
        target_dir = Dir.pwd
      end

      # run以外のコマンドではディレクトリ指定が必須
      unless target_dir
        puts 'エラー: 対象ディレクトリを指定してください'
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
        # デフォルトはインタラクティブモード（確認あり）
        # --no-confirm オプションで確認をスキップ
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
      puts 'Usage: tidyify [command] [target_directory] [options]'
      puts "\nCommands:"
      puts '  setup              整理ルールをインタラクティブに設定します'
      puts '  run                設定に基づいてファイルを整理します（ディレクトリ省略時はカレントディレクトリ）'
      puts '  organize-by-date   ファイルを更新日時ベースで整理します'
      puts '  find-duplicates    重複ファイルを検出します'
      puts '  remove-duplicates  重複ファイルを削除します（最初のファイルを保持）'
      puts "\nOptions:"
      puts '  --dry-run             実際には実行せず、シミュレーションのみ行います'
      puts '  --recursive, -r       サブディレクトリ内のファイルも再帰的に処理します'
      puts '  --pattern=<pattern>   日付整理のパターン (year, year-month, year-month-day)'
      puts '  --no-confirm          削除前の確認をスキップします（remove-duplicatesのみ）'
      puts "\nExamples:"
      puts '  tidyify setup ~/Downloads'
      puts '  tidyify run                                     # カレントディレクトリを整理'
      puts '  tidyify run ~/Downloads --dry-run               # シミュレーション'
      puts '  tidyify run ~/Downloads --recursive             # 実際に実行'
      puts '  tidyify organize-by-date ~/Downloads --pattern=year-month'
      puts '  tidyify find-duplicates ~/Downloads --recursive'
      puts '  tidyify remove-duplicates ~/Downloads --recursive'
      puts '  tidyify remove-duplicates ~/Downloads --no-confirm'
    end
  end
end
