require 'yaml'
require 'fileutils'
require 'digest'

module TidyFileOrganizer
  class Config
    CONFIG_DIR = File.expand_path('~/.config/tidy-file-organizer').freeze
    DEFAULT_CONFIG_PATH = File.join(CONFIG_DIR, 'default.yml').freeze

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
        create_default_symlink
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
      return if File.exist?(DEFAULT_CONFIG_PATH)

      # gem に含まれるデフォルト設定ファイルをコピー
      source = File.expand_path('../../config/default.yml', __dir__)
      FileUtils.cp(source, DEFAULT_CONFIG_PATH) if File.exist?(source)
    end

    def load_default_config
      return nil unless File.exist?(DEFAULT_CONFIG_PATH)

      YAML.load_file(DEFAULT_CONFIG_PATH)
    rescue StandardError
      nil
    end

    def config_equals_default?(config)
      default_config = load_default_config
      return false unless default_config

      config == default_config
    end

    def create_default_symlink
      # 既存のファイルやリンクを削除
      FileUtils.rm_f(@config_path) if File.exist?(@config_path)
      
      # シンボリックリンクを作成
      File.symlink(DEFAULT_CONFIG_PATH, @config_path)
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
