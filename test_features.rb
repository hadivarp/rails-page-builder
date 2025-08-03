#!/usr/bin/env ruby
# frozen_string_literal: true

# Test script for Rails Page Builder new features
# Run with: ruby test_features.rb

require_relative 'lib/rails/page/builder'

# Configure the gem
Rails::Page::Builder.configure do |config|
  config.default_language = :en
  config.supported_languages = [:en, :fa, :ar, :he]
  config.max_file_size = 10.megabytes
end

puts "🚀 Testing Rails Page Builder Advanced Features"
puts "=" * 50

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
  
rescue => e
  puts "❌ Error testing RTL support: #{e.message}"
end

# Test 4: Asset Management
puts "\n4. Testing Asset Management..."
puts "-" * 30

begin
  # Test asset categories
  categories = Rails::Page::Builder::AssetManager.get_asset_categories
  puts "✅ Asset categories: #{categories.join(', ')}"
  
  # Test asset listing (will be empty initially)
  assets = Rails::Page::Builder::AssetManager.list_assets
  puts "✅ Current assets: #{assets.count} assets"
  
  # Test file type validation
  allowed_types = ['image/jpeg', 'image/png', 'video/mp4', 'application/pdf']
  allowed_types.each do |type|
    is_allowed = Rails::Page::Builder::AssetManager.send(:allowed_file_type?, type)
    puts "✅ #{type} allowed: #{is_allowed}"
  end
  
rescue => e
  puts "❌ Error testing asset management: #{e.message}"
end

# Test 5: Template Manager
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
end

puts "\n" + "=" * 50
puts "🎉 Feature testing complete!"
puts "=" * 50