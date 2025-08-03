# frozen_string_literal: true

require "rails/engine"

module Rails
  module Page
    module Builder
      class Engine < ::Rails::Engine
        isolate_namespace Rails::Page::Builder
        
        config.assets.precompile += %w[
          rails_page_builder.js
          rails_page_builder.css
          grapesjs/grapesjs.min.js
          grapesjs/grapesjs.min.css
        ]
        
        initializer "rails_page_builder.helpers" do |app|
          ActiveSupport.on_load(:action_view) do
            include Rails::Page::Builder::Helpers
          end
        end
        
        initializer "rails_page_builder.assets" do |app|
          app.config.assets.paths << File.expand_path("../../../vendor/assets", __dir__)
        end
      end
    end
  end
end