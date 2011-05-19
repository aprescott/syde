Gem::Specification.new do |s|
  s.name         = "syde"
  s.version      = "0.0.1"
  s.authors      = ["Adam Prescott"]
  s.email        = ["adam@aprescott.com"]
  s.homepage     = "https://github.com/aprescott/syde"
  s.summary      = "Symmetric data encryption library."
  s.description  = "Syde is a symmetric data encryption library written in Ruby, licensed under the MIT license. It provides a saved encrypted data storage under a single password."
  s.files        = Dir["{lib/**/*,test/**/*}"] + %w[LICENSE Gemfile rakefile README.md syde.gemspec .gemtest]
  s.require_path = "lib"
  s.test_files   = Dir["test/*"]
  s.has_rdoc     = false
  s.add_development_dependency "rake"
  s.required_ruby_version = "~> 1.8.7"
  s.requirements << "Ruby 1.8.7, does not work with 1.9 (yet) due to encodings"
end
