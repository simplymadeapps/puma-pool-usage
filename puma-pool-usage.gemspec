# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "puma-pool-usage"
  spec.version       = "0.1.0"
  spec.authors       = ["Brandon Medenwald"]
  spec.email         = ["brandon@simplymadeapps.com"]

  spec.summary       = "Puma pool usage statistics in your logs"
  spec.description   = "Add pool usage statistics within your log files."
  spec.homepage      = "https://www.github.com/simplymadeapps/puma-pool-usage"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://www.github.com/simplymadeapps/puma-pool-usage/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "puma", ">= 3.0", "< 5.0"
  spec.add_runtime_dependency "rails", ">= 5.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 0.83.0"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "simplecov-rcov"
end
