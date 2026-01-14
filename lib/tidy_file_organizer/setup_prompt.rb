module TidyFileOrganizer
  class SetupPrompt
    def initialize(config_manager)
      @config_manager = config_manager
    end

    def run(target_dir)
      puts '=' * 60
      puts '  tidy-file-organizer セットアップ'
      puts '=' * 60
      puts "対象ディレクトリ: #{target_dir}"
      puts ''

      config = @config_manager.load || @config_manager.default

      # 言語設定
      @language = setup_language(config)
      config[:language] = @language

      setup_extensions(config)
      setup_keywords(config)

      @config_manager.save(config)
      puts ''
      puts '✓ 設定を保存しました'
      puts "  保存先: #{@config_manager.path}"
      puts ''
      puts '次のステップ:'
      puts "  1. シミュレーション: tidyify run #{target_dir} --dry-run"
      puts "  2. 実際に整理を実行: tidyify run #{target_dir}"
    end

    private

    def setup_language(config)
      puts '[0] フォルダ名の言語設定'
      puts '-' * 60
      puts '説明: 整理先フォルダ名を日本語にするか英語にするか選択します'
      puts ''
      puts '  1: English (例: Images, Documents, Screenshots)'
      puts '  2: 日本語 (例: 画像, 書類, スクリーンショット)'
      puts ''
      current = config[:language] || 'en'
      current_label = current == 'ja' ? '日本語' : 'English'
      puts "現在の設定: #{current_label}"
      print "\n選択 (1=English, 2=日本語, Enter=現在の設定のまま): "
      input = read_input.strip

      case input
      when '1'
        'en'
      when '2'
        'ja'
      when ''
        current
      else
        puts "無効な入力です。デフォルト（English）を使用します。"
        'en'
      end
    end

    def setup_extensions(config)
      puts '[1] 拡張子による整理ルール'
      puts '-' * 60
      puts '説明: ファイルの拡張子に基づいて整理先フォルダを指定します'
      puts ''
      puts '入力形式: 拡張子リスト:フォルダ名 拡張子リスト:フォルダ名 ...'
      puts ''
      puts 'デフォルト値:'
      show_default_extensions
      puts ''
      puts "現在の設定: #{format_extension_config(config[:extensions])}"
      print "\n新しい設定を入力 (デフォルト値を使う場合はEnter): "
      input = read_input
      
      if input.empty? && config[:extensions].empty?
        # 空の場合はデフォルト値を設定
        config[:extensions] = default_extensions
      elsif !input.empty?
        config[:extensions] = parse_rule_input(input)
      end
    end

    def setup_keywords(config)
      puts ''
      puts '[2] キーワードによる整理ルール'
      puts '-' * 60
      puts '説明: ファイル名に含まれるキーワードで整理先フォルダを指定します'
      puts '      ※キーワードは拡張子より優先されます'
      puts ''
      puts '入力形式: キーワードリスト:フォルダ名 キーワードリスト:フォルダ名 ...'
      puts ''
      puts 'デフォルト値:'
      show_default_keywords
      puts ''
      puts "現在の設定: #{format_keyword_config(config[:keywords])}"
      print "\n新しい設定を入力 (デフォルト値を使う場合はEnter): "
      input = read_input
      
      if input.empty? && config[:keywords].empty?
        # 空の場合はデフォルト値を設定
        config[:keywords] = default_keywords
      elsif !input.empty?
        config[:keywords] = parse_rule_input(input)
      end
    end

    def default_extensions
      if @language == 'en'
        {
          'Images' => %w[jpg jpeg png gif bmp svg webp],
          'Videos' => %w[mp4 mov avi mkv flv wmv],
          'Audio' => %w[mp3 wav flac aac m4a],
          'Documents' => %w[pdf doc docx xls xlsx ppt pptx txt md],
          'Scripts' => %w[rb py js ts java cpp c go rs],
          'Web' => %w[html css scss jsx tsx vue],
          'Archives' => %w[zip tar gz rar 7z bz2],
          'Configs' => %w[json yml yaml toml xml ini],
        }
      else
        {
          '画像' => %w[jpg jpeg png gif bmp svg webp],
          '動画' => %w[mp4 mov avi mkv flv wmv],
          '音声' => %w[mp3 wav flac aac m4a],
          '書類' => %w[pdf doc docx xls xlsx ppt pptx txt md],
          'スクリプト' => %w[rb py js ts java cpp c go rs],
          'ウェブ' => %w[html css scss jsx tsx vue],
          'アーカイブ' => %w[zip tar gz rar 7z bz2],
          '設定' => %w[json yml yaml toml xml ini],
        }
      end
    end

    def default_keywords
      if @language == 'en'
        {
          'Screenshots' => %w[screenshot スクリーンショット スクショ],
          'Invoices' => %w[invoice 請求書 見積],
          'Minutes' => %w[議事録 minutes meeting],
          'Contracts' => %w[契約 contract 同意書],
          'Backups' => %w[backup バックアップ bak],
        }
      else
        {
          'スクリーンショット' => %w[screenshot スクリーンショット スクショ],
          '請求書' => %w[invoice 請求書 見積],
          '議事録' => %w[議事録 minutes meeting],
          '契約書' => %w[契約 contract 同意書],
          'バックアップ' => %w[backup バックアップ bak],
        }
      end
    end

    def show_default_extensions
      default_extensions.each do |dir, exts|
        puts "  #{exts.join(',')}:#{dir}"
      end
    end

    def show_default_keywords
      default_keywords.each do |dir, keywords|
        puts "  #{keywords.join(',')}:#{dir}"
      end
    end

    def read_input
      $stdin.gets.chomp
    end

    def format_extension_config(exts)
      return 'なし' if exts.empty?

      exts.map { |dir, extensions| "#{extensions.join(',')}:#{dir}" }.join(' ')
    end

    def format_keyword_config(kws)
      return 'なし' if kws.empty?

      kws.map { |dir, keywords| "#{keywords.join(',')}:#{dir}" }.join(' ')
    end

    def parse_rule_input(input)
      result = {}
      input.split(/\s+/).each do |part|
        items, dir = part.split(':')
        next unless items && dir

        result[dir] = items.split(',')
      end
      result
    end
  end
end
