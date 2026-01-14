module TidyFileOrganizer
  class SetupPrompt
    def initialize(config_manager)
      @config_manager = config_manager
    end

    def run(target_dir)
      puts "--- #{target_dir} の整理設定 ---"

      config = @config_manager.load || @config_manager.default

      setup_extensions(config)
      setup_keywords(config)

      @config_manager.save(config)
      puts "\n設定を保存しました: #{@config_manager.path}"
    end

    private

    def setup_extensions(config)
      puts "\n[1] 拡張子ベースの整理設定 (例: jpg,png:images pdf:docs)"
      print "現在の設定: #{format_extension_config(config[:extensions])}\n新しい設定を入力 (スキップはEnter): "
      input = read_input
      config[:extensions] = parse_rule_input(input) unless input.empty?
    end

    def setup_keywords(config)
      puts "\n[2] キーワードベースの整理設定 (例: project_a:work billing:invoice)"
      print "現在の設定: #{format_keyword_config(config[:keywords])}\n新しい設定を入力 (スキップはEnter): "
      input = read_input
      config[:keywords] = parse_rule_input(input) unless input.empty?
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
