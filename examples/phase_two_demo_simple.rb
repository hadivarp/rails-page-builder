#!/usr/bin/env ruby
# frozen_string_literal: true

# Phase Two Demo - Advanced Features Showcase (Simple Version)

# Load systems individually (without complex component library)
require_relative '../lib/rails/page/builder/version'
require_relative '../lib/rails/page/builder/configuration'
require_relative '../lib/rails/page/builder/plugin_system'
require_relative '../lib/rails/page/builder/api_integration'
require_relative '../lib/rails/page/builder/advanced_editor'

# Mock Time.current
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

# Setup
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

puts "🎯 Rails Page Builder Phase Two Demo (Simple)"
puts "=" * 50

# Create demo directories
['examples/output', 'examples/plugins', 'examples/components'].each do |dir|
  Dir.mkdir(dir) unless Dir.exist?(dir)
end

# Configure
Rails::Page::Builder.configure do |config|
  config.enable_plugins = true
  config.editor_theme = 'dark'
  config.api_cache_ttl = 600
end

# Demo 1: Plugin System
puts "\n📦 Plugin System Demo"
puts "-" * 25

# Create a sample plugin
sample_plugin = {
  id: 'seo-optimizer',
  name: 'SEO Optimizer',
  version: '1.2.0',
  author: 'Page Builder Team',
  description: 'Automatically optimizes pages for search engines',
  category: 'seo',
  settings: {
    auto_generate_meta: true,
    optimize_images: true,
    minify_html: false
  }
}

plugin = Rails::Page::Builder::PluginSystem.register_plugin('seo-optimizer', sample_plugin)
puts "✅ Plugin registered: #{plugin.name}"

# Add hooks
Rails::Page::Builder::PluginSystem.register_hook('before_render', 'seo-optimizer', proc do |page_content|
  puts "🔍 SEO Optimizer: Analyzing page content..."
  "<!-- SEO optimized -->\n#{page_content}"
end)

# Test hook execution
result = Rails::Page::Builder::PluginSystem.execute_hooks('before_render', '<h1>My Page</h1>')
puts "✅ Hook executed: #{result.first[:result][0..50]}..."

# Demo 2: API Integration
puts "\n🌐 API Integration Demo"
puts "-" * 25

# Register a mock weather API
Rails::Page::Builder::ApiIntegration.register_api(:weather, {
  base_url: 'https://api.openweathermap.org/data/2.5',
  authentication: { type: 'api_key', key: 'demo_key' },
  rate_limit: { requests: 60, period: 3600 },
  cache_ttl: 1800
})

puts "✅ Weather API registered"

# Show API stats
weather_stats = Rails::Page::Builder::ApiIntegration.api_stats(:weather)
puts "✅ API stats: #{weather_stats[:requests_made]} requests made"

# Demo cache
Rails::Page::Builder::ApiIntegration.clear_cache
cache_stats = Rails::Page::Builder::ApiIntegration.cache_stats
puts "✅ Cache cleared: #{cache_stats[:total_entries]} entries"

# Demo 3: Advanced Editor Tools
puts "\n🎨 Advanced Editor Demo"
puts "-" * 25

# Create custom tool
Rails::Page::Builder::AdvancedEditor.register_tool('magic-wand', {
  type: 'action',
  icon: '🪄',
  shortcut: 'Ctrl+M',
  toolbar_group: 'magic',
  tooltip: 'Apply Magic Styling'
})

# Get all tools
magic_tools = Rails::Page::Builder::AdvancedEditor.get_toolbar_tools('magic')
puts "✅ Magic tools registered: #{magic_tools.count} tools"

# Test undo/redo system
editor_id = 'demo-editor'
Rails::Page::Builder::AdvancedEditor.save_editor_state(editor_id, { content: 'Original content' })

# Simulate edit
Rails::Page::Builder::AdvancedEditor.save_editor_state(editor_id, { content: 'Modified content' })

undo_result = Rails::Page::Builder::AdvancedEditor.undo(editor_id)
puts "✅ Undo successful: #{undo_result[:content]}" if undo_result

