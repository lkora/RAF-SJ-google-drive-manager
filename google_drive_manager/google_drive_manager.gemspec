# frozen_string_literal: true

require_relative "lib/google_drive_manager/version"

Gem::Specification.new do |spec|
  spec.name = "google_drive_manager"
  spec.version = GoogleDriveManager::VERSION
  spec.authors = ["Luka Korica"]
  spec.email = ["lukakorica@gmail.com"]

  spec.summary = "Google sheets manager"
  spec.description = "Google sheets manager simplifies managment of google sheets. University project for the course Script languages."
  spec.homepage = "https://github.com/lkora/RAF-SJ-google-drive-manager"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "google_drive", "~> 3.0.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
