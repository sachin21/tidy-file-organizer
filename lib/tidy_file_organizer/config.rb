require 'yaml'
require 'fileutils'
require 'digest'

module TidyFileOrganizer
  class Config
    CONFIG_DIR = File.expand_path('~/.config/tidy-file-organizer').freeze
    DEFAULT_CONFIG_PATH = File.join(CONFIG_DIR, 'default.yml').freeze
    DEFAULT_CONFIG_JA_PATH = File.join(CONFIG_DIR, 'default.ja.yml').freeze

    def initialize(target_dir)
      @target_dir = File.expand_path(target_dir)
      @config_filename = "#{Digest::MD5.hexdigest(@target_dir)}.yml"
      @config_path = File.join(CONFIG_DIR, @config_filename)
      FileUtils.mkdir_p(CONFIG_DIR)
      ensure_default_config_exists
    end

    def load
      return nil unless File.exist?(@config_path)

      YAML.load_file(@config_path)
    rescue StandardError
      nil
    end

    def save(config)
      # デフォルト設定と同じ場合はシンボリックリンクを作成
      if config_equals_default?(config)
        language = config[:language] || 'en'
        create_default_symlink(language)
      else
        content = generate_config_content(config)
        File.write(@config_path, content)
      end
    end

    def default
      { extensions: {}, keywords: {} }
    end

    def path
      @config_path
    end

    private

    def ensure_default_config_exists
      # 英語版（デフォルト）
      unless File.exist?(DEFAULT_CONFIG_PATH)
        source = File.expand_path('../../config/default.yml', __dir__)
        FileUtils.cp(source, DEFAULT_CONFIG_PATH) if File.exist?(source)
      end

      # 日本語版
      unless File.exist?(DEFAULT_CONFIG_JA_PATH)
        source_ja = File.expand_path('../../config/default.ja.yml', __dir__)
        FileUtils.cp(source_ja, DEFAULT_CONFIG_JA_PATH) if File.exist?(source_ja)
      end
    end

    def load_default_config(language = 'en')
      default_path = language == 'ja' ? DEFAULT_CONFIG_JA_PATH : DEFAULT_CONFIG_PATH
      return nil unless File.exist?(default_path)

      YAML.load_file(default_path)
    rescue StandardError
      nil
    end

    def config_equals_default?(config)
      language = config[:language] || 'en'
      default_config = load_default_config(language)
      return false unless default_config

      config == default_config
    end

    def create_default_symlink(language = 'en')
      # 既存のファイルやリンクを削除
      FileUtils.rm_f(@config_path) if File.exist?(@config_path)
      
      # 言語に応じたデフォルト設定へのシンボリックリンクを作成
      default_path = language == 'ja' ? DEFAULT_CONFIG_JA_PATH : DEFAULT_CONFIG_PATH
      File.symlink(default_path, @config_path)
    end

    def generate_config_content(config)
      header = <<~HEADER
        # tidy-file-organizer 設定ファイル
        # Target directory: #{@target_dir}
        # Configuration file: #{@config_path}
        #
        # このファイルを直接編集することもできます。
        # 再度 'tidyify setup' を実行すると上書きされます。

      HEADER

      header + config.to_yaml
    end
  end
end