# Create custom theme
Rails::Page::Builder::AdvancedEditor.register_theme('neon', {
  colors: {
    toolbar_bg: '#0a0a0a',
    content_bg: '#1a1a2e',
    content_text: '#00ffff',
    primary: '#ff00ff'
  },
  css_variables: {
    'glow-effect': '0 0 10px #00ffff'
  }
})

neon_css = Rails::Page::Builder::AdvancedEditor.generate_theme_css('neon')
puts "✅ Neon theme created: #{neon_css.lines.count} CSS lines"

# Demo 4: Simple Component Rendering
puts "\n🧩 Component Rendering Demo"
puts "-" * 25

# Create simple component templates
components = {
  hero: {
    name: 'Hero Banner',
    template: '<section class="hero" style="{{background}}; padding: {{padding}};"><h1>{{title}}</h1><p>{{subtitle}}</p></section>',
    default_props: { title: 'Welcome', subtitle: 'Get started today', background: 'linear-gradient(135deg, #667eea, #764ba2)', padding: '100px 20px' }
  },
  card: {
    name: 'Simple Card',
    template: '<div class="card"><h3>{{title}}</h3><p>{{content}}</p></div>',
    default_props: { title: 'Card Title', content: 'Card content goes here.' }
  },
  button: {
    name: 'Action Button',
    template: '<button class="btn" style="background: {{color}};">{{text}}</button>',
    default_props: { text: 'Click Me', color: '#007bff' }
  }
}

# Simple template rendering function
def render_template(template, props)
  result = template.dup
  props.each { |key, value| result.gsub!("{{#{key}}}", value.to_s) }
  result
end

rendered_components = {}
components.each do |id, component|
  rendered = render_template(component[:template], component[:default_props])
  rendered_components[id] = rendered
  puts "✅ #{component[:name]} rendered: #{rendered.length} characters"
end

# Demo 5: Generate Complete Demo Page
puts "\n📄 Generating Demo Page"
puts "-" * 25

