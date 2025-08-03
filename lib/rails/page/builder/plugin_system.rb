# frozen_string_literal: true

require 'securerandom'
require 'json'
require 'fileutils'

module Rails
  module Page
    module Builder
      class PluginSystem
        class PluginError < StandardError; end
        class PluginLoadError < PluginError; end
        class PluginValidationError < PluginError; end

        class << self
          attr_accessor :loaded_plugins
          
          def initialize_system
            @loaded_plugins = {}
            @plugin_hooks = {}
            @plugin_filters = {}
            ensure_plugin_directories
          end

          # Plugin Registration
          def register_plugin(plugin_id, plugin_config = nil)
            # Support both single argument (config with id) and two arguments (id, config)
            if plugin_config.nil?
              plugin_config = plugin_id
              plugin_id = plugin_config[:id]
            else
              plugin_config = plugin_config.merge(id: plugin_id)
            end
            
            validate_plugin_config!(plugin_config)
            
            if @loaded_plugins[plugin_id]
              raise PluginError, "Plugin '#{plugin_id}' is already registered"
            end

            plugin = create_plugin_instance(plugin_config)
            @loaded_plugins[plugin_id] = plugin
            
            # Call plugin initialization hook
            plugin.on_activate if plugin.respond_to?(:on_activate)
            
            # Register plugin hooks and filters
            register_plugin_hooks(plugin)
            register_plugin_filters(plugin)
            
            plugin
          end

          def unregister_plugin(plugin_id)
            plugin = @loaded_plugins[plugin_id]
            return false unless plugin

            # Call deactivation hook
            plugin.on_deactivate if plugin.respond_to?(:on_deactivate)
            
            # Remove hooks and filters
            unregister_plugin_hooks(plugin_id)
            unregister_plugin_filters(plugin_id)
            
            @loaded_plugins.delete(plugin_id)
            true
          end

          # Plugin Loading
          def load_plugin_from_file(file_path)
            raise PluginLoadError, "Plugin file not found: #{file_path}" unless File.exist?(file_path)
            
            plugin_content = File.read(file_path)
            plugin_config = JSON.parse(plugin_content, symbolize_names: true)
            
            # Load plugin code if specified
            if plugin_config[:code_file]
              code_path = File.join(File.dirname(file_path), plugin_config[:code_file])
              load code_path if File.exist?(code_path)
            end
            
            register_plugin(plugin_config)
          end

          def load_plugins_from_directory(directory_path = nil)
            directory_path ||= plugins_directory
            return [] unless Dir.exist?(directory_path)

            loaded = []
            
            Dir.glob(File.join(directory_path, "*.json")).each do |plugin_file|
              begin
                plugin = load_plugin_from_file(plugin_file)
                loaded << plugin
              rescue => e
                Rails.logger&.error("Failed to load plugin #{plugin_file}: #{e.message}")
              end
            end
            
            loaded
          end

          # Plugin Discovery
          def available_plugins
            @loaded_plugins.values
          end

          def find_plugin(plugin_id)
            @loaded_plugins[plugin_id]
          end

          def plugins_by_category(category)
            @loaded_plugins.values.select { |plugin| plugin.category == category }
          end

          def active_plugins
            @loaded_plugins.values.select(&:active?)
          end

          # Hook System
          def register_hook(hook_name, plugin_id, callback)
            @plugin_hooks[hook_name] ||= []
            @plugin_hooks[hook_name] << { plugin_id: plugin_id, callback: callback }
          end

          def execute_hooks(hook_name, *args)
            return unless @plugin_hooks[hook_name]
            
            results = []
            @plugin_hooks[hook_name].each do |hook|
              begin
                result = hook[:callback].call(*args)
                results << { plugin_id: hook[:plugin_id], result: result }
              rescue => e
                Rails.logger&.error("Hook execution failed for #{hook[:plugin_id]}: #{e.message}")
              end
            end
            results
          end

          # Filter System
          def register_filter(filter_name, plugin_id, callback)
            @plugin_filters[filter_name] ||= []
            @plugin_filters[filter_name] << { plugin_id: plugin_id, callback: callback, priority: 10 }
          end

          def apply_filters(filter_name, value, *args)
            return value unless @plugin_filters[filter_name]
            
            # Sort by priority (lower numbers = higher priority)
            filters = @plugin_filters[filter_name].sort_by { |f| f[:priority] }
            
            filters.reduce(value) do |current_value, filter|
              begin
                filter[:callback].call(current_value, *args)
              rescue => e
                Rails.logger&.error("Filter execution failed for #{filter[:plugin_id]}: #{e.message}")
                current_value
              end
            end
          end

          # Plugin Management
          def activate_plugin(plugin_id)
            plugin = find_plugin(plugin_id)
            return false unless plugin

            plugin.activate!
            plugin.on_activate if plugin.respond_to?(:on_activate)
            true
          end

          def deactivate_plugin(plugin_id)
            plugin = find_plugin(plugin_id)
            return false unless plugin

            plugin.deactivate!
            plugin.on_deactivate if plugin.respond_to?(:on_deactivate)
            true
          end

          # Plugin Installation
          def install_plugin_from_package(package_path)
            # Extract and validate plugin package
            temp_dir = extract_plugin_package(package_path)
            
            begin
              manifest_path = File.join(temp_dir, 'plugin.json')
              raise PluginError, "Plugin manifest not found" unless File.exist?(manifest_path)
              
              plugin_config = JSON.parse(File.read(manifest_path), symbolize_names: true)
              validate_plugin_config!(plugin_config)
              
              # Install plugin files
              install_path = File.join(plugins_directory, plugin_config[:id])
              FileUtils.cp_r(temp_dir, install_path)
              
              # Load the installed plugin
              load_plugin_from_file(File.join(install_path, 'plugin.json'))
              
            ensure
              FileUtils.rm_rf(temp_dir) if Dir.exist?(temp_dir)
            end
          end

          def uninstall_plugin(plugin_id)
            # Unregister plugin first
            unregister_plugin(plugin_id)
            
            # Remove plugin files
            plugin_path = File.join(plugins_directory, plugin_id)
            FileUtils.rm_rf(plugin_path) if Dir.exist?(plugin_path)
            
            true
          end

          # Plugin Information
          def plugin_info(plugin_id)
            plugin = find_plugin(plugin_id)
            return nil unless plugin

            {
              id: plugin.id,
              name: plugin.name,
              version: plugin.version,
              description: plugin.description,
              author: plugin.author,
              category: plugin.category,
              active: plugin.active?,
              dependencies: plugin.dependencies,
              settings: plugin.settings
            }
          end

          def export_plugin_list
            @loaded_plugins.values.map { |plugin| plugin_info(plugin.id) }
          end

          private

          def create_plugin_instance(config)
            Plugin.new(config)
          end

          def validate_plugin_config!(config)
            required_fields = [:id, :name, :version, :author]
            missing_fields = required_fields.select { |field| config[field].nil? || config[field].to_s.strip.empty? }
            
            if missing_fields.any?
              raise PluginValidationError, "Missing required plugin fields: #{missing_fields.join(', ')}"
            end

            # Validate ID format
            unless config[:id].match?(/^[a-z0-9_-]+$/)
              raise PluginValidationError, "Plugin ID must contain only lowercase letters, numbers, hyphens, and underscores"
            end

            # Validate version format
            unless config[:version].match?(/^\d+\.\d+\.\d+$/)
              raise PluginValidationError, "Plugin version must be in semver format (e.g., 1.0.0)"
            end
          end

          def register_plugin_hooks(plugin)
            return unless plugin.respond_to?(:hooks)
            
            plugin.hooks.each do |hook_name, callback|
              register_hook(hook_name, plugin.id, callback)
            end
          end

          def register_plugin_filters(plugin)
            return unless plugin.respond_to?(:filters)
            
            plugin.filters.each do |filter_name, config|
              callback = config.is_a?(Hash) ? config[:callback] : config
              register_filter(filter_name, plugin.id, callback)
            end
          end

          def unregister_plugin_hooks(plugin_id)
            @plugin_hooks.each do |hook_name, hooks|
              @plugin_hooks[hook_name] = hooks.reject { |hook| hook[:plugin_id] == plugin_id }
            end
          end

          def unregister_plugin_filters(plugin_id)
            @plugin_filters.each do |filter_name, filters|
              @plugin_filters[filter_name] = filters.reject { |filter| filter[:plugin_id] == plugin_id }
            end
          end

          def ensure_plugin_directories
            [plugins_directory, temp_plugins_directory].each do |dir|
              FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
            end
          end

          def plugins_directory
            begin
              Rails::Page::Builder.configuration.plugins_path || 
                File.join(Dir.pwd, 'plugins')
            rescue
              File.join(Dir.pwd, 'plugins')
            end
          end

          def temp_plugins_directory
            File.join(plugins_directory, '.tmp')
          end

          def extract_plugin_package(package_path)
            temp_dir = File.join(temp_plugins_directory, SecureRandom.hex(8))
            
            # Simple extraction for zip files (in real implementation, use rubyzip)
            if package_path.end_with?('.zip')
              # Mock extraction - in real implementation use zip extraction
              FileUtils.mkdir_p(temp_dir)
            else
              raise PluginError, "Unsupported package format"
            end
            
            temp_dir
          end
        end

        # Initialize the system
        def self.included(base)
          initialize_system
        end

        # Plugin Class
        class Plugin
          attr_reader :id, :name, :version, :description, :author, :category, 
                      :dependencies, :settings, :config

          def initialize(config)
            @config = config
            @id = config[:id]
            @name = config[:name]
            @version = config[:version]
            @description = config[:description] || ''
            @author = config[:author]
            @category = config[:category] || 'general'
            @dependencies = config[:dependencies] || []
            @settings = config[:settings] || {}
            @active = config[:active].nil? ? true : config[:active]
            @hooks = {}
            @filters = {}
          end

          def active?
            @active
          end

          def activate!
            @active = true
          end

          def deactivate!
            @active = false
          end

          def add_hook(hook_name, &block)
            @hooks[hook_name] = block
          end

          def add_filter(filter_name, priority: 10, &block)
            @filters[filter_name] = { callback: block, priority: priority }
          end

          def hooks
            @hooks
          end

          def filters
            @filters
          end

          def get_setting(key, default = nil)
            @settings[key] || default
          end

          def set_setting(key, value)
            @settings[key] = value
          end

          def to_h
            {
              id: @id,
              name: @name,
              version: @version,
              description: @description,
              author: @author,
              category: @category,
              active: @active,
              dependencies: @dependencies,
              settings: @settings
            }
          end
        end
      end
    end
  end
end

# Initialize the plugin system
Rails::Page::Builder::PluginSystem.initialize_system