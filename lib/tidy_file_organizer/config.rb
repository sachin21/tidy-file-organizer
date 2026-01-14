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
      FileUtils.mkdir_p(CONFIG_DIR) unless Dir.exist?(CONFIG_DIR)
    end

    def load
      return nil unless File.exist?(@config_path)
      YAML.load_file(@config_path)
    rescue
      nil
    end

    def save(config)
      File.write(@config_path, config.to_yaml)
    end

    def default
      { extensions: {}, keywords: {} }
    end

    def path
      @config_path
    end
  end
end
