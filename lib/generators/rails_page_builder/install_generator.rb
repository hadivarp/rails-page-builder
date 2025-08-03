# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/migration'

module RailsPageBuilder
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      include ::Rails::Generators::Migration
      
      source_root File.expand_path('templates', __dir__)
      desc 'Install Rails Page Builder'
      
      def self.next_migration_number(path)
        ::ActiveRecord::Generators::Base.next_migration_number(path)
      end
      
      def create_migration
        migration_template 'create_pages.rb', 'db/migrate/create_pages.rb'
      end
      
      def create_controller
        template 'pages_controller.rb', 'app/controllers/page_builder/pages_controller.rb'
      end
      
      def create_views
        template 'index.html.erb', 'app/views/page_builder/pages/index.html.erb'
        template 'show.html.erb', 'app/views/page_builder/pages/show.html.erb'
        template 'edit.html.erb', 'app/views/page_builder/pages/edit.html.erb'
        template '_editor.html.erb', 'app/views/page_builder/pages/_editor.html.erb'
      end
      
      def create_model
        template 'page.rb', 'app/models/page.rb'
      end
      
      def create_routes
        route 'mount Rails::Page::Builder::Engine => "/page_builder"'
      end
      
      def create_initializer
        template 'rails_page_builder.rb', 'config/initializers/rails_page_builder.rb'
      end
      
      def show_instructions
        puts "\n" + "="*50
        puts "Rails Page Builder installed successfully!"
        puts "="*50
        puts "\nNext steps:"
        puts "1. Run: rails db:migrate"
        puts "2. Add to your application layout:"
        puts "   <%= page_builder_assets %>"
        puts "3. Visit /page_builder/pages to start building!"
        puts "\nFor Farsi support, set language in initializer:"
        puts "   config.default_language = :fa"
        puts "="*50 + "\n"
      end
    end
  end
end