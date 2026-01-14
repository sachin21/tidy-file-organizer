module TidyFileOrganizer
  class SetupPrompt
    def initialize(config_manager)
      @config_manager = config_manager
    end

    def run(target_dir)
      puts I18n.t('setup.separator')
      puts "  #{I18n.t('setup.title')}"
      puts I18n.t('setup.separator')
      puts I18n.t('setup.target_directory', dir: target_dir)
      puts ''

      config = @config_manager.load || @config_manager.default

      # 言語設定
      @language = setup_language(config)
      config[:language] = @language

      setup_extensions(config)
      setup_keywords(config)

      @config_manager.save(config)
      puts ''
      puts I18n.t('setup.config_saved')
      puts I18n.t('setup.save_location', path: @config_manager.path)
      puts ''
      puts I18n.t('setup.next_steps')
      puts I18n.t('setup.step_dry_run', dir: target_dir)
      puts I18n.t('setup.step_execute', dir: target_dir)
    end

    private

    def setup_language(config)
      puts I18n.t('setup.language_setting')
      puts I18n.t('setup.section_separator')
      puts I18n.t('setup.language_description')
      puts ''
      puts I18n.t('setup.language_option_1')
      puts I18n.t('setup.language_option_2')
      puts ''
      current = config[:language] || 'en'
      current_label = current == 'ja' ? I18n.t('setup.japanese') : I18n.t('setup.english')
      puts I18n.t('setup.current_setting', setting: current_label)
      print "\n#{I18n.t('setup.language_prompt')}"
      input = read_input.strip

      case input
      when '1'
        'en'
      when '2'
        'ja'
      when ''
        current
      else
        puts I18n.t('setup.invalid_input')
        'en'
      end
    end

    def setup_extensions(config)
      puts ''
      puts I18n.t('setup.extensions_title')
      puts I18n.t('setup.section_separator')
      puts I18n.t('setup.extensions_description')
      puts ''
      puts I18n.t('setup.input_format')
      puts ''
      puts I18n.t('setup.default_values')
      show_default_extensions
      puts ''
      puts I18n.t('setup.current_config', config: format_extension_config(config[:extensions]))
      print "\n#{I18n.t('setup.new_config_prompt')}"
      input = read_input

      if input.empty? && config[:extensions].empty?
        # Use default values if empty
        config[:extensions] = default_extensions
      elsif !input.empty?
        config[:extensions] = parse_rule_input(input)
      end
    end

    def setup_keywords(config)
      puts ''
      puts I18n.t('setup.keywords_title')
      puts I18n.t('setup.section_separator')
      puts I18n.t('setup.keywords_description')
      puts I18n.t('setup.keywords_note')
      puts ''
      puts I18n.t('setup.input_format')
      puts ''
      puts I18n.t('setup.default_values')
      show_default_keywords
      puts ''
      puts I18n.t('setup.current_config', config: format_keyword_config(config[:keywords]))
      print "\n#{I18n.t('setup.new_config_prompt')}"
      input = read_input

      if input.empty? && config[:keywords].empty?
        # Use default values if empty
        config[:keywords] = default_keywords
      elsif !input.empty?
        config[:keywords] = parse_rule_input(input)
      end
    end

    def default_extensions
      if @language == 'en'
        {
          'Images' => %w[jpg jpeg png gif bmp svg webp heic heif tiff tif avif ico raw cr2 nef],
          'Videos' => %w[mp4 mov avi mkv flv wmv webm m4v 3gp ogv],
          'Audio' => %w[mp3 wav flac aac m4a ogg opus wma midi mid],
          'Documents' => %w[pdf doc docx xls xlsx ppt pptx txt md],
          'Scripts' => %w[rb py js ts java cpp c go rs sh bash zsh fish ps1 r swift kt scala clj lua],
          'Web' => %w[html css scss jsx tsx vue],
          'Archives' => %w[zip tar gz rar 7z bz2],
          'Configs' => %w[json yml yaml toml xml ini],
          'Databases' => %w[db sqlite sqlite3 sql mdb accdb],
          'Fonts' => %w[ttf otf woff woff2 eot],
          'eBooks' => %w[epub mobi azw azw3 fb2],
          'Logs' => %w[log out err],
          'Data' => %w[csv tsv parquet arrow],
        }
      else
        {
          '画像' => %w[jpg jpeg png gif bmp svg webp heic heif tiff tif avif ico raw cr2 nef],
          '動画' => %w[mp4 mov avi mkv flv wmv webm m4v 3gp ogv],
          '音声' => %w[mp3 wav flac aac m4a ogg opus wma midi mid],
          '書類' => %w[pdf doc docx xls xlsx ppt pptx txt md],
          'スクリプト' => %w[rb py js ts java cpp c go rs sh bash zsh fish ps1 r swift kt scala clj lua],
          'ウェブ' => %w[html css scss jsx tsx vue],
          'アーカイブ' => %w[zip tar gz rar 7z bz2],
          '設定' => %w[json yml yaml toml xml ini],
          'データベース' => %w[db sqlite sqlite3 sql mdb accdb],
          'フォント' => %w[ttf otf woff woff2 eot],
          '電子書籍' => %w[epub mobi azw azw3 fb2],
          'ログ' => %w[log out err],
          'データ' => %w[csv tsv parquet arrow],
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
          'Receipts' => %w[receipt 領収書 レシート],
          'Reports' => %w[report 報告書 レポート 報告],
          'Proposals' => %w[proposal 提案書 提案 企画書],
          'Presentations' => %w[presentation slide deck プレゼン 資料 スライド],
          'Templates' => %w[template テンプレート sample サンプル boilerplate],
          'Drafts' => %w[draft 草案 下書き wip temp tmp],
          'Notes' => %w[note memo メモ ノート 覚書],
        }
      else
        {
          'スクリーンショット' => %w[screenshot スクリーンショット スクショ],
          '請求書' => %w[invoice 請求書 見積],
          '議事録' => %w[議事録 minutes meeting],
          '契約書' => %w[契約 contract 同意書],
          'バックアップ' => %w[backup バックアップ bak],
          '領収書' => %w[receipt 領収書 レシート],
          '報告書' => %w[report 報告書 レポート 報告],
          '提案書' => %w[proposal 提案書 提案 企画書],
          'プレゼン資料' => %w[presentation slide deck プレゼン 資料 スライド],
          'テンプレート' => %w[template テンプレート sample サンプル boilerplate],
          '下書き' => %w[draft 草案 下書き wip temp tmp],
          'メモ' => %w[note memo メモ ノート 覚書],
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
      return I18n.t('setup.none') if exts.empty?

      exts.map { |dir, extensions| "#{extensions.join(',')}:#{dir}" }.join(' ')
    end

    def format_keyword_config(kws)
      return I18n.t('setup.none') if kws.empty?

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
