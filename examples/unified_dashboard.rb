#!/usr/bin/env ruby
# frozen_string_literal: true

# Unified Dashboard - Complete Rails Page Builder Demo
# Combines Phase 1 (Advanced Blocks, Templates, Languages, Assets) 
# with Phase 2 (Plugins, APIs, Editor, Components)

# Load all systems
require_relative '../lib/rails/page/builder/version'
require_relative '../lib/rails/page/builder/configuration'
require_relative '../lib/rails/page/builder/block_library'
require_relative '../lib/rails/page/builder/template_system'
require_relative '../lib/rails/page/builder/plugin_system'
require_relative '../lib/rails/page/builder/api_integration'
require_relative '../lib/rails/page/builder/advanced_editor'

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

puts "🏗️  Rails Page Builder - Unified Dashboard"
puts "=" * 60
puts "RTL-First Design | Multi-Language | Advanced Features"
puts "=" * 60

# Create output directory
Dir.mkdir('examples/output') unless Dir.exist?('examples/output')

# Configure for RTL-first design
Rails::Page::Builder.configure do |config|
  config.default_language = :fa  # RTL-first approach
  config.supported_languages = [:fa, :ar, :he, :en]
  config.enable_plugins = true
  config.editor_theme = 'dark'
  config.api_cache_ttl = 600
  config.enable_collaboration = true
end

# Initialize systems
puts "\n🚀 Initializing Systems..."

# Phase 1: Block Library Enhancement
puts "📦 Loading Enhanced Block Library..."
enhanced_blocks = Rails::Page::Builder::BlockLibrary.all_blocks(:fa)
puts "   ✅ #{enhanced_blocks.count} blocks loaded"

# Phase 2: Advanced Systems
puts "🔧 Loading Advanced Systems..."
sample_plugin = {
  id: 'rtl-enhancer',
  name: 'RTL Enhancement Plugin',
  version: '1.0.0',
  author: 'Page Builder Team',
  description: 'Enhances RTL text rendering and layout',
  category: 'rtl',
  settings: { auto_detect_direction: true, enhance_typography: true }
}

plugin = Rails::Page::Builder::PluginSystem.register_plugin('rtl-enhancer', sample_plugin)
puts "   ✅ RTL Enhancement Plugin loaded"

# Register API for content translation
Rails::Page::Builder::ApiIntegration.register_api(:translation, {
  base_url: 'https://api.mymemory.translated.net',
  authentication: { type: 'none' },
  rate_limit: { requests: 100, period: 3600 }
})
puts "   ✅ Translation API registered"

# Setup advanced editor with RTL support
Rails::Page::Builder::AdvancedEditor.register_theme('rtl-dark', {
  colors: {
    toolbar_bg: '#2d3748',
    content_bg: '#1a202c',
    content_text: '#e2e8f0',
    primary: '#4299e1',
    rtl_indicator: '#38b2ac'
  },
  css_variables: {
    'text-direction': 'rtl',
    'text-align': 'right'
  }
})
puts "   ✅ RTL Dark theme created"

puts "\n🌍 Creating Multi-Language Dashboard..."

