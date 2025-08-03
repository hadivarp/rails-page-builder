# frozen_string_literal: true

require_relative "builder/version"
require_relative "builder/engine"
require_relative "builder/configuration"
require_relative "builder/helpers"
require_relative "builder/block_library"
require_relative "builder/template_system"
require_relative "builder/template_manager"
require_relative "builder/asset_manager"
require_relative "builder/plugin_system"
require_relative "builder/api_integration"
require_relative "builder/advanced_editor"
require_relative "builder/component_library"
require_relative "builder/collaboration"
require_relative "builder/websocket_manager"
require_relative "builder/security"
require_relative "builder/permissions"
require_relative "builder/performance"
require_relative "builder/analytics"
require_relative "builder/reporting"

module Rails
  module Page
    module Builder
      class Error < StandardError; end
      
      class << self
        def configuration
          @configuration ||= Configuration.new
        end
        
        def configure
          yield(configuration)
        end
      end
    end
  end
end
