# frozen_string_literal: true

require_relative "lib/rails/page/builder/version"

Gem::Specification.new do |spec|
  spec.name = "rails-page-builder"
  spec.version = Rails::Page::Builder::VERSION
  spec.authors = ["Hadi"]
  spec.email = ["h.varposhti@roundtableapps.com"]

  spec.summary = "A visual page builder for Ruby on Rails using GrapesJS with multi-language support"
  spec.description = "This gem is designed to help you simplify working with views in Rails frameworks — especially for developers who have no background in frontend development but need to build an app.
The initial idea was to create something similar to Elementor or WPBakery, but for Rails.
I hope it’s useful. If you encounter any issues, please open a commit or let me know — I’ll do my best to fix it."
  spec.homepage = "https://github.com/hadivarp/rails-page-builder"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/hadivarp/rails-page-builder"
  spec.metadata["changelog_uri"] = "https://github.com/hadivarp/rails-page-builder/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_dependency "rails", ">= 6.0"
  spec.add_dependency "sprockets-rails", ">= 3.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
