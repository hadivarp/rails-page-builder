#!/usr/bin/env ruby
# frozen_string_literal: true

# Asset management demo
require_relative '../lib/rails/page/builder'

puts "📁 Asset Management Demo"

# Mock Rails if not available
unless defined?(Rails)
  module Rails
    def self.root
      Pathname.new(__dir__).parent
    end
  end
end

# Configure
Rails::Page::Builder.configure do |config|
  config.max_file_size = 5.megabytes
  config.assets_path = File.join(__dir__, 'assets')
  config.thumbnails_path = File.join(__dir__, 'thumbnails') 
  config.metadata_path = File.join(__dir__, 'metadata')
end

# Create demo directories
['assets', 'thumbnails', 'metadata', 'output'].each do |dir|
  Dir.mkdir(File.join('examples', dir)) unless Dir.exist?(File.join('examples', dir))
end

puts "\n1. Testing Asset Categories..."
puts "-" * 30

categories = Rails::Page::Builder::AssetManager.get_asset_categories
puts "Available categories: #{categories.join(', ')}"

puts "\n2. Testing File Type Validation..."
puts "-" * 30

test_types = [
  'image/jpeg',
  'image/png', 
  'video/mp4',
  'application/pdf',
  'text/plain',
  'application/zip',
  'application/octet-stream' # Should not be allowed
]

test_types.each do |type|
  allowed = Rails::Page::Builder::AssetManager.send(:allowed_file_type?, type)
  status = allowed ? "✅" : "❌"
  puts "#{status} #{type}: #{allowed ? 'Allowed' : 'Not allowed'}"
end

puts "\n3. Testing Asset Listing..."
puts "-" * 30

assets = Rails::Page::Builder::AssetManager.list_assets
puts "Current assets: #{assets.count}"

if assets.empty?
  puts "No assets found (this is expected for a fresh installation)"
else
  assets.each do |asset|
    puts "  - #{asset[:original_filename]} (#{asset[:content_type]})"
  end
end

puts "\n4. Testing Mock File Upload..."
puts "-" * 30

# Create a mock file object for testing
class MockFile
  attr_reader :original_filename, :content_type, :size
  
  def initialize(filename, content_type, content = "Mock file content")
    @original_filename = filename
    @content_type = content_type
    @content = content
    @size = content.bytesize
  end
  
  def read
    @content
  end
  
  def respond_to?(method)
    [:read, :original_filename, :content_type, :size].include?(method) || super
  end
end

# Test uploading different types of mock files
test_files = [
  { name: 'test-image.jpg', type: 'image/jpeg' },
  { name: 'sample-document.pdf', type: 'application/pdf' },
  { name: 'video-file.mp4', type: 'video/mp4' }
]

uploaded_assets = []

test_files.each do |file_info|
  puts "Testing upload: #{file_info[:name]}"
  
  begin
    mock_file = MockFile.new(file_info[:name], file_info[:type])
    
    options = {
      title: "Test #{file_info[:name]}",
      alt_text: "Test image",
      description: "Mock file for testing",
      tags: ['test', 'demo']
    }
    
    asset_info = Rails::Page::Builder::AssetManager.upload_asset(mock_file, options)
    uploaded_assets << asset_info
    
    puts "✅ Uploaded successfully"
    puts "   ID: #{asset_info[:id]}"
    puts "   URL: #{asset_info[:url]}"
    puts "   Category: #{asset_info[:category]}"
    
  rescue => e
    puts "❌ Upload failed: #{e.message}"
  end
end

puts "\n5. Testing Asset Retrieval..."
puts "-" * 30

uploaded_assets.each do |asset|
  retrieved = Rails::Page::Builder::AssetManager.get_asset(asset[:id])
  
  if retrieved
    puts "✅ Retrieved asset: #{retrieved[:original_filename]}"
  else
    puts "❌ Failed to retrieve asset: #{asset[:id]}"
  end
end

puts "\n6. Testing Asset Search by Category..."
puts "-" * 30

