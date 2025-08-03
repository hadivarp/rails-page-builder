# frozen_string_literal: true

module Rails
  module Page
    module Builder
      module Helpers
        def page_builder_editor(options = {})
          default_options = {
            height: '100vh',
            language: Rails::Page::Builder.configuration.default_language,
            rtl: Rails::Page::Builder.configuration.rtl_language?(options[:language] || Rails::Page::Builder.configuration.default_language),
            storage_manager: true,
            block_manager: true,
            style_manager: true,
            layer_manager: true,
            trait_manager: true,
            device_manager: true,
            panels: true,
            commands: true,
            css_composer: true,
            selector_manager: true,
            code_manager: true
          }
          
          merged_options = default_options.merge(options)
          
          content_tag :div, '', 
            id: 'gjs',
            data: {
              'page-builder-options': merged_options.to_json
            },
            style: "height: #{merged_options[:height]}"
        end
        
        def page_builder_assets
          content_for :head do
            concat stylesheet_link_tag('grapesjs/grapesjs.min.css')
            concat stylesheet_link_tag('rails_page_builder.css')
          end
          
          content_for :javascript do
            concat javascript_include_tag('grapesjs/grapesjs.min.js')
            concat javascript_include_tag('rails_page_builder.js')
          end
        end
        
        def render_page_content(page_data, language = nil)
          return '' if page_data.blank?
          
          language ||= Rails::Page::Builder.configuration.default_language
          rtl = Rails::Page::Builder.configuration.rtl_language?(language)
          
          content_tag :div, 
            page_data.html_safe,
            class: "page-builder-content #{'rtl' if rtl}",
            dir: (rtl ? 'rtl' : 'ltr'),
            lang: language
        end
      end
    end
  end
end