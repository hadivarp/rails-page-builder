#!/usr/bin/env ruby
require 'sinatra'
require 'json'
require_relative 'lib/rails/page/builder'

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

# Setup Rails Page Builder
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
  config.enable_plugins = true
end

# Initialize systems
Rails::Page::Builder::PluginSystem.register_plugin('demo-plugin', {
  id: 'demo-plugin',
  name: 'Demo Plugin',
  version: '1.0.0',
  author: 'Demo',
  description: 'Demo plugin for testing'
})

Rails::Page::Builder::ApiIntegration.register_api(:demo, {
  base_url: 'https://jsonplaceholder.typicode.com',
  authentication: { type: 'none' }
})

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
  {
    blocks: Rails::Page::Builder::BlockLibrary.all_blocks.count,
    plugins: Rails::Page::Builder::PluginSystem.available_plugins.count,
    apis: Rails::Page::Builder::ApiIntegration.list_apis.count,
    editor_tools: Rails::Page::Builder::AdvancedEditor.get_toolbar_tools.count,
    languages: 4
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
            font-family: Arial, sans-serif; 
            background: #f5f5f5;
            direction: rtl;
        }
        .container { display: flex; height: 100vh; }
        .sidebar { 
            width: 300px; 
            background: #2d3748; 
            color: white; 
            padding: 20px;
            overflow-y: auto;
        }
        .canvas { 
            flex: 1; 
            padding: 20px; 
            background: white;
            overflow-y: auto;
        }
        .block-item {
            background: #4a5568;
            margin: 10px 0;
            padding: 15px;
            border-radius: 8px;
            cursor: pointer;
            transition: background 0.3s;
        }
        .block-item:hover {
            background: #667eea;
        }
        .category-title {
            color: #81c784;
            margin: 20px 0 10px 0;
            font-weight: bold;
        }
        .drop-zone {
            min-height: 200px;
            border: 2px dashed #ddd;
            border-radius: 8px;
            padding: 20px;
            text-align: center;
            margin: 10px 0;
        }
        .page-header {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 20px;
            margin: -20px -20px 20px -20px;
            border-radius: 0 0 12px 12px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="sidebar">
            <h2>📦 Rails Page Builder</h2>
            <p style="margin: 10px 0; opacity: 0.8;">Drag blocks to canvas</p>
            
            <div id="blocks-container">
                <div class="category-title">⏳ Loading blocks...</div>
            </div>
        </div>
        
        <div class="canvas">
            <div class="page-header">
                <h1>🎨 Interactive Page Builder</h1>
                <p>Drop blocks from the sidebar to build your page</p>
            </div>
            
            <div class="drop-zone" id="canvas">
                <p>Drop blocks here to start building your page</p>
            </div>
            
            <div style="margin-top: 20px; padding: 15px; background: #f8f9fa; border-radius: 8px;">
                <strong>Stats:</strong>
                <span id="stats">Loading...</span>
            </div>
        </div>
    </div>
    
    <script>
        // Load blocks
        fetch('/blocks/fa')
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
                    title.textContent = category;
                    container.appendChild(title);
                    
                    categoryBlocks.forEach(block => {
                        const item = document.createElement('div');
                        item.className = 'block-item';
                        item.innerHTML = `${block.icon} ${block.label}`;
                        item.draggable = true;
                        item.dataset.blockId = block.id;
                        
                        item.addEventListener('dragstart', (e) => {
                            e.dataTransfer.setData('text/plain', block.id);
                        });
                        
                        container.appendChild(item);
                    });
                });
            });
        
        // Load stats
        fetch('/api/stats')
            .then(r => r.json())
            .then(stats => {
                document.getElementById('stats').innerHTML = 
                    `${stats.blocks} blocks • ${stats.plugins} plugins • ${stats.apis} APIs • ${stats.editor_tools} tools`;
            });
        
        // Canvas drop handling
        const canvas = document.getElementById('canvas');
        
        canvas.addEventListener('dragover', (e) => {
            e.preventDefault();
            canvas.style.borderColor = '#667eea';
        });
        
        canvas.addEventListener('dragleave', () => {
            canvas.style.borderColor = '#ddd';
        });
        
        canvas.addEventListener('drop', (e) => {
            e.preventDefault();
            canvas.style.borderColor = '#ddd';
            
            const blockId = e.dataTransfer.getData('text/plain');
            
            fetch('/api/render_block', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ block_id: blockId, language: 'fa' })
            })
            .then(r => r.json())
            .then(result => {
                if (result.success) {
                    const wrapper = document.createElement('div');
                    wrapper.innerHTML = result.html;
                    wrapper.style.margin = '10px 0';
                    wrapper.style.border = '1px solid #eee';
                    wrapper.style.borderRadius = '4px';
                    canvas.appendChild(wrapper);
                    
                    if (canvas.querySelector('p')) {
                        canvas.querySelector('p').remove();
                    }
                }
            });
        });
    </script>
</body>
</html>