# frozen_string_literal: true

module Rails
  module Page
    module Builder
      class Configuration
        attr_accessor :default_language, :supported_languages, :storage_adapter, :custom_blocks,
                      :max_file_size, :assets_path, :thumbnails_path, :metadata_path, :asset_host,
                      :template_storage_path, :auto_save_templates, :template_versioning,
                      :plugins_path, :enable_plugins, :api_cache_ttl, :api_rate_limiting,
                      :editor_theme, :enable_collaboration, :component_library_path
        
        def initialize
          @default_language = :en
          @supported_languages = [:en, :fa, :ar, :he]
          @storage_adapter = :active_record
          @custom_blocks = []
          @max_file_size = 10 * 1024 * 1024 # 10MB
          @assets_path = nil
          @thumbnails_path = nil
          @metadata_path = nil
          @asset_host = nil
          @template_storage_path = nil
          @auto_save_templates = true
          @template_versioning = true
          @plugins_path = nil
          @enable_plugins = true
          @api_cache_ttl = 300
          @api_rate_limiting = true
          @editor_theme = 'light'
          @enable_collaboration = false
          @component_library_path = nil
        end
        
        def rtl_language?(language)
          [:fa, :ar, :he].include?(language.to_sym)
        end
      end
    end
  end
end