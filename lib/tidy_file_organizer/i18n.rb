require 'yaml'

module TidyFileOrganizer
  module I18n
    class << self
      def locale
        @locale ||= detect_locale
      end

      def locale=(value)
        @locale = value
      end

      def t(key, **options)
        translations = load_translations(locale)
        text = translations.dig(*key.to_s.split('.')) || key.to_s

        # Variable substitution
        options.each do |k, v|
          text = text.gsub("%{#{k}}", v.to_s)
        end

        text
      end

      private

      def detect_locale
        lang = ENV['LANG'].to_s
        lang.start_with?('ja') ? :ja : :en
      end

      def load_translations(locale)
        @translations ||= {}
        @translations[locale] ||= begin
          locale_file = File.expand_path("locale/#{locale}.yml", __dir__)
          yaml_data = YAML.load_file(locale_file)
          yaml_data[locale.to_s]
        end
      end
    end
  end
end
