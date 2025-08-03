#!/usr/bin/env ruby
require 'sinatra'
require 'json'

# Load only the core components without Rails dependencies
require_relative 'lib/rails/page/builder/version'
require_relative 'lib/rails/page/builder/configuration'
require_relative 'lib/rails/page/builder/block_library'

# Configure Sinatra
set :port, 4567
set :bind, '0.0.0.0'
set :public_folder, File.join(__dir__, 'examples/output')

# Mock Rails for the demo
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

# Setup Rails Page Builder (minimal)
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
  config.default_language = :fa
  config.supported_languages = [:fa, :ar, :he, :en]
end

puts "🚀 Rails Page Builder Demo Server"
puts "Starting on http://localhost:4567"
puts "=================================="

# Routes
get '/' do
  redirect '/dashboard'
end

get '/dashboard' do
  send_file File.join(settings.public_folder, 'unified_dashboard.html')
end

get '/dashboard/:lang' do
  lang = params[:lang]
  file_path = File.join(settings.public_folder, "unified_dashboard_#{lang}.html")
  
  if File.exist?(file_path)
    send_file file_path
  else
    redirect '/dashboard'
  end
end

get '/blocks/:lang' do
  content_type :json
  lang = params[:lang].to_sym
  blocks = Rails::Page::Builder::BlockLibrary.all_blocks(lang)
  blocks.to_json
end

get '/api/stats' do
  content_type :json
  blocks = Rails::Page::Builder::BlockLibrary.all_blocks
  {
    blocks: blocks.count,
    categories: blocks.group_by { |b| b[:category] }.count,
    languages: 4,
    status: 'active'
  }.to_json
end

post '/api/render_block' do
  content_type :json
  data = JSON.parse(request.body.read)
  
  block_id = data['block_id']
  language = data['language']&.to_sym || :en
  
  blocks = Rails::Page::Builder::BlockLibrary.all_blocks(language)
  block = blocks.find { |b| b[:id] == block_id }
  
  if block
    { success: true, html: block[:content] }.to_json
  else
    { success: false, error: 'Block not found' }.to_json
  end
end

get '/interactive' do
  erb :interactive
end

get '/showcase/:lang' do
  lang = params[:lang]
  file_path = File.join(settings.public_folder, "block_showcase_#{lang}.html")
  
  if File.exist?(file_path)
    send_file file_path
  else
    "Showcase for #{lang} not found"
  end
end

# Interactive page builder view
__END__

@@interactive
<!DOCTYPE html>
<html dir="rtl">
<head>
    <meta charset="UTF-8">
    <title>Rails Page Builder - Interactive Demo</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: 'Arial', sans-serif; 
            background: linear-gradient(135deg, #667eea, #764ba2);
            direction: rtl;
            min-height: 100vh;
        }
        .header {
            background: rgba(255,255,255,0.1);
            color: white;
            padding: 15px 20px;
            backdrop-filter: blur(10px);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .nav-links a {
            color: white;
            text-decoration: none;
            margin: 0 10px;
            padding: 8px 15px;
            border-radius: 6px;
            transition: background 0.3s;
        }
        .nav-links a:hover {
            background: rgba(255,255,255,0.2);
        }
        .container { 
            display: flex; 
            height: calc(100vh - 70px);
            gap: 0;
        }
        .sidebar { 
            width: 320px; 
            background: rgba(255,255,255,0.95); 
            padding: 20px;
            overflow-y: auto;
            backdrop-filter: blur(10px);
        }
        .canvas-area { 
            flex: 1; 
            padding: 20px; 
            background: rgba(255,255,255,0.9);
            overflow-y: auto;
            backdrop-filter: blur(10px);
        }
        .block-item {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            margin: 8px 0;
            padding: 12px 15px;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s;
            border: 2px solid transparent;
        }
        .block-item:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            border-color: rgba(255,255,255,0.3);
        }
        .category-title {
            color: #2d3748;
            margin: 15px 0 8px 0;
            font-weight: bold;
            font-size: 14px;
            text-transform: uppercase;
            border-bottom: 2px solid #e2e8f0;
            padding-bottom: 5px;
        }
        .drop-zone {
            min-height: 300px;
            border: 3px dashed #cbd5e0;
            border-radius: 12px;
            padding: 30px;
            text-align: center;
            margin: 15px 0;
            background: white;
            transition: all 0.3s;
        }
        .drop-zone.drag-over {
            border-color: #667eea;
            background: #f0f8ff;
        }
        .page-element {
            margin: 15px 0;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            background: white;
            position: relative;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }
        .element-controls {
            position: absolute;
            top: -15px;
            right: 10px;
            background: #667eea;
            color: white;
            padding: 5px 10px;
            border-radius: 15px;
            font-size: 12px;
            opacity: 0;
            transition: opacity 0.3s;
        }
        .page-element:hover .element-controls {
            opacity: 1;
        }
        .stats-bar {
            background: rgba(255,255,255,0.1);
            color: white;
            padding: 10px 20px;
            margin-top: 20px;
            border-radius: 8px;
            text-align: center;
            backdrop-filter: blur(10px);
        }
        .language-switcher {
            background: rgba(255,255,255,0.1);
            border-radius: 8px;
            padding: 5px;
        }
        .language-switcher a {
            display: inline-block;
            padding: 5px 10px;
            margin: 0 2px;
            border-radius: 4px;
            color: white;
            text-decoration: none;
            transition: background 0.3s;
        }
        .language-switcher a:hover,
        .language-switcher a.active {
            background: rgba(255,255,255,0.2);
        }
    </style>
