#!/usr/bin/env ruby
# frozen_string_literal: true

# Simple test script for Rails Page Builder new features (without Rails Engine)

# Load individual components instead of the main module
require_relative 'lib/rails/page/builder/version'
require_relative 'lib/rails/page/builder/configuration'
require_relative 'lib/rails/page/builder/block_contents'
require_relative 'lib/rails/page/builder/block_library'
require_relative 'lib/rails/page/builder/template_system'
require_relative 'lib/rails/page/builder/template_manager'
require_relative 'lib/rails/page/builder/asset_manager'

# Mock Time.current for compatibility
class Time
  def self.current
    Time.now
  end
end

# Mock Rails.root for asset manager
module Rails
  def self.root
    Pathname.new(__dir__)
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

# Configure the gem
Rails::Page::Builder.configure do |config|
  config.default_language = :en
  config.supported_languages = [:en, :fa, :ar, :he]
  config.max_file_size = 10 * 1024 * 1024 # 10MB
end

puts "🚀 Testing Rails Page Builder Advanced Features (Simple Mode)"
puts "=" * 60

# Test 1: Advanced Block Library
puts "\n1. Testing Advanced Block Library..."
puts "-" * 30

begin
  # Test all blocks in English
  all_blocks_en = Rails::Page::Builder::BlockLibrary.all_blocks(:en)
  puts "✅ English blocks loaded: #{all_blocks_en.count} blocks"
  
  # Test advanced blocks specifically
  advanced_blocks = Rails::Page::Builder::BlockLibrary.advanced_blocks(:en)
  puts "✅ Advanced blocks: #{advanced_blocks.count} blocks"
  advanced_blocks.each do |block|
    puts "   - #{block[:label]} (#{block[:id]})"
  end
  
  # Test blocks in different languages
  [:fa, :ar, :he].each do |lang|
    blocks = Rails::Page::Builder::BlockLibrary.all_blocks(lang)
    puts "✅ #{lang.upcase} blocks: #{blocks.count} blocks"
  end
  
rescue => e
  puts "❌ Error testing blocks: #{e.message}"
  puts e.backtrace.first(3)
end

# Test 2: Template System
puts "\n2. Testing Template System..."
puts "-" * 30

begin
  # Test template loading
  templates_en = Rails::Page::Builder::TemplateSystem.all_templates(:en)
  puts "✅ English templates: #{templates_en.count} templates"
  
  templates_en.each do |template|
    puts "   - #{template[:name]} (#{template[:category]})"
  end
  
  # Test template in Arabic
  templates_ar = Rails::Page::Builder::TemplateSystem.all_templates(:ar)
  puts "✅ Arabic templates: #{templates_ar.count} templates"
  
  # Test finding specific template
  landing_template = Rails::Page::Builder::TemplateSystem.find_template('landing-page', :en)
  if landing_template
    puts "✅ Landing page template found: #{landing_template[:name]}"
  else
    puts "❌ Landing page template not found"
  end
  
rescue => e
  puts "❌ Error testing templates: #{e.message}"
  puts e.backtrace.first(3)
end

# Test 3: RTL Language Support
puts "\n3. Testing RTL Language Support..."
puts "-" * 30

begin
  # Test RTL detection
  rtl_languages = [:fa, :ar, :he]
  ltr_languages = [:en]
  
  rtl_languages.each do |lang|
    config = Rails::Page::Builder.configuration
    is_rtl = config.rtl_language?(lang)
    puts "✅ #{lang.upcase} is RTL: #{is_rtl}"
  end
  
  ltr_languages.each do |lang|
    config = Rails::Page::Builder.configuration
    is_rtl = config.rtl_language?(lang)
    puts "✅ #{lang.upcase} is RTL: #{is_rtl}"
  end
  
  # Test block content with RTL
  text_block_ar = Rails::Page::Builder::BlockLibrary.send(:text_block_content, :ar)
  puts "✅ Arabic text block generated (#{text_block_ar.length} chars)"
  
  # Test if content contains RTL attributes
  if text_block_ar.include?('direction: rtl')
    puts "✅ RTL direction attribute found"
  else
    puts "❌ RTL direction attribute missing"
  end
  
rescue => e
  puts "❌ Error testing RTL support: #{e.message}"
  puts e.backtrace.first(3)
end

# Test 4: Asset Management (basic functionality)
puts "\n4. Testing Asset Management..."
puts "-" * 30

begin
  # Test asset categories
  categories = Rails::Page::Builder::AssetManager.get_asset_categories
  puts "✅ Asset categories: #{categories.join(', ')}"
  
  # Test file type validation
  test_types = ['image/jpeg', 'image/png', 'video/mp4', 'application/pdf', 'application/exe']
  test_types.each do |type|
    is_allowed = Rails::Page::Builder::AssetManager.send(:allowed_file_type?, type)
    status = is_allowed ? "✅" : "❌"
    puts "#{status} #{type}: #{is_allowed ? 'Allowed' : 'Not allowed'}"
  end
  
  # Test category determination
  puts "✅ Category determination:"
  test_types.each do |type|
    category = Rails::Page::Builder::AssetManager.send(:determine_category, type)
    puts "   #{type} -> #{category}"
  end
  
rescue => e
  puts "❌ Error testing asset management: #{e.message}"
  puts e.backtrace.first(3)
end

# Test 5: Template Manager (basic functionality)
puts "\n5. Testing Template Manager..."
puts "-" * 30

begin
  # Test template categories
  categories = Rails::Page::Builder::TemplateManager.template_categories(:en)
  puts "✅ Template categories: #{categories.join(', ')}"
  
  # Test template search
  search_results = Rails::Page::Builder::TemplateManager.search_templates('business', :en)
  puts "✅ Search 'business': #{search_results.count} results"
  
  # Test template validation
  sample_template = {
    id: 'test-template',
    name: 'Test Template',
    content: '<div>Hello World</div>',
    language: :en
  }
  
  errors = Rails::Page::Builder::TemplateManager.validate_template(sample_template)
  if errors.empty?
    puts "✅ Template validation passed"
  else
    puts "❌ Template validation failed: #{errors.join(', ')}"
  end
  
rescue => e
  puts "❌ Error testing template manager: #{e.message}"
  puts e.backtrace.first(3)
end

# Test 6: Sample Block Content Generation
puts "\n6. Testing Block Content Generation..."
puts "-" * 30

begin
  # Test generating some advanced block content
  test_blocks = [
    { method: :accordion_content, name: 'Accordion' },
    { method: :tabs_content, name: 'Tabs' },
    { method: :carousel_content, name: 'Carousel' },
    { method: :modal_content, name: 'Modal' }
  ]
  
  test_blocks.each do |block_info|
    content = Rails::Page::Builder::BlockLibrary.send(block_info[:method], :en)
    if content && content.length > 0
      puts "✅ #{block_info[:name]} content generated (#{content.length} chars)"
    else
      puts "❌ #{block_info[:name]} content generation failed"
    end
  end
  
rescue => e
  puts "❌ Error testing block content: #{e.message}"
  puts e.backtrace.first(3)
end

puts "\n" + "=" * 60
puts "🎉 Simple feature testing complete!"
puts "\nNext steps:"
puts "1. Run: ruby examples/block_showcase.rb"
puts "2. Run: ruby examples/template_demo.rb" 
puts "3. Run: ruby examples/asset_demo.rb"
puts "4. Open generated HTML files in examples/output/"
puts "=" * 60