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

  dashboard_html = <<~HTML
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
            
            .unified-content {
                background: rgba(255,255,255,0.95);
                border-radius: 16px;
                padding: 30px;
                margin-bottom: 40px;
                box-shadow: 0 8px 32px rgba(0,0,0,0.1);
            }
            
            .section-title {
                font-size: 1.8rem;
                font-weight: 600;
                color: #2d3748;
                margin-bottom: 20px;
                text-align: #{text_align};
                border-bottom: 3px solid #4299e1;
                padding-bottom: 10px;
            }
            
            .feature-showcase {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
                gap: 20px;
                margin: 20px 0;
            }
            
            .feature-card {
                background: linear-gradient(135deg, #667eea, #764ba2);
                color: white;
                padding: 25px;
                border-radius: 12px;
                text-align: center;
                transition: transform 0.3s;
            }
            
            .feature-card:hover {
                transform: translateY(-3px);
            }
            
            .feature-icon {
                font-size: 2.5rem;
                margin-bottom: 15px;
                display: block;
            }
            
            .feature-title {
                font-size: 1.2rem;
                font-weight: 600;
                margin-bottom: 10px;
            }
            
            .footer {
                text-align: center;
                color: white;
                margin-top: 40px;
                padding: 30px;
                background: rgba(0,0,0,0.1);
                border-radius: 12px;
            }
            
            @media (max-width: 768px) {
                .header h1 {
                    font-size: 2rem;
                }
                
                .stats-grid {
                    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                }
                
                .feature-showcase {
                    grid-template-columns: 1fr;
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
            
            <div class="unified-content">
                <h2 class="section-title">#{content[:phase1_title]} + #{content[:phase2_title]}</h2>
                <div class="feature-showcase">
                    <div class="feature-card">
                        <span class="feature-icon">🧱</span>
                        <div class="feature-title">کتابخانه بلوک پیشرفته</div>
                        <p>#{blocks.count} بلوک در #{categories.count} دسته‌بندی مختلف</p>
                    </div>
                    
                    <div class="feature-card">
                        <span class="feature-icon">🎨</span>
                        <div class="feature-title">سیستم قالب‌ها</div>
                        <p>قالب‌های آماده و قابل تنظیم</p>
                    </div>
                    
                    <div class="feature-card">
                        <span class="feature-icon">🌍</span>
                        <div class="feature-title">پشتیبانی چندزبانه</div>
                        <p>RTL و LTR با تشخیص خودکار</p>
                    </div>
                    
                    <div class="feature-card">
                        <span class="feature-icon">📁</span>
                        <div class="feature-title">مدیریت دارایی‌ها</div>
                        <p>آپلود و مدیریت تصاویر و فایل‌ها</p>
                    </div>
                    
                    <div class="feature-card">
                        <span class="feature-icon">📦</span>
                        <div class="feature-title">سیستم افزونه‌ها</div>
                        <p>معماری قابل توسعه با Hook و Filter</p>
                    </div>
                    
                    <div class="feature-card">
                        <span class="feature-icon">🌐</span>
                        <div class="feature-title">یکپارچه‌سازی API</div>
                        <p>اتصال به سرویس‌های خارجی</p>
                    </div>
                    
                    <div class="feature-card">
                        <span class="feature-icon">🛠️</span>
                        <div class="feature-title">ویرایشگر پیشرفته</div>
                        <p>ابزارهای حرفه‌ای ویرایش</p>
                    </div>
                    
                    <div class="feature-card">
                        <span class="feature-icon">🧩</span>
                        <div class="feature-title">کامپوننت‌های قابل استفاده</div>
                        <p>اجزای پیش‌ساخته و قابل تنظیم</p>
                    </div>
                </div>
            </div>
            
            <footer class="footer">
                <h3>🎉 Rails Page Builder - نسخه کامل</h3>
                <p>سیستم جامع ساخت صفحه با پشتیبانی RTL و ویژگی‌های پیشرفته</p>
                <p style="margin-top: 15px; opacity: 0.9;">
                    <strong>آمار کلی:</strong><br>
                    #{blocks.count} بلوک • #{categories.count} دسته‌بندی • 4 زبان • #{plugins.count} افزونه • #{apis.count} API • #{editor_tools.count} ابزار
                </p>
            </footer>
        </div>
        
        <script>
            document.addEventListener('DOMContentLoaded', function() {
                console.log('🚀 Rails Page Builder Unified Dashboard');
                console.log('Language: #{language}');
                console.log('Direction: #{dir_attr}');
                console.log('Total Blocks: #{blocks.count}');
                console.log('Total Categories: #{categories.count}');
                console.log('Plugins: #{plugins.count}');
                console.log('APIs: #{apis.count}');
                console.log('Editor Tools: #{editor_tools.count}');
            });
        </script>
    </body>
    </html>
  HTML
  
  dashboard_html
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
puts "\n📄 Creating main dashboard page..."
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
          h1 { margin-bottom: 20px; font-size: 2.5rem; }
          p { margin-bottom: 30px; opacity: 0.9; font-size: 1.1rem; }
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
              font-size: 1.1rem;
          }
          .lang-btn:hover {
              background: rgba(255,255,255,0.3);
              border-color: white;
              transform: translateY(-2px);
          }
          .auto-redirect {
              margin-top: 20px;
              font-size: 0.9rem;
              opacity: 0.7;
          }
      </style>
  </head>
  <body>
      <div class="container">
          <h1>🏗️ Rails Page Builder</h1>
          <p>Choose your preferred language<br>زبان مورد نظر خود را انتخاب کنید</p>
          <div class="language-buttons">
              <a href="unified_dashboard_fa.html" class="lang-btn">🇮🇷 فارسی</a>
              <a href="unified_dashboard_ar.html" class="lang-btn">🇸🇦 العربية</a>
              <a href="unified_dashboard_he.html" class="lang-btn">🇮🇱 עברית</a>
              <a href="unified_dashboard_en.html" class="lang-btn">🇺🇸 English</a>
          </div>
          <div class="auto-redirect">
              Auto-redirecting to Persian in <span id="countdown">5</span> seconds...
          </div>
      </div>
      <script>
          let countdown = 5;
          const countdownEl = document.getElementById('countdown');
          
          const timer = setInterval(() => {
              countdown--;
              countdownEl.textContent = countdown;
              
              if (countdown <= 0) {
                  clearInterval(timer);
                  window.location.href = 'unified_dashboard_fa.html';
              }
          }, 1000);
      </script>
  </body>
  </html>
HTML

File.write('examples/output/unified_dashboard.html', main_dashboard)
generated_files << 'examples/output/unified_dashboard.html'

puts "      ✅ examples/output/unified_dashboard.html"

puts "\n" + "=" * 60
puts "🎉 Unified Dashboard Complete!"
puts "=" * 60
puts "\n📁 Generated Files:"
generated_files.each { |file| puts "  ✅ #{file}" }

puts "\n🌟 Features Implemented:"
puts "  📦 Enhanced Block Library: #{enhanced_blocks.count} blocks"
puts "  🎨 RTL-First Design with LTR support"
puts "  🌍 Multi-Language: Persian, Arabic, Hebrew, English"
puts "  🔧 Advanced Systems: Plugins, APIs, Editor, Components"
puts "  💫 Unified Dashboard with interactive features"

puts "\n🚀 Quick Start:"
puts "  1. Open: examples/output/unified_dashboard.html"
puts "  2. Choose your language or wait for auto-redirect to Persian"
puts "  3. Explore all Phase 1 & 2 features in one interface"

puts "\n🎯 RTL-First Approach:"
puts "  • Default language: Persian (فارسی)"
puts "  • Proper RTL typography and layout"
puts "  • Arabic and Hebrew full support"
puts "  • English as secondary language"

puts "=" * 60