categories.each do |category|
  assets_in_category = Rails::Page::Builder::AssetManager.list_assets(category: category)
  puts "#{category.capitalize}: #{assets_in_category.count} assets"
end

puts "\n7. Generating Asset Management Demo HTML..."
puts "-" * 30

demo_html = <<~HTML
  <!DOCTYPE html>
  <html lang="en">
  <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Asset Management Demo</title>
      <style>
          body {
              font-family: Arial, sans-serif;
              margin: 0;
              padding: 20px;
              background: #f5f5f5;
          }
          
          .container {
              max-width: 1200px;
              margin: 0 auto;
          }
          
          .asset-grid {
              display: grid;
              grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
              gap: 20px;
              margin-top: 20px;
          }
          
          .asset-card {
              background: white;
              border-radius: 12px;
              padding: 20px;
              box-shadow: 0 2px 10px rgba(0,0,0,0.1);
          }
          
          .asset-category {
              background: #007bff;
              color: white;
              padding: 4px 12px;
              border-radius: 20px;
              font-size: 0.8rem;
              display: inline-block;
              margin-bottom: 10px;
          }
          
          .stats-grid {
              display: grid;
              grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
              gap: 20px;
              margin-bottom: 30px;
          }
          
          .stat-card {
              background: white;
              padding: 20px;
              border-radius: 12px;
              text-align: center;
              box-shadow: 0 2px 10px rgba(0,0,0,0.1);
          }
          
          .stat-number {
              font-size: 2rem;
              font-weight: bold;
              color: #007bff;
          }
      </style>
  </head>
  <body>
      <div class="container">
          <h1>📁 Asset Management System Demo</h1>
          
          <div class="stats-grid">
              <div class="stat-card">
                  <div class="stat-number">#{Rails::Page::Builder::AssetManager.list_assets.count}</div>
                  <div>Total Assets</div>
              </div>
              <div class="stat-card">
                  <div class="stat-number">#{categories.count}</div>
                  <div>Categories</div>
              </div>
              <div class="stat-card">
                  <div class="stat-number">#{test_types.count { |type| Rails::Page::Builder::AssetManager.send(:allowed_file_type?, type) }}</div>
                  <div>Supported Types</div>
              </div>
          </div>
          
          <h2>📂 Asset Categories</h2>
          <div class="asset-grid">
HTML

categories.each do |category|
  assets_in_category = Rails::Page::Builder::AssetManager.list_assets(category: category)
  demo_html += <<~HTML
    <div class="asset-card">
        <div class="asset-category">#{category.capitalize}</div>
        <h3>#{category.capitalize} Files</h3>
        <p>#{assets_in_category.count} assets in this category</p>
        <small>Supported types: #{test_types.select { |type| Rails::Page::Builder::AssetManager.send(:determine_category, type) == category }.join(', ')}</small>
    </div>
  HTML
end

demo_html += <<~HTML
          </div>
          
          <h2>🔧 File Type Support</h2>
          <div class="asset-grid">
HTML

test_types.each do |type|
  allowed = Rails::Page::Builder::AssetManager.send(:allowed_file_type?, type)
  category = Rails::Page::Builder::AssetManager.send(:determine_category, type)
  
  demo_html += <<~HTML
    <div class="asset-card">
        <div class="asset-category" style="background: #{allowed ? '#28a745' : '#dc3545'}">
            #{allowed ? '✅ Allowed' : '❌ Not Allowed'}
        </div>
        <h3>#{type}</h3>
        <p>Category: #{category}</p>
    </div>
  HTML
end

demo_html += <<~HTML
          </div>
          
          <div style="margin-top: 40px; text-align: center; color: #6c757d;">
              <p>Generated by Rails Page Builder Asset Management System</p>
          </div>
      </div>
  </body>
  </html>
HTML

File.write('examples/output/asset_management_demo.html', demo_html)
puts "✅ Demo HTML generated: examples/output/asset_management_demo.html"

puts "\n🎉 Asset management demo complete!"
puts "Check examples/output/asset_management_demo.html to see the results"