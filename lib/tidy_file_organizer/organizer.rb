require 'yaml'
require 'fileutils'
require 'digest'

module TidyFileOrganizer
  class Organizer
    CONFIG_DIR = File.expand_path('~/.tidy-file-organizer/configs')

    def initialize(target_dir)
      @target_dir = File.expand_path(target_dir)
      @config_path = File.join(CONFIG_DIR, "#{Digest::MD5.hexdigest(@target_dir)}.yml")
      FileUtils.mkdir_p(CONFIG_DIR) unless Dir.exist?(CONFIG_DIR)
    end

  def setup
    puts "--- #{@target_dir} の整理設定 ---"
    
    config = load_config || default_config

    # 拡張子ベースの設定
    puts "\n[1] 拡張子ベースの整理設定 (例: jpg,png:images pdf:docs)"
    print "現在の設定: #{format_extension_config(config[:extensions])}\n新しい設定を入力 (スキップはEnter): "
    input = gets.chomp
    config[:extensions] = parse_extension_input(input) unless input.empty?

    # キーワードベースの設定
    puts "\n[2] キーワードベースの整理設定 (例: project_a:work billing:invoice)"
    print "現在の設定: #{format_keyword_config(config[:keywords])}\n新しい設定を入力 (スキップはEnter): "
    input = gets.chomp
    config[:keywords] = parse_keyword_input(input) unless input.empty?

    save_config(config)
    puts "\n設定を保存しました: #{@config_path}"
  end

  private

  def load_config
    return nil unless File.exist?(@config_path)
    YAML.load_file(@config_path)
  rescue
    nil
  end

  def save_config(config)
    File.write(@config_path, config.to_yaml)
  end

  def default_config
    {
      extensions: {},
      keywords: {}
    }
  end

  def format_extension_config(exts)
    return "なし" if exts.empty?
    exts.map { |dir, extensions| "#{extensions.join(',')}:#{dir}" }.join(" ")
  end

  def format_keyword_config(kws)
    return "なし" if kws.empty?
    kws.map { |dir, keywords| "#{keywords.join(',')}:#{dir}" }.join(" ")
  end

  def parse_extension_input(input)
    # input format: "jpg,png:images pdf:docs"
    result = {}
    input.split(/\s+/).each do |part|
      exts, dir = part.split(':')
      next unless exts && dir
      result[dir] = exts.split(',')
    end
    result
  end

    def parse_keyword_input(input)
      # input format: "project_a:work billing:invoice"
      result = {}
      input.split(/\s+/).each do |part|
        kws, dir = part.split(':')
        next unless kws && dir
        result[dir] = kws.split(',')
      end
      result
    end
  end
end
