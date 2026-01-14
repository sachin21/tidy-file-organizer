module TidyFileOrganizer
  class SetupPrompt
    def initialize(config_manager)
      @config_manager = config_manager
    end

    def run(target_dir)
      puts "=" * 60
      puts "  tidy-file-organizer セットアップ"
      puts "=" * 60
      puts "対象ディレクトリ: #{target_dir}"
      puts ""

      config = @config_manager.load || @config_manager.default

      setup_extensions(config)
      setup_keywords(config)

      @config_manager.save(config)
      puts ""
      puts "✓ 設定を保存しました"
      puts "  保存先: #{@config_manager.path}"
      puts ""
      puts "次のステップ:"
      puts "  1. Dry-run でシミュレーション: tidy-file-organizer run #{target_dir}"
      puts "  2. 実際に整理を実行: tidy-file-organizer run #{target_dir} --force"
    end

    private

    def setup_extensions(config)
      puts "[1] 拡張子による整理ルール"
      puts "-" * 60
      puts "説明: ファイルの拡張子に基づいて整理先フォルダを指定します"
      puts ""
      puts "入力形式: 拡張子リスト:フォルダ名 拡張子リスト:フォルダ名 ..."
      puts ""
      puts "デフォルト値:"
      show_default_extensions
      puts ""
      puts "現在の設定: #{format_extension_config(config[:extensions])}"
      print "\n新しい設定を入力 (変更しない場合はEnter): "
      input = read_input
      config[:extensions] = parse_rule_input(input) unless input.empty?
    end

    def setup_keywords(config)
      puts ""
      puts "[2] キーワードによる整理ルール"
      puts "-" * 60
      puts "説明: ファイル名に含まれるキーワードで整理先フォルダを指定します"
      puts "      ※キーワードは拡張子より優先されます"
      puts ""
      puts "入力形式: キーワードリスト:フォルダ名 キーワードリスト:フォルダ名 ..."
      puts ""
      puts "デフォルト値:"
      show_default_keywords
      puts ""
      puts "現在の設定: #{format_keyword_config(config[:keywords])}"
      print "\n新しい設定を入力 (変更しない場合はEnter): "
      input = read_input
      config[:keywords] = parse_rule_input(input) unless input.empty?
    end

    def show_default_extensions
      defaults = {
        '画像' => ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'svg', 'webp'],
        '動画' => ['mp4', 'mov', 'avi', 'mkv', 'flv', 'wmv'],
        '音声' => ['mp3', 'wav', 'flac', 'aac', 'm4a'],
        '書類' => ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'md'],
        'スクリプト' => ['rb', 'py', 'js', 'ts', 'java', 'cpp', 'c', 'go', 'rs'],
        'ウェブ' => ['html', 'css', 'scss', 'jsx', 'tsx', 'vue'],
        'アーカイブ' => ['zip', 'tar', 'gz', 'rar', '7z', 'bz2'],
        '設定' => ['json', 'yml', 'yaml', 'toml', 'xml', 'ini']
      }
      defaults.each do |dir, exts|
        puts "  #{exts.join(',')}:#{dir}"
      end
    end

    def show_default_keywords
      defaults = {
        'スクリーンショット' => ['screenshot', 'スクリーンショット', 'スクショ'],
        '請求書' => ['invoice', '請求書', '見積'],
        '議事録' => ['議事録', 'minutes', 'meeting'],
        '契約書' => ['契約', 'contract', '同意書'],
        'バックアップ' => ['backup', 'バックアップ', 'bak']
      }
      defaults.each do |dir, keywords|
        puts "  #{keywords.join(',')}:#{dir}"
      end
    end

    def read_input
      if $stdin.tty?
        $stdin.gets.chomp
      else
        STDIN.gets.chomp
      end
    end

    def format_extension_config(exts)
      return "なし" if exts.empty?
      exts.map { |dir, extensions| "#{extensions.join(',')}:#{dir}" }.join(" ")
    end

    def format_keyword_config(kws)
      return "なし" if kws.empty?
      kws.map { |dir, keywords| "#{keywords.join(',')}:#{dir}" }.join(" ")
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