# Function to create dashboard for each language
def create_dashboard(language)
  rtl = [:fa, :ar, :he].include?(language)
  dir_attr = rtl ? 'rtl' : 'ltr'
  text_align = rtl ? 'right' : 'left'
  
  # Language-specific content
  content = case language
  when :fa
    {
      title: 'داشبورد ساخت صفحه ریلز',
      subtitle: 'سیستم پیشرفته ساخت صفحه با پشتیبانی کامل از زبان‌های راست به چپ',
      phase1_title: 'فاز یک: بلوک‌ها و قالب‌ها',
      phase2_title: 'فاز دو: سیستم‌های پیشرفته',
      blocks_count: 'تعداد بلوک‌ها',
      templates_count: 'تعداد قالب‌ها',
      languages_count: 'زبان‌های پشتیبانی شده',
      plugins_count: 'افزونه‌های فعال',
      editor_tools: 'ابزارهای ویرایشگر',
      api_integrations: 'یکپارچه‌سازی‌های API'
    }
  when :ar
    {
      title: 'لوحة تحكم منشئ الصفحات ريلز',
      subtitle: 'نظام متقدم لإنشاء الصفحات مع دعم كامل للغات من اليمين إلى اليسار',
      phase1_title: 'المرحلة الأولى: الكتل والقوالب',
      phase2_title: 'المرحلة الثانية: الأنظمة المتقدمة',
      blocks_count: 'عدد الكتل',
      templates_count: 'عدد القوالب',
      languages_count: 'اللغات المدعومة',
      plugins_count: 'الإضافات النشطة',
      editor_tools: 'أدوات المحرر',
      api_integrations: 'تكاملات API'
    }
  when :he
    {
      title: 'לוח בקרה של בונה עמודים ריילס',
      subtitle: 'מערכת מתקדמת לבניית עמודים עם תמיכה מלאה בשפות מימין לשמאל',
      phase1_title: 'שלב ראשון: בלוקים ותבניות',
      phase2_title: 'שלב שני: מערכות מתקדמות',
      blocks_count: 'מספר בלוקים',
      templates_count: 'מספר תבניות',
      languages_count: 'שפות נתמכות',
      plugins_count: 'תוספים פעילים',
      editor_tools: 'כלי עורך',
      api_integrations: 'אינטגרציות API'
    }
  else # English
    {
      title: 'Rails Page Builder Dashboard',
      subtitle: 'Advanced page building system with full RTL language support',
      phase1_title: 'Phase One: Blocks & Templates',
      phase2_title: 'Phase Two: Advanced Systems',
      blocks_count: 'Total Blocks',
      templates_count: 'Total Templates',
      languages_count: 'Supported Languages',
      plugins_count: 'Active Plugins',
      editor_tools: 'Editor Tools',
      api_integrations: 'API Integrations'
    }
  end

  # Get statistics
  blocks = Rails::Page::Builder::BlockLibrary.all_blocks(language)
  plugins = Rails::Page::Builder::PluginSystem.available_plugins
  apis = Rails::Page::Builder::ApiIntegration.list_apis
  editor_tools = Rails::Page::Builder::AdvancedEditor.get_toolbar_tools

  # Block categories for navigation
  categories = {}
  blocks.each do |block|
    category = block[:category]
    categories[category] ||= []
    categories[category] << block
  end

  <<~HTML
    <!DOCTYPE html>
    <html lang="#{language}" dir="#{dir_attr}">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>#{content[:title]}</title>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        #{rtl ? '<link href="https://fonts.googleapis.com/css2?family=Vazirmatn:wght@300;400;500;600;700&display=swap" rel="stylesheet">' : ''}
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
            
            body {
                font-family: #{rtl ? "'Vazirmatn', " : ""}'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
                direction: #{dir_attr};
            }
            
            .dashboard-container {
                max-width: 1400px;
                margin: 0 auto;
                padding: 20px;
            }
            
            .header {
                text-align: center;
                color: white;
                margin-bottom: 40px;
            }
            
            .header h1 {
                font-size: 3rem;
                font-weight: 700;
                margin-bottom: 10px;
                text-shadow: 0 2px 4px rgba(0,0,0,0.3);
            }
            
            .header p {
                font-size: 1.2rem;
                opacity: 0.9;
                max-width: 600px;
                margin: 0 auto;
            }
            
            .language-switcher {
                position: fixed;
                top: 20px;
                #{rtl ? 'left' : 'right'}: 20px;
                background: rgba(255,255,255,0.1);
                border-radius: 8px;
                padding: 10px;
                backdrop-filter: blur(10px);
            }
            
            .language-switcher a {
                color: white;
                text-decoration: none;
                margin: 0 5px;
                padding: 5px 10px;
                border-radius: 4px;
                transition: background 0.3s;
            }
            
            .language-switcher a:hover,
            .language-switcher a.active {
                background: rgba(255,255,255,0.2);
            }
            
            .stats-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
                gap: 20px;
                margin-bottom: 40px;
            }
            
            .stat-card {
                background: rgba(255,255,255,0.95);
                border-radius: 12px;
                padding: 24px;
                text-align: center;
                box-shadow: 0 8px 32px rgba(0,0,0,0.1);
                backdrop-filter: blur(10px);
                border: 1px solid rgba(255,255,255,0.2);
                transition: transform 0.3s, box-shadow 0.3s;
            }
            
            .stat-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 12px 40px rgba(0,0,0,0.15);
            }
            
            .stat-icon {
                font-size: 3rem;
                margin-bottom: 15px;
                display: block;
            }
            
            .stat-number {
                font-size: 2.5rem;
                font-weight: 700;
                color: #2d3748;
                margin-bottom: 5px;
            }
            
            .stat-label {
                color: #4a5568;
                font-weight: 500;
            }
            
            .phases-container {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 30px;
                margin-bottom: 40px;
            }
            
            .phase-section {
                background: rgba(255,255,255,0.95);
                border-radius: 16px;
                padding: 30px;
                box-shadow: 0 8px 32px rgba(0,0,0,0.1);
            }
            
            .phase-title {
                font-size: 1.8rem;
                font-weight: 600;
                color: #2d3748;
                margin-bottom: 20px;
                text-align: #{text_align};
            }
            
            .block-categories {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 15px;
                margin-bottom: 20px;
            }
            
            .category-card {
                background: #f7fafc;
                border: 2px solid #e2e8f0;
                border-radius: 8px;
                padding: 15px;
                text-align: center;
                transition: all 0.3s;
                cursor: pointer;
            }
            
            .category-card:hover {
                border-color: #4299e1;
                background: #ebf8ff;
            }
            
            .category-name {
                font-weight: 500;
                color: #2d3748;
                margin-bottom: 5px;
            }
            
            .category-count {
                color: #718096;
                font-size: 0.9rem;
            }
            
            .block-showcase {
                display: none;
                grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
                gap: 20px;
                margin-top: 20px;
                padding: 20px;
                background: #f7fafc;
                border-radius: 8px;
            }
            
            .block-preview {
                background: white;
                border-radius: 8px;
                padding: 15px;
                border: 1px solid #e2e8f0;
            }
            
            .block-title {
                font-weight: 500;
                color: #2d3748;
                margin-bottom: 10px;
                display: flex;
                align-items: center;
                gap: 8px;
            }
            
            .block-content {
                border: 1px dashed #cbd5e0;
                border-radius: 4px;
                min-height: 100px;
                overflow: hidden;
            }
            
            .advanced-features {
                background: rgba(255,255,255,0.95);
                border-radius: 16px;
                padding: 30px;
                margin-bottom: 20px;
            }
            
            .feature-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
                gap: 20px;
                margin-top: 20px;
            }
            
            .feature-item {
                background: linear-gradient(135deg, #667eea, #764ba2);
                color: white;
                padding: 20px;
                border-radius: 8px;
                text-align: center;
            }
            
            .feature-icon {
                font-size: 2rem;
                margin-bottom: 10px;
                display: block;
            }
            
            .footer {
                text-align: center;
                color: white;
                margin-top: 40px;
                padding: 20px;
                background: rgba(0,0,0,0.1);
                border-radius: 12px;
            }
            
            @media (max-width: 768px) {
                .phases-container {
                    grid-template-columns: 1fr;
                }
                
                .header h1 {
                    font-size: 2rem;
                }
                
                .stats-grid {
                    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                }
            }
        </style>
    </head>
    <body>
        <div class="language-switcher">
            <a href="unified_dashboard_fa.html" class="#{language == :fa ? 'active' : ''}">فا</a>
            <a href="unified_dashboard_ar.html" class="#{language == :ar ? 'active' : ''}">ع</a>
            <a href="unified_dashboard_he.html" class="#{language == :he ? 'active' : ''}">ע</a>
            <a href="unified_dashboard_en.html" class="#{language == :en ? 'active' : ''}">EN</a>
        </div>
        
        <div class="dashboard-container">
            <header class="header">
                <h1>#{content[:title]}</h1>
                <p>#{content[:subtitle]}</p>
            </header>
            
            <div class="stats-grid">
                <div class="stat-card">
                    <span class="stat-icon">🧱</span>
                    <div class="stat-number">#{blocks.count}</div>
                    <div class="stat-label">#{content[:blocks_count]}</div>
                </div>
                
                <div class="stat-card">
                    <span class="stat-icon">🎨</span>
                    <div class="stat-number">#{categories.count}</div>
                    <div class="stat-label">#{content[:templates_count]}</div>
                </div>
                
                <div class="stat-card">
                    <span class="stat-icon">🌍</span>
                    <div class="stat-number">4</div>
                    <div class="stat-label">#{content[:languages_count]}</div>
                </div>
                
                <div class="stat-card">
                    <span class="stat-icon">🔌</span>
                    <div class="stat-number">#{plugins.count}</div>
                    <div class="stat-label">#{content[:plugins_count]}</div>
                </div>
                
                <div class="stat-card">
                    <span class="stat-icon">🛠️</span>
                    <div class="stat-number">#{editor_tools.count}</div>
                    <div class="stat-label">#{content[:editor_tools]}</div>
                </div>
                
                <div class="stat-card">
                    <span class="stat-icon">🌐</span>
                    <div class="stat-number">#{apis.count}</div>
                    <div class="stat-label">#{content[:api_integrations]}</div>
                </div>
            </div>
            
            <div class="phases-container">
                <div class="phase-section">
                    <h2 class="phase-title">#{content[:phase1_title]}</h2>
                    <div class="block-categories">
                        #{categories.map do |category, category_blocks|
                          <<~CATEGORY
                            <div class="category-card" onclick="toggleBlockShowcase('#{category}')">
                                <div class="category-name">#{category}</div>
                                <div class="category-count">#{category_blocks.count} بلوک</div>
                            </div>
                          CATEGORY
                        end.join}
                    </div>
                    
                    #{categories.map do |category, category_blocks|
                      <<~SHOWCASE
                        <div id="blocks-#{category}" class="block-showcase">
                            #{category_blocks.first(3).map do |block|
                              <<~BLOCK
                                <div class="block-preview">
                                    <div class="block-title">
                                        <span>#{block[:icon]}</span>
                                        <span>#{block[:label]}</span>
                                    </div>
                                    <div class="block-content">
                                        #{block[:content]}
                                    </div>
                                </div>
                              BLOCK
                            end.join}
                        </div>
                      SHOWCASE
                    end.join}
                </div>
                
                <div class="phase-section">
                    <h2 class="phase-title">#{content[:phase2_title]}</h2>
                    <div class="feature-grid">
                        <div class="feature-item">
                            <span class="feature-icon">📦</span>
                            <h3>سیستم افزونه‌ها</h3>
                            <p>معماری قابل توسعه با Hook و Filter</p>
                        </div>
                        
                        <div class="feature-item">
                            <span class="feature-icon">🌐</span>
                            <h3>یکپارچه‌سازی API</h3>
                            <p>اتصال به سرویس‌های خارجی با کش</p>
                        </div>
                        
                        <div class="feature-item">
                            <span class="feature-icon">🎨</span>
                            <h3>ویرایشگر پیشرفته</h3>
                            <p>ابزارهای حرفه‌ای ویرایش و تم‌ها</p>
                        </div>
                        
                        <div class="feature-item">
                            <span class="feature-icon">🧩</span>
                            <h3>کتابخانه کامپوننت</h3>
                            <p>اجزای قابل استفاده مجدد</p>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="advanced-features">
                <h2 class="phase-title">ویژگی‌های RTL محور</h2>
                <div class="feature-grid">
                    <div class="feature-item">
                        <span class="feature-icon">🔄</span>
                        <h4>تشخیص خودکار جهت</h4>
                        <p>تشخیص هوشمند زبان‌های راست به چپ</p>
                    </div>
                    
                    <div class="feature-item">
                        <span class="feature-icon">🎯</span>
                        <h4>طراحی RTL محور</h4>
                        <p>ابتدا برای زبان‌های راست به چپ طراحی شده</p>
                    </div>
                    
                    <div class="feature-item">
                        <span class="feature-icon">🌍</span>
                        <h4>پشتیبانی چندزبانه</h4>
                        <p>فارسی، عربی، عبری و انگلیسی</p>
                    </div>
                    
                    <div class="feature-item">
                        <span class="feature-icon">🎨</span>
                        <h4>تایپوگرافی هوشمند</h4>
                        <p>بهینه‌سازی فونت‌ها برای هر زبان</p>
                    </div>
                </div>
            </div>
            
            <footer class="footer">
                <h3>🎉 Rails Page Builder</h3>
                <p>سیستم کامل ساخت صفحه با پشتیبانی RTL و ویژگی‌های پیشرفته</p>
                <p style="margin-top: 10px; opacity: 0.8;">
                    فاز ۱: #{blocks.count} بلوک • #{categories.count} دسته‌بندی • ۴ زبان
                    <br>
                    فاز ۲: #{plugins.count} افزونه • #{apis.count} API • #{editor_tools.count} ابزار
                </p>
            </footer>
        </div>
        
        <script>
            function toggleBlockShowcase(category) {
                // Hide all showcases
                document.querySelectorAll('.block-showcase').forEach(el => {
                    el.style.display = 'none';
                });
                
                // Show selected showcase
                const showcase = document.getElementById('blocks-' + category);
                if (showcase) {
                    showcase.style.display = 'grid';
                }
                
                // Update active state
                document.querySelectorAll('.category-card').forEach(el => {
                    el.style.backgroundColor = '#f7fafc';
                    el.style.borderColor = '#e2e8f0';
                });
                
                event.target.closest('.category-card').style.backgroundColor = '#ebf8ff';
                event.target.closest('.category-card').style.borderColor = '#4299e1';
            }
            
            // Add interactive features
            document.addEventListener('DOMContentLoaded', function() {
                // Animate stat cards
                const statCards = document.querySelectorAll('.stat-card');
                statCards.forEach((card, index) => {
                    setTimeout(() => {
                        card.style.opacity = '0';
                        card.style.transform = 'translateY(20px)';
                        card.style.transition = 'all 0.6s ease';
                        card.style.opacity = '1';
                        card.style.transform = 'translateY(0)';
                    }, index * 100);
                });
                
                console.log('🚀 Rails Page Builder Dashboard Loaded');
                console.log('Language: #{language}');
                console.log('Direction: #{dir_attr}');
                console.log('Blocks: #{blocks.count}');
                console.log('Plugins: #{plugins.count}');
            });
        </script>
    </body>
    </html>
  HTML
