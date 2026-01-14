require_relative 'lib/tidy_file_organizer/version'

Gem::Specification.new do |spec|
  spec.name          = 'tidy-file-organizer'
  spec.version       = TidyFileOrganizer::VERSION
  spec.authors        = ['sachin21']
  spec.email          = ['sachin21@example.com'] # 適宜変更してください

  spec.summary       = 'File organizer based on extensions, names, and keywords.'
  spec.description   = 'A Ruby gem to organize files in directories based on configurable rules including ' \
                       'extensions, keywords, and dates.'
  spec.homepage      = 'https://github.com/sachin21/tidy-file-organizer'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = ['tidyify']
  spec.require_paths = ['lib']

  # Post-install message (language based on LANG environment variable)
  lang = ENV['LANG'].to_s
  spec.post_install_message = if lang.start_with?('ja')
                                <<~MSG
                                   使い方:
                                     tidyify setup ~/Downloads     # 設定を作成
                                     tidyify run ~/Downloads        # ファイルを整理

                                   詳細: https://github.com/sachin21/tidy-file-organizer
                                 MSG
                               else
                                 <<~MSG
                                   Usage:
                                     tidyify setup ~/Downloads     # Create configuration
                                     tidyify run ~/Downloads        # Organize files

                                   Details: https://github.com/sachin21/tidy-file-organizer
                                 MSG
                               end

  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.0'
  spec.add_development_dependency 'rubocop-performance', '~> 1.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 3.0'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
