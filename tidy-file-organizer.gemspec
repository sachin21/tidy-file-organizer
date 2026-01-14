Gem::Specification.new do |spec|
  spec.name          = "tidy-file-organizer"
  spec.version       = "0.1.0"
  spec.authors        = ["sachin21"]
  spec.email          = ["sachin21@example.com"] # 適宜変更してください

  spec.summary       = "File organizer based on extensions, names, and keywords."
  spec.description   = "A Ruby gem to organize files in directories based on configurable rules including extensions, keywords, and dates."
  spec.homepage      = "https://github.com/sachin21/tidy-file-organizer"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = ["tidy-file-organizer"]
  spec.require_paths = ["lib"]

  # yamlは標準ライブラリなので依存関係から削除
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