end

# Generate dashboards for all languages
languages = [:fa, :ar, :he, :en]
generated_files = []

languages.each do |lang|
  puts "   🌍 Creating #{lang.to_s.upcase} dashboard..."
  
  dashboard_html = create_dashboard(lang)
  filename = "examples/output/unified_dashboard_#{lang}.html"
  File.write(filename, dashboard_html)
  generated_files << filename
  
  puts "      ✅ #{filename}"
end

# Create main redirect page
main_dashboard = <<~HTML
  <!DOCTYPE html>
  <html>
  <head>
      <meta charset="UTF-8">
      <title>Rails Page Builder - Language Selection</title>
      <style>
          body { 
              margin: 0; 
              font-family: Arial, sans-serif; 
              background: linear-gradient(135deg, #667eea, #764ba2);
              height: 100vh;
              display: flex;
              align-items: center;
              justify-content: center;
          }
          .container {
              text-align: center;
              color: white;
              background: rgba(255,255,255,0.1);
              padding: 40px;
              border-radius: 16px;
              backdrop-filter: blur(10px);
          }
          h1 { margin-bottom: 20px; }
          p { margin-bottom: 30px; opacity: 0.9; }
          .language-buttons {
              display: flex;
              gap: 20px;
              justify-content: center;
              flex-wrap: wrap;
          }
          .lang-btn {
              padding: 15px 30px;
              background: rgba(255,255,255,0.2);
              color: white;
              text-decoration: none;
              border-radius: 8px;
              font-weight: 500;
              transition: all 0.3s;
              border: 2px solid transparent;
          }
          .lang-btn:hover {
              background: rgba(255,255,255,0.3);
              border-color: white;
              transform: translateY(-2px);
          }
      </style>
  </head>
  <body>
      <div class="container">
          <h1>🏗️ Rails Page Builder</h1>
          <p>Choose your preferred language / زبان مورد نظر خود را انتخاب کنید</p>
          <div class="language-buttons">
              <a href="unified_dashboard_fa.html" class="lang-btn">فارسی (Persian)</a>
              <a href="unified_dashboard_ar.html" class="lang-btn">العربية (Arabic)</a>
              <a href="unified_dashboard_he.html" class="lang-btn">עברית (Hebrew)</a>
              <a href="unified_dashboard_en.html" class="lang-btn">English</a>
          </div>
      </div>
      <script>
          // Auto-redirect to Persian (RTL-first approach)
          setTimeout(() => {
              window.location.href = 'unified_dashboard_fa.html';
          }, 3000);
      </script>
  </body>
  </html>
HTML

File.write('examples/output/unified_dashboard.html', main_dashboard)
generated_files << 'examples/output/unified_dashboard.html'

<function_calls>
<invoke name="TodoWrite">
<parameter name="todos">[{"content": "Enhance Phase 1 with more advanced blocks (forms, media, layouts)", "status": "completed", "priority": "high", "id": "1"}, {"content": "Fix CSS issues and improve RTL support", "status": "completed", "priority": "high", "id": "2"}, {"content": "Create unified dashboard combining Phase 1 and Phase 2", "status": "completed", "priority": "high", "id": "3"}, {"content": "Add more sophisticated block types for better visual design", "status": "completed", "priority": "medium", "id": "4"}, {"content": "Implement proper RTL-first design with English support", "status": "completed", "priority": "medium", "id": "5"}]