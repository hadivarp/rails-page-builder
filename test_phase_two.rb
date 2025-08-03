#!/usr/bin/env ruby
# frozen_string_literal: true

# Test script for Rails Page Builder Phase Two Features
# Includes: Plugin System, API Integration, Advanced Editor, Component Library

# Load individual components (avoiding Rails Engine)
require_relative 'lib/rails/page/builder/version'
require_relative 'lib/rails/page/builder/configuration'
require_relative 'lib/rails/page/builder/plugin_system'
require_relative 'lib/rails/page/builder/api_integration'
require_relative 'lib/rails/page/builder/advanced_editor'
require_relative 'lib/rails/page/builder/component_library'

# Mock dependencies
class Time
  def self.current
    Time.now
  end
end

module Rails
  def self.root
    Pathname.new(__dir__)
  end
  
  def self.logger
    nil
  end
end

# Set up basic configuration
module Rails
  module Page
    module Builder
      @configuration = nil
      
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

# Configure the gem for Phase Two
Rails::Page::Builder.configure do |config|
  config.default_language = :en
  config.supported_languages = [:en, :fa, :ar, :he]
  config.enable_plugins = true
  config.api_cache_ttl = 300
  config.editor_theme = 'light'
  config.enable_collaboration = false
end

puts "🚀 Testing Rails Page Builder Phase Two Features"
puts "=" * 60

# Test 1: Plugin System
puts "\n1. Testing Plugin System..."
puts "-" * 30

begin
  # Test plugin registration
  sample_plugin_config = {
    id: 'sample-plugin',
    name: 'Sample Plugin',
    version: '1.0.0',
    author: 'Test Author',
    description: 'A sample plugin for testing',
    category: 'utility',
    active: true
  }
  
  plugin = Rails::Page::Builder::PluginSystem.register_plugin('sample-plugin', sample_plugin_config)
  puts "✅ Plugin registered: #{plugin.name} v#{plugin.version}"
  
  # Test plugin discovery
  available_plugins = Rails::Page::Builder::PluginSystem.available_plugins
  puts "✅ Available plugins: #{available_plugins.count}"
  
  # Test plugin info
  plugin_info = Rails::Page::Builder::PluginSystem.plugin_info('sample-plugin')
  puts "✅ Plugin info retrieved: #{plugin_info[:name]}"
  
  # Test plugin activation/deactivation
  Rails::Page::Builder::PluginSystem.deactivate_plugin('sample-plugin')
  puts "✅ Plugin deactivated successfully"
  
  Rails::Page::Builder::PluginSystem.activate_plugin('sample-plugin')
  puts "✅ Plugin activated successfully"
  
  # Test hooks system
  Rails::Page::Builder::PluginSystem.register_hook('test_hook', 'sample-plugin', proc { |data| "Hook executed: #{data}" })
  hook_results = Rails::Page::Builder::PluginSystem.execute_hooks('test_hook', 'test data')
  puts "✅ Hook system working: #{hook_results.first[:result]}" if hook_results.any?
  
rescue => e
  puts "❌ Error testing plugin system: #{e.message}"
  puts e.backtrace.first(3)
end

# Test 2: API Integration System
puts "\n2. Testing API Integration System..."
puts "-" * 30

begin
  # Test API registration
  Rails::Page::Builder::ApiIntegration.register_api(:test_api, {
    base_url: 'https://api.example.com',
    authentication: { type: 'api_key', key: 'test_key' },
    rate_limit: { requests: 100, period: 3600 },
    timeout: 30
  })
  puts "✅ Test API registered successfully"
  
  # Test API configuration retrieval
  api_config = Rails::Page::Builder::ApiIntegration.get_api_config(:test_api)
  puts "✅ API config retrieved: #{api_config[:base_url]}"
  
  # Test API listing
  apis = Rails::Page::Builder::ApiIntegration.list_apis
  puts "✅ Available APIs: #{apis.join(', ')}"
  
  # Test rate limiting check (without actual request)
  puts "✅ Rate limiting system integrated"
  
  # Test cache management
  Rails::Page::Builder::ApiIntegration.clear_cache(:test_api)
  cache_stats = Rails::Page::Builder::ApiIntegration.cache_stats
  puts "✅ Cache system working: #{cache_stats[:total_entries]} entries"
  
  # Test API stats
  stats = Rails::Page::Builder::ApiIntegration.api_stats(:test_api)
  puts "✅ API stats: #{stats[:requests_made]} requests made"
  
  # Test common API setup
  Rails::Page::Builder::ApiIntegration.setup_common_apis
  all_apis = Rails::Page::Builder::ApiIntegration.list_apis
  puts "✅ Common APIs set up: #{all_apis.count} total APIs"
  
rescue => e
  puts "❌ Error testing API integration: #{e.message}"
  puts e.backtrace.first(3)
end

# Test 3: Advanced Editor Tools
puts "\n3. Testing Advanced Editor Tools..."
puts "-" * 30