</head>
<body>
    <div class="header">
        <div>
            <h2>🏗️ Rails Page Builder</h2>
            <small>Interactive Demo - RTL First Design</small>
        </div>
        <div class="nav-links">
            <a href="/dashboard">📊 Dashboard</a>
            <a href="/showcase/fa">🎨 Showcase</a>
            <div class="language-switcher">
                <a href="#" onclick="switchLanguage('fa')" class="active" id="lang-fa">فا</a>
                <a href="#" onclick="switchLanguage('ar')" id="lang-ar">ع</a>
                <a href="#" onclick="switchLanguage('he')" id="lang-he">ע</a>
                <a href="#" onclick="switchLanguage('en')" id="lang-en">EN</a>
            </div>
        </div>
    </div>
    
    <div class="container">
        <div class="sidebar">
            <h3 style="margin-bottom: 15px; color: #2d3748;">📦 Block Library</h3>
            <p style="color: #718096; font-size: 14px; margin-bottom: 15px;">Drag blocks to the canvas</p>
            
            <div id="blocks-container">
                <div class="category-title">⏳ Loading blocks...</div>
            </div>
        </div>
        
        <div class="canvas-area">
            <h2 style="color: #2d3748; margin-bottom: 15px;">🎨 Page Canvas</h2>
            
            <div class="drop-zone" id="canvas">
                <h3 style="color: #718096;">Drop blocks here to build your page</h3>
                <p style="color: #a0aec0; margin-top: 10px;">Click and drag any block from the sidebar</p>
            </div>
            
            <div style="margin-top: 20px;">
                <button onclick="clearCanvas()" style="background: #e53e3e; color: white; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer;">🗑️ Clear Canvas</button>
                <button onclick="exportPage()" style="background: #38a169; color: white; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; margin-right: 10px;">💾 Export HTML</button>
            </div>
            
            <div class="stats-bar">
                <span id="stats">📊 Loading statistics...</span>
            </div>
        </div>
    </div>
    
    <script>
        let currentLanguage = 'fa';
        let pageElements = [];
        
        // Switch language
        function switchLanguage(lang) {
            currentLanguage = lang;
            
            // Update active state
            document.querySelectorAll('.language-switcher a').forEach(a => a.classList.remove('active'));
            document.getElementById('lang-' + lang).classList.add('active');
            
            // Reload blocks
            loadBlocks();
        }
        
        // Load blocks
        function loadBlocks() {
            fetch('/blocks/' + currentLanguage)
                .then(r => r.json())
                .then(blocks => {
                    const container = document.getElementById('blocks-container');
                    container.innerHTML = '';
                    
                    // Group by category
                    const categories = {};
                    blocks.forEach(block => {
                        const cat = block.category;
                        if (!categories[cat]) categories[cat] = [];
                        categories[cat].push(block);
                    });
                    
                    // Render categories
                    Object.entries(categories).forEach(([category, categoryBlocks]) => {
                        const title = document.createElement('div');
                        title.className = 'category-title';
                        title.textContent = `${category} (${categoryBlocks.length})`;
                        container.appendChild(title);
                        
                        categoryBlocks.forEach(block => {
                            const item = document.createElement('div');
                            item.className = 'block-item';
                            item.innerHTML = `${block.icon} ${block.label}`;
                            item.draggable = true;
                            item.dataset.blockId = block.id;
                            
                            item.addEventListener('dragstart', (e) => {
                                e.dataTransfer.setData('text/plain', block.id);
                                e.dataTransfer.setData('text/label', block.label);
                                e.dataTransfer.setData('text/icon', block.icon);
                            });
                            
                            container.appendChild(item);
                        });
                    });
                })
                .catch(err => {
                    document.getElementById('blocks-container').innerHTML = 
                        '<div class="category-title">❌ Error loading blocks</div>';
                });
        }
        
        // Load stats
        function loadStats() {
            fetch('/api/stats')
                .then(r => r.json())
                .then(stats => {
                    document.getElementById('stats').innerHTML = 
                        `📦 ${stats.blocks} blocks • 🗂️ ${stats.categories} categories • 🌍 ${stats.languages} languages • 📄 ${pageElements.length} elements on canvas`;
                })
                .catch(err => {
                    document.getElementById('stats').innerHTML = '❌ Error loading stats';
                });
        }
        
        // Canvas drop handling
        const canvas = document.getElementById('canvas');
        
        canvas.addEventListener('dragover', (e) => {
            e.preventDefault();
            canvas.classList.add('drag-over');
        });
        
        canvas.addEventListener('dragleave', () => {
            canvas.classList.remove('drag-over');
        });
        
        canvas.addEventListener('drop', (e) => {
            e.preventDefault();
            canvas.classList.remove('drag-over');
            
            const blockId = e.dataTransfer.getData('text/plain');
            const blockLabel = e.dataTransfer.getData('text/label');
            const blockIcon = e.dataTransfer.getData('text/icon');
            
            fetch('/api/render_block', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ block_id: blockId, language: currentLanguage })
            })
            .then(r => r.json())
            .then(result => {
                if (result.success) {
                    const wrapper = document.createElement('div');
                    wrapper.className = 'page-element';
                    wrapper.innerHTML = `
                        <div class="element-controls">${blockIcon} ${blockLabel} ✕</div>
                        ${result.html}
                    `;
                    
                    // Add click to remove
                    wrapper.querySelector('.element-controls').addEventListener('click', () => {
                        wrapper.remove();
                        pageElements = pageElements.filter(el => el !== wrapper);
                        loadStats();
                    });
                    
                    canvas.appendChild(wrapper);
                    pageElements.push(wrapper);
                    
                    // Remove placeholder text
                    const placeholder = canvas.querySelector('h3');
                    if (placeholder) placeholder.style.display = 'none';
                    
                    loadStats();
                } else {
                    alert('Error rendering block: ' + result.error);
                }
            })
            .catch(err => {
                alert('Network error: ' + err.message);
            });
        });
        
        // Clear canvas
        function clearCanvas() {
            if (confirm('Clear all elements from canvas?')) {
                canvas.innerHTML = `
                    <h3 style="color: #718096;">Drop blocks here to build your page</h3>
                    <p style="color: #a0aec0; margin-top: 10px;">Click and drag any block from the sidebar</p>
                `;
                pageElements = [];
                loadStats();
            }
        }
        
        // Export page
        function exportPage() {
            if (pageElements.length === 0) {
                alert('Canvas is empty! Add some blocks first.');
                return;
            }
            
            const html = pageElements.map(el => {
                const content = el.innerHTML.replace(/<div class="element-controls">.*?<\/div>/, '');
                return content;
            }).join('\\n');
            
            const fullHtml = `<!DOCTYPE html>
<html dir="${currentLanguage === 'fa' || currentLanguage === 'ar' || currentLanguage === 'he' ? 'rtl' : 'ltr'}">
<head>
    <meta charset="UTF-8">
    <title>Generated Page - Rails Page Builder</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; direction: ${currentLanguage === 'fa' || currentLanguage === 'ar' || currentLanguage === 'he' ? 'rtl' : 'ltr'}; }
    </style>
</head>
<body>
${html}
</body>
</html>`;
            
            const blob = new Blob([fullHtml], { type: 'text/html' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `page-${currentLanguage}-${Date.now()}.html`;
            a.click();
            URL.revokeObjectURL(url);
        }
        
        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            loadBlocks();
            loadStats();
            
            console.log('🚀 Rails Page Builder Interactive Demo Loaded');
            console.log('Language: ' + currentLanguage);
        });
    </script>
</body>
</html>