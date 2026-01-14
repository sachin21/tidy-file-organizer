require 'yaml'
require 'fileutils'
require 'digest'

module TidyFileOrganizer
  class Config
    CONFIG_DIR = File.expand_path('~/.config/tidy-file-organizer').freeze

    def initialize(target_dir)
      @target_dir = File.expand_path(target_dir)
      @config_filename = "#{Digest::MD5.hexdigest(@target_dir)}.yml"
      @config_path = File.join(CONFIG_DIR, @config_filename)
      FileUtils.mkdir_p(CONFIG_DIR)
    end

    def load
      return nil unless File.exist?(@config_path)

      YAML.load_file(@config_path)
    rescue StandardError
      nil
    end

    def save(config)
      content = generate_config_content(config)
      File.write(@config_path, content)
    end

    def default
      { extensions: {}, keywords: {} }
    end

    def path
      @config_path
    end

    private

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