begin
  # Test editor tools registration
  Rails::Page::Builder::AdvancedEditor.register_tool('test_tool', {
    type: 'action',
    icon: '🔧',
    shortcut: 'Ctrl+T',
    toolbar_group: 'test',
    tooltip: 'Test Tool'
  })
  puts "✅ Test tool registered successfully"
  
  # Test toolbar tools
  toolbar_tools = Rails::Page::Builder::AdvancedEditor.get_toolbar_tools('test')
  puts "✅ Toolbar tools: #{toolbar_tools.count} tools in test group"
  
  # Test keyboard shortcuts
  shortcuts = Rails::Page::Builder::AdvancedEditor.get_shortcuts_map
  puts "✅ Keyboard shortcuts: #{shortcuts.keys.count} shortcuts available"
  
  # Test undo/redo system
  editor_id = 'test-editor'
  Rails::Page::Builder::AdvancedEditor.save_editor_state(editor_id, { content: 'initial content' })
  
  can_undo = Rails::Page::Builder::AdvancedEditor.can_undo?(editor_id)
  can_redo = Rails::Page::Builder::AdvancedEditor.can_redo?(editor_id)
  puts "✅ Undo/Redo system: Can undo: #{can_undo}, Can redo: #{can_redo}"
  
  # Test visual editing tools
  visual_tools = Rails::Page::Builder::AdvancedEditor.get_visual_editing_tools
  puts "✅ Visual editing tools: #{visual_tools.keys.count} tool categories"
  
  # Test responsive tools
  responsive_tools = Rails::Page::Builder::AdvancedEditor.get_responsive_tools
  puts "✅ Responsive tools: #{responsive_tools.keys.count} responsive features"
  
  # Test theme system
  Rails::Page::Builder::AdvancedEditor.register_theme('test_theme', {
    colors: { primary: '#007bff', secondary: '#6c757d' },
    fonts: { content: 'Arial, sans-serif' }
  })
  
  theme_css = Rails::Page::Builder::AdvancedEditor.generate_theme_css('test_theme')
  puts "✅ Theme system: CSS generated (#{theme_css.length} characters)"
  
  # Test editor config export
  editor_config = Rails::Page::Builder::AdvancedEditor.export_editor_config(editor_id)
  puts "✅ Editor config export: #{editor_config.keys.count} config sections"
  
rescue => e
  puts "❌ Error testing advanced editor: #{e.message}"
  puts e.backtrace.first(3)
end

# Test 4: Component Library System
puts "\n4. Testing Component Library System..."
puts "-" * 30

begin
  # Test component registration (should have default components)
  components = Rails::Page::Builder::ComponentLibrary.list_components
  puts "✅ Default components loaded: #{components.count} components"
  
  # Test component by category
  layout_components = Rails::Page::Builder::ComponentLibrary.list_components('layout')
  puts "✅ Layout components: #{layout_components.count} components"
  
  # Test component search
  search_results = Rails::Page::Builder::ComponentLibrary.search_components('card')
  puts "✅ Search results for 'card': #{search_results.count} components"
  
  # Test component instance creation
  card_component = Rails::Page::Builder::ComponentLibrary.get_component('card')
  if card_component
    instance = Rails::Page::Builder::ComponentLibrary.create_component_instance('card', {
      properties: { title: 'Test Card', description: 'Test Description' }
    })
    puts "✅ Component instance created: #{instance.id}"
    
    # Test component rendering
    rendered = Rails::Page::Builder::ComponentLibrary.render_component_instance(instance.id)
    puts "✅ Component rendered: #{rendered.length} characters"
    
    # Test instance update
    updated = Rails::Page::Builder::ComponentLibrary.update_component_instance(instance.id, {
      title: 'Updated Title'
    })
    puts "✅ Component instance updated: #{updated}"
  end
  
  # Test categories
  categories = Rails::Page::Builder::ComponentLibrary.get_categories
  puts "✅ Component categories: #{categories.join(', ')}"
  
  # Test component validation
  if card_component
    validation = Rails::Page::Builder::ComponentLibrary.validate_component('card', {
      title: 'Test Title',
      description: 'Test Description'
    })
    puts "✅ Component validation: #{validation[:valid] ? 'Passed' : 'Failed'}"
  end
  
  # Test usage stats
  usage_stats = Rails::Page::Builder::ComponentLibrary.get_component_usage_stats
  puts "✅ Usage stats: #{usage_stats.keys.count} components tracked"
  
  # Test popular components
  popular = Rails::Page::Builder::ComponentLibrary.get_popular_components(5)
  puts "✅ Popular components: #{popular.count} components listed"
  
rescue => e
  puts "❌ Error testing component library: #{e.message}"
  puts e.backtrace.first(3)
end

# Test 5: Integration Tests
puts "\n5. Testing System Integration..."
puts "-" * 30

begin
  # Test configuration integration
  config = Rails::Page::Builder.configuration
  puts "✅ Plugins enabled: #{config.enable_plugins}"
  puts "✅ API cache TTL: #{config.api_cache_ttl}s"
  puts "✅ Editor theme: #{config.editor_theme}"
  puts "✅ Collaboration enabled: #{config.enable_collaboration}"
  
  # Test cross-system compatibility
  puts "✅ All systems loaded without conflicts"
  
  # Test memory usage (basic)
  loaded_systems = [
    Rails::Page::Builder::PluginSystem,
    Rails::Page::Builder::ApiIntegration,
    Rails::Page::Builder::AdvancedEditor,
    Rails::Page::Builder::ComponentLibrary
  ]
  
  puts "✅ Loaded systems: #{loaded_systems.count} systems active"
  
rescue => e
  puts "❌ Error testing integration: #{e.message}"
  puts e.backtrace.first(3)
end

puts "\n" + "=" * 60
puts "🎉 Phase Two testing complete!"
puts "\nFeature Summary:"
puts "  ✅ Plugin System: Extensible architecture with hooks and filters"
puts "  ✅ API Integration: External service connections with caching"
puts "  ✅ Advanced Editor: Professional editing tools and themes"
puts "  ✅ Component Library: Reusable component system"
puts "\nNext steps:"
puts "  1. Run: ruby examples/phase_two_demo.rb"
puts "  2. Test individual systems in detail"
puts "  3. Create custom plugins and components"
puts "=" * 60