# frozen_string_literal: true

module Rails
  module Page
    module Builder
      class TemplateSystem
        class << self
          def all_templates(language = :en)
            [
              landing_page_template(language),
              business_template(language),
              portfolio_template(language),
              blog_template(language),
              ecommerce_template(language),
              agency_template(language),
              restaurant_template(language),
              personal_template(language)
            ]
          end
          
          def find_template(id, language = :en)
            all_templates(language).find { |template| template[:id] == id }
          end
          
          private
          
          def landing_page_template(language)
            is_rtl = rtl?(language)
            
            {
              id: 'landing-page',
              name: t('templates.landing_page', language),
              description: t('templates.landing_page_desc', language),
              category: t('template_categories.marketing', language),
              preview: 'templates/landing-page.jpg',
              tags: [t('tags.marketing', language), t('tags.business', language)],
              content: landing_page_content(language),
              css: landing_page_css(language),
              language: language,
              rtl: is_rtl
            }
          end
          
          def business_template(language)
            is_rtl = rtl?(language)
            
            {
              id: 'business',
              name: t('templates.business', language),
              description: t('templates.business_desc', language),
              category: t('template_categories.business', language),
              preview: 'templates/business.jpg',
              tags: [t('tags.corporate', language), t('tags.professional', language)],
              content: business_template_content(language),
              css: business_template_css(language),
              language: language,
              rtl: is_rtl
            }
          end
          
          def portfolio_template(language)
            is_rtl = rtl?(language)
            
            {
              id: 'portfolio',
              name: t('templates.portfolio', language),
              description: t('templates.portfolio_desc', language),
              category: t('template_categories.creative', language),
              preview: 'templates/portfolio.jpg',
              tags: [t('tags.creative', language), t('tags.showcase', language)],
              content: portfolio_template_content(language),
              css: portfolio_template_css(language),
              language: language,
              rtl: is_rtl
            }
          end
          
          def blog_template(language)
            is_rtl = rtl?(language)
            
            {
              id: 'blog',
              name: t('templates.blog', language),
              description: t('templates.blog_desc', language),
              category: t('template_categories.content', language),
              preview: 'templates/blog.jpg',
              tags: [t('tags.blog', language), t('tags.content', language)],
              content: blog_template_content(language),
              css: blog_template_css(language),
              language: language,
              rtl: is_rtl
            }
          end
          
          def ecommerce_template(language)
            is_rtl = rtl?(language)
            
            {
              id: 'ecommerce',
              name: t('templates.ecommerce', language),
              description: t('templates.ecommerce_desc', language),
              category: t('template_categories.ecommerce', language),
              preview: 'templates/ecommerce.jpg',
              tags: [t('tags.shop', language), t('tags.products', language)],
              content: ecommerce_template_content(language),
              css: ecommerce_template_css(language),
              language: language,
              rtl: is_rtl
            }
          end
          
          def agency_template(language)
            is_rtl = rtl?(language)
            
            {
              id: 'agency',
              name: t('templates.agency', language),
              description: t('templates.agency_desc', language),
              category: t('template_categories.business', language),
              preview: 'templates/agency.jpg',
              tags: [t('tags.agency', language), t('tags.services', language)],
              content: agency_template_content(language),
              css: agency_template_css(language),
              language: language,
              rtl: is_rtl
            }
          end
          
          def restaurant_template(language)
            is_rtl = rtl?(language)
            
            {
              id: 'restaurant',
              name: t('templates.restaurant', language),
              description: t('templates.restaurant_desc', language),
              category: t('template_categories.business', language),
              preview: 'templates/restaurant.jpg',
              tags: [t('tags.food', language), t('tags.menu', language)],
              content: restaurant_template_content(language),
              css: restaurant_template_css(language),
              language: language,
              rtl: is_rtl
            }
          end
          
          def personal_template(language)
            is_rtl = rtl?(language)
            
            {
              id: 'personal',
              name: t('templates.personal', language),
              description: t('templates.personal_desc', language),
              category: t('template_categories.personal', language),
              preview: 'templates/personal.jpg',
              tags: [t('tags.personal', language), t('tags.resume', language)],
              content: personal_template_content(language),
              css: personal_template_css(language),
              language: language,
              rtl: is_rtl
            }
          end
          
          def t(key, language)
            translations = {
              en: {
                'templates.landing_page' => 'Landing Page',
                'templates.landing_page_desc' => 'Perfect for product launches and conversions',
                'templates.business' => 'Business',
                'templates.business_desc' => 'Professional business website template',
                'templates.portfolio' => 'Portfolio',
                'templates.portfolio_desc' => 'Showcase your work and creativity',
                'templates.blog' => 'Blog',
                'templates.blog_desc' => 'Clean blog layout for content creators',
                'templates.ecommerce' => 'E-commerce',
                'templates.ecommerce_desc' => 'Online store with product showcase',
                'templates.agency' => 'Agency',
                'templates.agency_desc' => 'Digital agency and services template',
                'templates.restaurant' => 'Restaurant',
                'templates.restaurant_desc' => 'Food and restaurant business template',
                'templates.personal' => 'Personal',
                'templates.personal_desc' => 'Personal website and resume template',
                'template_categories.marketing' => 'Marketing',
                'template_categories.business' => 'Business',
                'template_categories.creative' => 'Creative',
                'template_categories.content' => 'Content',
                'template_categories.ecommerce' => 'E-commerce',
                'template_categories.personal' => 'Personal',
                'tags.marketing' => 'Marketing',
                'tags.business' => 'Business',
                'tags.corporate' => 'Corporate',
                'tags.professional' => 'Professional',
                'tags.creative' => 'Creative',
                'tags.showcase' => 'Showcase',
                'tags.blog' => 'Blog',
                'tags.content' => 'Content',
                'tags.shop' => 'Shop',
                'tags.products' => 'Products',
                'tags.agency' => 'Agency',
                'tags.services' => 'Services',
                'tags.food' => 'Food',
                'tags.menu' => 'Menu',
                'tags.personal' => 'Personal',
                'tags.resume' => 'Resume'
              },
              fa: {
                'templates.landing_page' => 'صفحه فرود',
                'templates.landing_page_desc' => 'مناسب برای راه‌اندازی محصول و تبدیل بازدیدکننده',
                'templates.business' => 'کسب و کار',
                'templates.business_desc' => 'قالب وب‌سایت حرفه‌ای کسب و کار',
                'templates.portfolio' => 'نمونه کار',
                'templates.portfolio_desc' => 'نمایش کارها و خلاقیت‌های شما',
                'templates.blog' => 'وبلاگ',
                'templates.blog_desc' => 'چیدمان تمیز وبلاگ برای تولیدکنندگان محتوا',
                'templates.ecommerce' => 'فروشگاهی',
                'templates.ecommerce_desc' => 'فروشگاه آنلاین با نمایش محصولات',
                'templates.agency' => 'آژانس',
                'templates.agency_desc' => 'قالب آژانس دیجیتال و خدمات',
                'templates.restaurant' => 'رستوران',
                'templates.restaurant_desc' => 'قالب کسب و کار غذا و رستوران',
                'templates.personal' => 'شخصی',
                'templates.personal_desc' => 'قالب وب‌سایت شخصی و رزومه',
                'template_categories.marketing' => 'بازاریابی',
                'template_categories.business' => 'کسب و کار',
                'template_categories.creative' => 'خلاقانه',
                'template_categories.content' => 'محتوا',
                'template_categories.ecommerce' => 'فروشگاهی',
                'template_categories.personal' => 'شخصی',
                'tags.marketing' => 'بازاریابی',
                'tags.business' => 'کسب و کار',
                'tags.corporate' => 'شرکتی',
                'tags.professional' => 'حرفه‌ای',
                'tags.creative' => 'خلاقانه',
                'tags.showcase' => 'نمایش',
                'tags.blog' => 'وبلاگ',
                'tags.content' => 'محتوا',
                'tags.shop' => 'فروشگاه',
                'tags.products' => 'محصولات',
                'tags.agency' => 'آژانس',
                'tags.services' => 'خدمات',
                'tags.food' => 'غذا',
                'tags.menu' => 'منو',
                'tags.personal' => 'شخصی',
                'tags.resume' => 'رزومه'
              },
              ar: {
                'templates.landing_page' => 'صفحة الهبوط',
                'templates.landing_page_desc' => 'مثالية لإطلاق المنتجات والتحويلات',
                'templates.business' => 'الأعمال',
                'templates.business_desc' => 'قالب موقع أعمال احترافي',
                'templates.portfolio' => 'المحفظة',
                'templates.portfolio_desc' => 'اعرض أعمالك وإبداعك',
                'templates.blog' => 'المدونة',
                'templates.blog_desc' => 'تخطيط مدونة نظيف لمنشئي المحتوى',
                'templates.ecommerce' => 'التجارة الإلكترونية',
                'templates.ecommerce_desc' => 'متجر إلكتروني مع عرض المنتجات',
                'templates.agency' => 'الوكالة',
                'templates.agency_desc' => 'قالب وكالة رقمية وخدمات',
                'templates.restaurant' => 'المطعم',
                'templates.restaurant_desc' => 'قالب أعمال الطعام والمطاعم',
                'templates.personal' => 'شخصي',
                'templates.personal_desc' => 'قالب موقع شخصي وسيرة ذاتية',
                'template_categories.marketing' => 'التسويق',
                'template_categories.business' => 'الأعمال',
                'template_categories.creative' => 'الإبداعية',
                'template_categories.content' => 'المحتوى',
                'template_categories.ecommerce' => 'التجارة الإلكترونية',
                'template_categories.personal' => 'شخصي',
                'tags.marketing' => 'التسويق',
                'tags.business' => 'الأعمال',
                'tags.corporate' => 'الشركات',
                'tags.professional' => 'المهنية',
                'tags.creative' => 'الإبداعية',
                'tags.showcase' => 'العرض',
                'tags.blog' => 'المدونة',
                'tags.content' => 'المحتوى',
                'tags.shop' => 'المتجر',
                'tags.products' => 'المنتجات',
                'tags.agency' => 'الوكالة',
                'tags.services' => 'الخدمات',
                'tags.food' => 'الطعام',
                'tags.menu' => 'القائمة',
                'tags.personal' => 'شخصي',
                'tags.resume' => 'السيرة الذاتية'
              },
              he: {
                'templates.landing_page' => 'דף נחיתה',
                'templates.landing_page_desc' => 'מושלם להשקות מוצרים והמרות',
                'templates.business' => 'עסקי',
                'templates.business_desc' => 'תבנית אתר עסקי מקצועי',
                'templates.portfolio' => 'תיק עבודות',
                'templates.portfolio_desc' => 'הצג את העבודות והיצירתיות שלך',
                'templates.blog' => 'בלוג',
                'templates.blog_desc' => 'פריסת בלוג נקייה ליוצרי תוכן',
                'templates.ecommerce' => 'מסחר אלקטרוני',
                'templates.ecommerce_desc' => 'חנות מקוונת עם תצוגת מוצרים',
                'templates.agency' => 'סוכנות',
                'templates.agency_desc' => 'תבנית סוכנות דיגיטלית ושירותים',
                'templates.restaurant' => 'מסעדה',
                'templates.restaurant_desc' => 'תבנית עסק מזון ומסעדות',
                'templates.personal' => 'אישי',
                'templates.personal_desc' => 'תבנית אתר אישי וקורות חיים',
                'template_categories.marketing' => 'שיווק',
                'template_categories.business' => 'עסקי',
                'template_categories.creative' => 'יצירתי',
                'template_categories.content' => 'תוכן',
                'template_categories.ecommerce' => 'מסחר אלקטרוני',
                'template_categories.personal' => 'אישי',
                'tags.marketing' => 'שיווק',
                'tags.business' => 'עסקי',
                'tags.corporate' => 'תאגידי',
                'tags.professional' => 'מקצועי',
                'tags.creative' => 'יצירתי',
                'tags.showcase' => 'תצוגה',
                'tags.blog' => 'בלוג',
                'tags.content' => 'תוכן',
                'tags.shop' => 'חנות',
                'tags.products' => 'מוצרים',
                'tags.agency' => 'סוכנות',
                'tags.services' => 'שירותים',
                'tags.food' => 'אוכל',
                'tags.menu' => 'תפריט',
                'tags.personal' => 'אישי',
                'tags.resume' => 'קורות חיים'
              }
            }
            
            translations[language][key] || key
          end
          
          def rtl?(language)
            [:fa, :ar, :he, :ur].include?(language.to_sym)
          end
          
          def dir_attr(language)
            rtl?(language) ? 'rtl' : 'ltr'
          end
          
          def text_align(language)
            rtl?(language) ? 'right' : 'left'
          end
          
          # Template content methods
          def landing_page_content(language)
            hero_title = language == :fa ? 'راه‌حل بهترین برای کسب و کار شما' : 'The Best Solution for Your Business'
            hero_subtitle = language == :fa ? 'ما به شما کمک می‌کنیم تا هدف‌های خود را محقق کنید' : 'We help you achieve your goals'
            
            <<~HTML
              <div style="direction: #{dir_attr(language)};">
                <!-- Hero Section -->
                <section style="
                  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                  color: white;
                  padding: 100px 20px;
                  text-align: center;
                  min-height: 600px;
                  display: flex;
                  align-items: center;
                  justify-content: center;
                ">
                  <div style="max-width: 800px;">
                    <h1 style="font-size: 3.5rem; margin-bottom: 20px; font-weight: 700;">#{hero_title}</h1>
                    <p style="font-size: 1.3rem; margin-bottom: 40px; opacity: 0.9;">#{hero_subtitle}</p>
                    <button style="
                      background: #fff;
                      color: #667eea;
                      padding: 15px 40px;
                      border: none;
                      border-radius: 50px;
                      font-size: 1.2rem;
                      font-weight: 600;
                      cursor: pointer;
                      margin: 0 10px;
                    ">#{language == :fa ? 'شروع رایگان' : 'Start Free Trial'}</button>
                    <button style="
                      background: transparent;
                      color: white;
                      border: 2px solid white;
                      padding: 15px 40px;
                      border-radius: 50px;
                      font-size: 1.2rem;
                      font-weight: 600;
                      cursor: pointer;
                      margin: 0 10px;
                    ">#{language == :fa ? 'بیشتر بدانید' : 'Learn More'}</button>
                  </div>
                </section>
                
                <!-- Features Section -->
                <section style="padding: 80px 20px; background: #f8f9fa;">
                  <div style="max-width: 1200px; margin: 0 auto; text-align: center;">
                    <h2 style="font-size: 2.5rem; margin-bottom: 60px; color: #495057;">
                      #{language == :fa ? 'چرا ما را انتخاب کنید؟' : 'Why Choose Us?'}
                    </h2>
                    <div style="
                      display: grid;
                      grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
                      gap: 40px;
                    ">
                      #{(1..3).map { |i|
                        titles = language == :fa ? 
                          ['سرعت بالا', 'امنیت کامل', 'پشتیبانی ۲۴/۷'] :
                          ['High Speed', 'Complete Security', '24/7 Support']
                        descriptions = language == :fa ? 
                          ['عملکرد سریع و بهینه', 'امنیت داده‌های شما اولویت ماست', 'پشتیبانی در تمام ساعات شبانه روز'] :
                          ['Fast and optimized performance', 'Your data security is our priority', 'Support available around the clock']
                        
                        <<~FEATURE
                          <div style="
                            background: white;
                            padding: 40px 30px;
                            border-radius: 12px;
                            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
                            text-align: center;
                          ">
                            <div style="
                              width: 80px;
                              height: 80px;
                              background: linear-gradient(135deg, #667eea, #764ba2);
                              border-radius: 50%;
                              display: flex;
                              align-items: center;
                              justify-content: center;
                              margin: 0 auto 20px;
                              font-size: 2rem;
                            ">#{ ['⚡', '🔒', '🎧'][i-1] }</div>
                            <h3 style="margin: 0 0 15px 0; color: #495057;">#{ titles[i-1] }</h3>
                            <p style="color: #6c757d; line-height: 1.6;">#{ descriptions[i-1] }</p>
                          </div>
                        FEATURE
                      }.join}
                    </div>
                  </div>
                </section>
                
                <!-- CTA Section -->
                <section style="
                  background: linear-gradient(135deg, #28a745, #20c997);
                  color: white;
                  padding: 80px 20px;
                  text-align: center;
                ">
                  <div style="max-width: 800px; margin: 0 auto;">
                    <h2 style="font-size: 2.5rem; margin-bottom: 20px;">
                      #{language == :fa ? 'آماده شروع هستید؟' : 'Ready to Get Started?'}
                    </h2>
                    <p style="font-size: 1.3rem; margin-bottom: 40px; opacity: 0.9;">
                      #{language == :fa ? 'همین امروز به هزاران مشتری راضی بپیوندید' : 'Join thousands of satisfied customers today'}
                    </p>
                    <button style="
                      background: white;
                      color: #28a745;
                      padding: 15px 40px;
                      border: none;
                      border-radius: 50px;
                      font-size: 1.2rem;
                      font-weight: 600;
                      cursor: pointer;
                    ">#{language == :fa ? 'شروع کنید' : 'Get Started'}</button>
                  </div>
                </section>
              </div>
            HTML
          end
          
          def landing_page_css(language)
            <<~CSS
              * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
              }
              
              body {
                font-family: 'Arial', sans-serif;
                line-height: 1.6;
                color: #333;
                direction: #{dir_attr(language)};
              }
              
              .hero-section button:hover {
                transform: translateY(-2px);
                transition: transform 0.3s ease;
              }
              
              .feature-box:hover {
                transform: translateY(-5px);
                transition: transform 0.3s ease;
              }
              
              @media (max-width: 768px) {
                .hero-section h1 {
                  font-size: 2.5rem !important;
                }
                
                .hero-section p {
                  font-size: 1.1rem !important;
                }
                
                .hero-section button {
                  display: block;
                  width: 100%;
                  margin: 10px 0 !important;
                }
              }
            CSS
          end
          
          def business_template_content(language)
            company_name = language == :fa ? 'شرکت نمونه' : 'Sample Company'
            
            <<~HTML
              <div style="direction: #{dir_attr(language)};">
                <!-- Header -->
                <header style="
                  background: white;
                  padding: 20px;
                  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                  position: sticky;
                  top: 0;
                  z-index: 1000;
                ">
                  <nav style="
                    max-width: 1200px;
                    margin: 0 auto;
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                  ">
                    <h1 style="color: #007bff; font-size: 1.8rem;">#{company_name}</h1>
                    <div style="display: flex; gap: 30px;">
                      #{%w[Home About Services Contact].map { |item|
                        translated = language == :fa ? 
                          {'Home' => 'خانه', 'About' => 'درباره ما', 'Services' => 'خدمات', 'Contact' => 'تماس'}[item] : item
                        "<a href='#' style='text-decoration: none; color: #495057; font-weight: 500;'>#{translated}</a>"
                      }.join}
                    </div>
                  </nav>
                </header>
                
                <!-- About Section -->
                <section style="padding: 80px 20px;">
                  <div style="max-width: 1200px; margin: 0 auto; display: grid; grid-template-columns: 1fr 1fr; gap: 60px; align-items: center;">
                    <div>
                      <h2 style="font-size: 2.5rem; margin-bottom: 20px; color: #495057;">
                        #{language == :fa ? 'درباره شرکت ما' : 'About Our Company'}
                      </h2>
                      <p style="font-size: 1.1rem; line-height: 1.8; color: #6c757d; margin-bottom: 30px;">
                        #{language == :fa ? 
                          'ما با بیش از ۱۰ سال تجربه در صنعت، بهترین خدمات را به مشتریان خود ارائه می‌دهیم. تیم متخصص ما همواره در تلاش برای ارائه راه‌حل‌های نوآورانه است.' :
                          'With over 10 years of experience in the industry, we provide the best services to our clients. Our expert team is always striving to deliver innovative solutions.'
                        }
                      </p>
                      <button style="
                        background: #007bff;
                        color: white;
                        padding: 12px 30px;
                        border: none;
                        border-radius: 6px;
                        font-weight: 600;
                        cursor: pointer;
                      ">#{language == :fa ? 'بیشتر بخوانید' : 'Read More'}</button>
                    </div>
                    <div>
                      <img src="https://via.placeholder.com/500x400/007bff/ffffff?text=#{language == :fa ? 'تصویر+شرکت' : 'Company+Image'}" 
                           style="width: 100%; border-radius: 12px; box-shadow: 0 8px 25px rgba(0,0,0,0.15);">
                    </div>
                  </div>
                </section>
                
                <!-- Services Section -->
                <section style="padding: 80px 20px; background: #f8f9fa;">
                  <div style="max-width: 1200px; margin: 0 auto; text-align: center;">
                    <h2 style="font-size: 2.5rem; margin-bottom: 60px; color: #495057;">
                      #{language == :fa ? 'خدمات ما' : 'Our Services'}
                    </h2>
                    <div style="
                      display: grid;
                      grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
                      gap: 30px;
                    ">
                      #{(1..4).map { |i|
                        services = language == :fa ? 
                          ['مشاوره کسب و کار', 'طراحی و توسعه', 'بازاریابی دیجیتال', 'پشتیبانی فنی'] :
                          ['Business Consulting', 'Design & Development', 'Digital Marketing', 'Technical Support']
                        
                        <<~SERVICE
                          <div style="
                            background: white;
                            padding: 40px 30px;
                            border-radius: 12px;
                            text-align: center;
                            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
                          ">
                            <div style="
                              width: 70px;
                              height: 70px;
                              background: #007bff;
                              border-radius: 50%;
                              display: flex;
                              align-items: center;
                              justify-content: center;
                              margin: 0 auto 20px;
                              font-size: 1.8rem;
                              color: white;
                            ">#{ ['📊', '🎨', '📱', '🔧'][i-1] }</div>
                            <h3 style="margin: 0 0 15px 0; color: #495057;">#{ services[i-1] }</h3>
                            <p style="color: #6c757d; line-height: 1.6;">
                              #{language == :fa ? 'توضیح مختصر درباره این خدمات و مزایای آن.' : 'Brief description about this service and its benefits.'}
                            </p>
                          </div>
                        SERVICE
                      }.join}
                    </div>
                  </div>
                </section>
              </div>
            HTML
          end
          
          def business_template_css(language)
            <<~CSS
              * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
              }
              
              body {
                font-family: 'Arial', sans-serif;
                line-height: 1.6;
                color: #333;
                direction: #{dir_attr(language)};
              }
              
              nav a:hover {
                color: #007bff !important;
                transition: color 0.3s ease;
              }
              
              button:hover {
                transform: translateY(-2px);
                transition: transform 0.3s ease;
              }
              
              .service-card:hover {
                transform: translateY(-5px);
                transition: transform 0.3s ease;
              }
              
              @media (max-width: 768px) {
                nav {
                  flex-direction: column;
                  gap: 20px;
                }
                
                .about-grid {
                  grid-template-columns: 1fr !important;
                  gap: 40px !important;
                }
              }
            CSS
          end
          
          # Additional template content methods would continue here...
          # For brevity, I'll implement a few key ones and indicate where others would go
          
          def portfolio_template_content(language)
            # Portfolio template implementation
            "<!-- Portfolio template content for #{language} -->"
          end
          
          def portfolio_template_css(language)
            "/* Portfolio template CSS for #{language} */"
          end
          
          def blog_template_content(language)
            # Blog template implementation
            "<!-- Blog template content for #{language} -->"
          end
          
          def blog_template_css(language)
            "/* Blog template CSS for #{language} */"
          end
          
          def ecommerce_template_content(language)
            # E-commerce template implementation
            "<!-- E-commerce template content for #{language} -->"
          end
          
          def ecommerce_template_css(language)
            "/* E-commerce template CSS for #{language} */"
          end
          
          def agency_template_content(language)
            # Agency template implementation
            "<!-- Agency template content for #{language} -->"
          end
          
          def agency_template_css(language)
            "/* Agency template CSS for #{language} */"
          end
          
          def restaurant_template_content(language)
            # Restaurant template implementation
            "<!-- Restaurant template content for #{language} -->"
          end
          
          def restaurant_template_css(language)
            "/* Restaurant template CSS for #{language} */"
          end
          
          def personal_template_content(language)
            # Personal template implementation
            "<!-- Personal template content for #{language} -->"
          end
          
          def personal_template_css(language)
            "/* Personal template CSS for #{language} */"
          end
        end
      end
    end
  end
end