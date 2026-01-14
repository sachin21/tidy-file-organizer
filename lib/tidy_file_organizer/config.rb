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

      config = YAML.load_file(@config_path)
      
      # If it's a reference to default config, load the default config
      if config.is_a?(Hash) && config[:use_default]
        language = config[:language] || 'en'
        load_default_config(language)
      else
        config
      end
    rescue StandardError
      nil
    end

    def save(config)
      # If same as default config, create a reference file
      if config_equals_default?(config)
        language = config[:language] || 'en'
        create_default_reference(language)
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

    def create_default_reference(language = 'en')
      # Create a reference file indicating to use default config
      reference_config = {
        use_default: true,
        language: language,
        target_directory: @target_dir
      }
      
      content = <<~HEADER
        # tidy-file-organizer configuration file (using default config)
        # Target directory: #{@target_dir}
        # Configuration file: #{@config_path}
        #
        # This configuration uses default config (#{language == 'ja' ? 'default.ja.yml' : 'default.yml'}).
        # To customize, re-run 'tidyify setup'.

      HEADER
      
      File.write(@config_path, content + reference_config.to_yaml)
    end

    def generate_config_content(config)
      header = <<~HEADER
        # tidy-file-organizer configuration file
        # Target directory: #{@target_dir}
        # Configuration file: #{@config_path}
        #
        # You can edit this file directly.
        # Running 'tidyify setup' again will overwrite it.

      HEADER

      header + config.to_yaml
    end
  end
end
