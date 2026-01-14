require 'fileutils'
require_relative 'i18n'

module TidyFileOrganizer
  class PostInstall
    CONFIG_DIR = File.expand_path('~/.config/tidy-file-organizer').freeze
    DEFAULT_CONFIG_PATH = File.join(CONFIG_DIR, 'default.yml').freeze
    DEFAULT_CONFIG_JA_PATH = File.join(CONFIG_DIR, 'default.ja.yml').freeze

    def self.run
      FileUtils.mkdir_p(CONFIG_DIR)
      
      # 英語版（デフォルト）
      source = File.expand_path('../../config/default.yml', __dir__)
      unless File.exist?(DEFAULT_CONFIG_PATH)
        FileUtils.cp(source, DEFAULT_CONFIG_PATH)
        puts I18n.t('post_install.created_default_en', path: DEFAULT_CONFIG_PATH)
      end

      # 日本語版
      source_ja = File.expand_path('../../config/default.ja.yml', __dir__)
      unless File.exist?(DEFAULT_CONFIG_JA_PATH)
        FileUtils.cp(source_ja, DEFAULT_CONFIG_JA_PATH)
        puts I18n.t('post_install.created_default_ja', path: DEFAULT_CONFIG_JA_PATH)
      end
    end
  end
end

# gem install 時に自動実行
TidyFileOrganizer::PostInstall.run if __FILE__ == $PROGRAM_NAME