demo_html = <<~HTML
  <!DOCTYPE html>
  <html lang="en">
  <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Rails Page Builder - Phase Two Demo</title>
      <style>
          body {
              margin: 0;
              font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
              background: #f8f9fa;
          }
          
          #{neon_css}
          
          .demo-section {
              margin: 40px 0;
              padding: 20px;
              background: white;
              border-radius: 12px;
              box-shadow: 0 4px 6px rgba(0,0,0,0.1);
          }
          
          .feature-grid {
              display: grid;
              grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
              gap: 20px;
              margin: 20px 0;
          }
          
          .feature-card {
              padding: 20px;
              border: 1px solid #e9ecef;
              border-radius: 8px;
              text-align: center;
          }
          
          .feature-icon {
              font-size: 2rem;
              margin-bottom: 10px;
          }
          
          .hero {
              text-align: center;
              color: white;
              border-radius: 12px;
              margin-bottom: 20px;
          }
          
          .card {
              padding: 20px;
              border: 1px solid #ddd;
              border-radius: 8px;
              background: white;
              margin: 10px 0;
          }
          
          .btn {
              padding: 12px 24px;
              border: none;
              border-radius: 6px;
              color: white;
              cursor: pointer;
              font-size: 16px;
          }
      </style>
  </head>
  <body>
      <!-- Generated Hero Component -->
      #{rendered_components[:hero]}
      
      <div style="max-width: 1200px; margin: 0 auto; padding: 20px;">
          <div class="demo-section">
              <h2>🚀 Phase Two Features</h2>
              <div class="feature-grid">
                  <div class="feature-card">
                      <div class="feature-icon">📦</div>
                      <h3>Plugin System</h3>
                      <p>Extensible architecture with #{Rails::Page::Builder::PluginSystem.available_plugins.count} plugins loaded</p>
                  </div>
                  
                  <div class="feature-card">
                      <div class="feature-icon">🌐</div>
                      <h3>API Integration</h3>
                      <p>Connected to #{Rails::Page::Builder::ApiIntegration.list_apis.count} external services</p>
                  </div>
                  
                  <div class="feature-card">
                      <div class="feature-icon">🎨</div>
                      <h3>Advanced Editor</h3>
                      <p>Professional editing with #{Rails::Page::Builder::AdvancedEditor.get_shortcuts_map.count} keyboard shortcuts</p>
                  </div>
                  
                  <div class="feature-card">
                      <div class="feature-icon">🧩</div>
                      <h3>Component System</h3>
                      <p>#{components.count} demo components rendered</p>
                  </div>
              </div>
          </div>
          
          <div class="demo-section">
              <h2>📊 System Statistics</h2>
              <ul>
                  <li><strong>Plugins:</strong> #{Rails::Page::Builder::PluginSystem.available_plugins.count} registered</li>
                  <li><strong>APIs:</strong> #{Rails::Page::Builder::ApiIntegration.active_apis.count} active</li>
                  <li><strong>Editor Tools:</strong> #{Rails::Page::Builder::AdvancedEditor.get_toolbar_tools.count} available</li>
                  <li><strong>Components:</strong> #{components.count} demo components</li>
                  <li><strong>Cache Entries:</strong> #{Rails::Page::Builder::ApiIntegration.cache_stats[:total_entries]}</li>
              </ul>
          </div>
          
          <div class="demo-section">
              <h2>🎯 Component Showcase</h2>
              <div style="margin: 20px 0;">
                  <h4>Sample Card Component</h4>
                  #{rendered_components[:card]}
              </div>
              
              <div style="margin: 20px 0;">
                  <h4>Action Button Component</h4>
                  #{rendered_components[:button]}
              </div>
          </div>
          
          <div class="demo-section" style="text-align: center; background: linear-gradient(135deg, #667eea, #764ba2); color: white;">
              <h2>🎉 Phase Two Complete!</h2>
              <p>Rails Page Builder now includes advanced plugin system, API integrations, professional editor tools, and component rendering capabilities.</p>
              <p><strong>Total Features:</strong> 4 major systems • 20+ tools • Multiple integrations</p>
          </div>
      </div>
      
      <script>
          console.log('🚀 Rails Page Builder Phase Two Demo Loaded');
          console.log('Features: Plugin System, API Integration, Advanced Editor, Component Rendering');
          
          // Add some interactivity
          document.querySelectorAll('.btn').forEach(btn => {
              btn.addEventListener('click', () => {
                  alert('Component interaction working! 🎉');
              });
          });
      </script>
  </body>
  </html>
HTML

# Write demo file
File.write('examples/output/phase_two_demo.html', demo_html)
puts "✅ Demo page generated: examples/output/phase_two_demo.html"

# Generate plugin example
plugin_example = {
  plugin: {
    id: 'example-plugin',
    name: 'Example Plugin',
    version: '1.0.0',
    author: 'Your Name',
    description: 'An example plugin showing the structure',
    category: 'utility'
  },
  hooks: {
    before_render: "Apply transformations before rendering",
    after_save: "Clean up after saving"
  },
  filters: {
    content_filter: "Modify content as it flows through the system"
  }
}

File.write('examples/plugins/example-plugin.json', JSON.pretty_generate(plugin_example))
puts "✅ Plugin example: examples/plugins/example-plugin.json"

# Generate component example
component_example = {
  component: {
    id: 'custom-alert',
    name: 'Custom Alert',
    description: 'A customizable alert component',
    category: 'ui_elements',
    template: '<div class="alert alert-{{type}}">{{message}}</div>',
    properties: {
      message: { type: 'string', default: 'Alert message' },
      type: { type: 'string', default: 'info', options: ['info', 'warning', 'error', 'success'] }
    },
    css: '.alert { padding: 1rem; border-radius: 4px; margin: 1rem 0; }'
  }
}

File.write('examples/components/custom-alert.json', JSON.pretty_generate(component_example))
puts "✅ Component example: examples/components/custom-alert.json"

puts "\n" + "=" * 50
puts "🎉 Phase Two Demo Complete!"
puts "\n📁 Generated Files:"
puts "  • examples/output/phase_two_demo.html - Complete demo page"
puts "  • examples/plugins/example-plugin.json - Plugin example"
puts "  • examples/components/custom-alert.json - Component example"
puts "\n🌐 Open the demo page in your browser to see all features in action!"
puts "=" * 50