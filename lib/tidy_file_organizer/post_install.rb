require 'fileutils'

module TidyFileOrganizer
  class PostInstall
    CONFIG_DIR = File.expand_path('~/.config/tidy-file-organizer').freeze
    DEFAULT_CONFIG_PATH = File.join(CONFIG_DIR, 'default.yml').freeze

    def self.run
      FileUtils.mkdir_p(CONFIG_DIR)
      
      source = File.expand_path('../../config/default.yml', __dir__)
      
      # default.yml が存在しない場合のみコピー（上書きしない）
      unless File.exist?(DEFAULT_CONFIG_PATH)
        FileUtils.cp(source, DEFAULT_CONFIG_PATH)
        puts "✓ デフォルト設定ファイルを作成しました: #{DEFAULT_CONFIG_PATH}"
      end
    end
  end
end

# gem install 時に自動実行
TidyFileOrganizer::PostInstall.run if __FILE__ == $PROGRAM_NAME
