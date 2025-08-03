#!/usr/bin/env ruby
# frozen_string_literal: true

# Template demo - shows how to use the template system
require_relative '../lib/rails/page/builder'

puts "📄 Template System Demo"

# Configure
Rails::Page::Builder.configure do |config|
  config.supported_languages = [:en, :fa, :ar, :he]
  config.template_storage_path = File.join(__dir__, 'templates')
  config.template_versioning = true
end

# Create examples directory
Dir.mkdir('examples') unless Dir.exist?('examples')
Dir.mkdir('examples/templates') unless Dir.exist?('examples/templates')
Dir.mkdir('examples/output') unless Dir.exist?('examples/output')

puts "\n1. Testing Template Loading..."
puts "-" * 30

# Test loading built-in templates
templates = Rails::Page::Builder::TemplateSystem.all_templates(:en)
puts "Built-in templates: #{templates.count}"

templates.each do |template|
  puts "  - #{template[:name]} (#{template[:id]})"
end

puts "\n2. Testing Template Preview..."
puts "-" * 30

# Generate preview for landing page template
landing_template = Rails::Page::Builder::TemplateSystem.find_template('landing-page', :en)
if landing_template
  preview_html = <<~HTML
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>#{landing_template[:name]} - Preview</title>
        <style>
            #{landing_template[:css]}
        </style>
    </head>
    <body>
        #{landing_template[:content]}
    </body>
    </html>
  HTML
  
  File.write('examples/output/landing_page_preview.html', preview_html)
  puts "✅ Landing page preview generated: examples/output/landing_page_preview.html"
end

puts "\n3. Testing Custom Template Creation..."
puts "-" * 30

# Create a custom template
custom_template_data = {
  id: 'custom-test-template',
  name: 'My Custom Template',
  description: 'A test custom template',
  category: 'Custom',
  tags: ['test', 'demo'],
  author: 'Test User'
}

# Mock page object for testing
class MockPage
  attr_accessor :content, :css, :language, :title, :slug
  
  def initialize
    @content = '<div style="padding: 40px; text-align: center; background: linear-gradient(135deg, #667eea, #764ba2); color: white;"><h1>Custom Template</h1><p>This is a custom template for testing.</p></div>'
    @css = 'body { margin: 0; font-family: Arial, sans-serif; }'
    @language = 'en'
    @title = 'Custom Test Page'
    @slug = 'custom-test'
  end
  
  def rtl?
    false
  end
  
  def created_at
    Time.now
  end
end

mock_page = MockPage.new
result = Rails::Page::Builder::TemplateManager.save_custom_template(mock_page, custom_template_data)

if result[:success]
  puts "✅ Custom template saved successfully"
  puts "   Template ID: #{result[:template][:id]}"
  puts "   Template Name: #{result[:template][:name]}"
  
  # Generate preview for custom template
  custom_preview_html = <<~HTML
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>#{result[:template][:name]} - Preview</title>
        <style>
            #{result[:template][:css]}
        </style>
    </head>
    <body>
        #{result[:template][:content]}
        <div style="position: fixed; top: 10px; right: 10px; background: rgba(0,0,0,0.8); color: white; padding: 10px; border-radius: 5px; font-size: 12px;">
            Custom Template: #{result[:template][:name]}
        </div>
    </body>
    </html>
  HTML
  
  File.write('examples/output/custom_template_preview.html', custom_preview_html)
  puts "✅ Custom template preview: examples/output/custom_template_preview.html"
else
  puts "❌ Failed to save custom template: #{result[:errors].join(', ')}"
end

puts "\n4. Testing Template Search..."
puts "-" * 30

# Test search functionality
search_terms = ['business', 'landing', 'portfolio']
search_terms.each do |term|
  results = Rails::Page::Builder::TemplateManager.search_templates(term, :en)
  puts "Search '#{term}': #{results.count} results"
  results.each do |template|
    puts "  - #{template[:name]}"
  end
end

puts "\n5. Testing Multi-language Templates..."
puts "-" * 30

# Test templates in different languages
[:fa, :ar, :he].each do |lang|
  templates = Rails::Page::Builder::TemplateSystem.all_templates(lang)
  business_template = templates.find { |t| t[:id] == 'business' }
  
  if business_template
    puts "✅ #{lang.upcase} business template: #{business_template[:name]}"
    
    # Generate preview
    preview_html = <<~HTML
      <!DOCTYPE html>
      <html lang="#{lang}" dir="#{business_template[:rtl] ? 'rtl' : 'ltr'}">
      <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>#{business_template[:name]} - #{lang.upcase}</title>
          <style>
              #{business_template[:css]}
          </style>
      </head>
      <body>
          #{business_template[:content]}
      </body>
      </html>
    HTML
    
    File.write("examples/output/business_template_#{lang}.html", preview_html)
    puts "   Preview: examples/output/business_template_#{lang}.html"
  end
end

puts "\n🎉 Template demo complete!"
puts "Check examples/output/ for generated HTML previews"