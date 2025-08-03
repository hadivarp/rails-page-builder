# frozen_string_literal: true

require_relative 'block_contents'

module Rails
  module Page
    module Builder
      class BlockLibrary
        include BlockContents
        class << self
          def all_blocks(language = :en)
            [
              *basic_blocks(language),
              *layout_blocks(language),
              *content_blocks(language),
              *marketing_blocks(language),
              *media_blocks(language),
              *form_blocks(language),
              *ecommerce_blocks(language),
              *advanced_blocks(language),
              *navigation_blocks(language),
              *interactive_blocks(language),
              *social_blocks(language)
            ]
          end
          
          def basic_blocks(language = :en)
            [
              {
                id: 'text',
                label: t('blocks.text', language),
                content: text_block_content(language),
                category: t('categories.basic', language),
                icon: '📝',
                attributes: { class: 'text-block' }
              },
              {
                id: 'heading',
                label: t('blocks.heading', language),
                content: heading_block_content(language),
                category: t('categories.basic', language),
                icon: '📰',
                attributes: { class: 'heading-block' }
              },
              {
                id: 'paragraph',
                label: t('blocks.paragraph', language),
                content: paragraph_block_content(language),
                category: t('categories.basic', language),
                icon: '📄',
                attributes: { class: 'paragraph-block' }
              }
            ]
          end
          
          def layout_blocks(language = :en)
            [
              {
                id: 'hero-section',
                label: t('blocks.hero_section', language),
                content: hero_section_content(language),
                category: t('categories.layout', language),
                icon: '🎯',
                attributes: { class: 'hero-section' }
              },
              {
                id: 'two-columns',
                label: t('blocks.two_columns', language),
                content: two_columns_content(language),
                category: t('categories.layout', language),
                icon: '📋',
                attributes: { class: 'two-columns' }
              },
              {
                id: 'three-columns',
                label: t('blocks.three_columns', language),
                content: three_columns_content(language),
                category: t('categories.layout', language),
                icon: '📊',
                attributes: { class: 'three-columns' }
              },
              {
                id: 'container',
                label: t('blocks.container', language),
                content: container_content(language),
                category: t('categories.layout', language),
                icon: '📦',
                attributes: { class: 'container-block' }
              }
            ]
          end
          
          def content_blocks(language = :en)
            [
              {
                id: 'feature-box',
                label: t('blocks.feature_box', language),
                content: feature_box_content(language),
                category: t('categories.content', language),
                icon: '⭐',
                attributes: { class: 'feature-box' }
              },
              {
                id: 'call-to-action',
                label: t('blocks.call_to_action', language),
                content: cta_content(language),
                category: t('categories.content', language),
                icon: '🎯',
                attributes: { class: 'call-to-action' }
              },
              {
                id: 'stats-counter',
                label: t('blocks.stats_counter', language),
                content: stats_counter_content(language),
                category: t('categories.content', language),
                icon: '📈',
                attributes: { class: 'stats-counter' }
              }
            ]
          end
          
          def marketing_blocks(language = :en)
            [
              {
                id: 'pricing-table',
                label: t('blocks.pricing_table', language),
                content: pricing_table_content(language),
                category: t('categories.marketing', language),
                icon: '💰',
                attributes: { class: 'pricing-table' }
              },
              {
                id: 'testimonial',
                label: t('blocks.testimonial', language),
                content: testimonial_content(language),
                category: t('categories.marketing', language),
                icon: '💬',
                attributes: { class: 'testimonial' }
              },
              {
                id: 'team-member',
                label: t('blocks.team_member', language),
                content: team_member_content(language),
                category: t('categories.marketing', language),
                icon: '👥',
                attributes: { class: 'team-member' }
              }
            ]
          end
          
          def media_blocks(language = :en)
            [
              {
                id: 'image-gallery',
                label: t('blocks.image_gallery', language),
                content: image_gallery_content(language),
                category: t('categories.media', language),
                icon: '🖼️',
                attributes: { class: 'image-gallery' }
              },
              {
                id: 'video-embed',
                label: t('blocks.video_embed', language),
                content: video_embed_content(language),
                category: t('categories.media', language),
                icon: '🎥',
                attributes: { class: 'video-embed' }
              },
              {
                id: 'image',
                label: t('blocks.image', language),
                content: image_content(language),
                category: t('categories.media', language),
                icon: '🖼️',
                attributes: { class: 'image-block' }
              }
            ]
          end
          
          def form_blocks(language = :en)
            [
              {
                id: 'contact-form',
                label: t('blocks.contact_form', language),
                content: contact_form_content(language),
                category: t('categories.forms', language),
                icon: '📧',
                attributes: { class: 'contact-form' }
              },
              {
                id: 'newsletter-signup',
                label: t('blocks.newsletter_signup', language),
                content: newsletter_signup_content(language),
                category: t('categories.forms', language),
                icon: '📮',
                attributes: { class: 'newsletter-signup' }
              },
              {
                id: 'button',
                label: t('blocks.button', language),
                content: button_content(language),
                category: t('categories.forms', language),
                icon: '🔘',
                attributes: { class: 'button-block' }
              }
            ]
          end
          
          def ecommerce_blocks(language = :en)
            [
              {
                id: 'product-card',
                label: t('blocks.product_card', language),
                content: product_card_content(language),
                category: t('categories.ecommerce', language),
                icon: '🛍️',
                attributes: { class: 'product-card' }
              },
              {
                id: 'product-grid',
                label: t('blocks.product_grid', language),
                content: product_grid_content(language),
                category: t('categories.ecommerce', language),
                icon: '📦',
                attributes: { class: 'product-grid' }
              },
              {
                id: 'shopping-cart',
                label: t('blocks.shopping_cart', language),
                content: shopping_cart_content(language),
                category: t('categories.ecommerce', language),
                icon: '🛒',
                attributes: { class: 'shopping-cart' }
              },
              {
                id: 'checkout-form',
                label: t('blocks.checkout_form', language),
                content: checkout_form_content(language),
                category: t('categories.ecommerce', language),
                icon: '💳',
                attributes: { class: 'checkout-form' }
              }
            ]
          end
          
          def advanced_blocks(language = :en)
            [
              {
                id: 'accordion',
                label: t('blocks.accordion', language),
                content: accordion_content(language),
                category: t('categories.advanced', language),
                icon: '📑',
                attributes: { class: 'accordion-block' }
              },
              {
                id: 'tabs',
                label: t('blocks.tabs', language),
                content: tabs_content(language),
                category: t('categories.advanced', language),
                icon: '📂',
                attributes: { class: 'tabs-block' }
              },
              {
                id: 'carousel',
                label: t('blocks.carousel', language),
                content: carousel_content(language),
                category: t('categories.advanced', language),
                icon: '🎠',
                attributes: { class: 'carousel-block' }
              },
              {
                id: 'modal',
                label: t('blocks.modal', language),
                content: modal_content(language),
                category: t('categories.advanced', language),
                icon: '🪟',
                attributes: { class: 'modal-block' }
              },
              {
                id: 'countdown-timer',
                label: t('blocks.countdown_timer', language),
                content: countdown_timer_content(language),
                category: t('categories.advanced', language),
                icon: '⏰',
                attributes: { class: 'countdown-timer' }
              },
              {
                id: 'progress-bar',
                label: t('blocks.progress_bar', language),
                content: progress_bar_content(language),
                category: t('categories.advanced', language),
                icon: '📊',
                attributes: { class: 'progress-bar' }
              },
              {
                id: 'social-feed',
                label: t('blocks.social_feed', language),
                content: social_feed_content(language),
                category: t('categories.advanced', language),
                icon: '📱',
                attributes: { class: 'social-feed' }
              }
            ]
          end
          
          private
          
          def t(key, language)
            translations = {
              en: {
                'blocks.text' => 'Text',
                'blocks.heading' => 'Heading',
                'blocks.paragraph' => 'Paragraph',
                'blocks.hero_section' => 'Hero Section',
                'blocks.two_columns' => 'Two Columns',
                'blocks.three_columns' => 'Three Columns',
                'blocks.container' => 'Container',
                'blocks.feature_box' => 'Feature Box',
                'blocks.call_to_action' => 'Call to Action',
                'blocks.stats_counter' => 'Stats Counter',
                'blocks.pricing_table' => 'Pricing Table',
                'blocks.testimonial' => 'Testimonial',
                'blocks.team_member' => 'Team Member',
                'blocks.image_gallery' => 'Image Gallery',
                'blocks.video_embed' => 'Video Embed',
                'blocks.image' => 'Image',
                'blocks.contact_form' => 'Contact Form',
                'blocks.newsletter_signup' => 'Newsletter Signup',
                'blocks.button' => 'Button',
                'blocks.product_card' => 'Product Card',
                'blocks.product_grid' => 'Product Grid',
                'blocks.shopping_cart' => 'Shopping Cart',
                'blocks.checkout_form' => 'Checkout Form',
                'blocks.accordion' => 'Accordion',
                'blocks.tabs' => 'Tabs',
                'blocks.carousel' => 'Carousel',
                'blocks.modal' => 'Modal',
                'blocks.countdown_timer' => 'Countdown Timer',
                'blocks.progress_bar' => 'Progress Bar',
                'blocks.social_feed' => 'Social Feed',
                'blocks.navbar' => 'Navigation Bar',
                'blocks.breadcrumb' => 'Breadcrumb',
                'blocks.sidebar_menu' => 'Sidebar Menu',
                'blocks.search_bar' => 'Search Bar',
                'blocks.rating_stars' => 'Rating Stars',
                'blocks.toggle_switch' => 'Toggle Switch',
                'blocks.social_icons' => 'Social Icons',
                'blocks.social_share' => 'Social Share',
                'blocks.comment_section' => 'Comment Section',
                'categories.basic' => 'Basic',
                'categories.layout' => 'Layout',
                'categories.content' => 'Content',
                'categories.marketing' => 'Marketing',
                'categories.media' => 'Media',
                'categories.forms' => 'Forms',
                'categories.ecommerce' => 'E-commerce',
                'categories.advanced' => 'Advanced',
                'categories.navigation' => 'Navigation',
                'categories.interactive' => 'Interactive',
                'categories.social' => 'Social'
              },
              fa: {
                'blocks.text' => 'متن',
                'blocks.heading' => 'عنوان',
                'blocks.paragraph' => 'پاراگراف',
                'blocks.hero_section' => 'بخش اصلی',
                'blocks.two_columns' => 'دو ستون',
                'blocks.three_columns' => 'سه ستون',
                'blocks.container' => 'ظرف',
                'blocks.feature_box' => 'جعبه ویژگی',
                'blocks.call_to_action' => 'فراخوان عمل',
                'blocks.stats_counter' => 'شمارنده آمار',
                'blocks.pricing_table' => 'جدول قیمت',
                'blocks.testimonial' => 'نظرات مشتریان',
                'blocks.team_member' => 'عضو تیم',
                'blocks.image_gallery' => 'گالری تصاویر',
                'blocks.video_embed' => 'ویدیو جاسازی',
                'blocks.image' => 'تصویر',
                'blocks.contact_form' => 'فرم تماس',
                'blocks.newsletter_signup' => 'عضویت خبرنامه',
                'blocks.button' => 'دکمه',
                'blocks.product_card' => 'کارت محصول',
                'blocks.product_grid' => 'شبکه محصول',
                'blocks.shopping_cart' => 'سبد خرید',
                'blocks.checkout_form' => 'فرم پرداخت',
                'blocks.accordion' => 'آکاردئون',
                'blocks.tabs' => 'تب‌ها',
                'blocks.carousel' => 'کروسل',
                'blocks.modal' => 'پنجره مودال',
                'blocks.countdown_timer' => 'شمارش معکوس',
                'blocks.progress_bar' => 'نوار پیشرفت',
                'blocks.social_feed' => 'فید اجتماعی',
                'blocks.navbar' => 'نوار ناوبری',
                'blocks.breadcrumb' => 'مسیر صفحه',
                'blocks.sidebar_menu' => 'منوی کناری',
                'blocks.search_bar' => 'نوار جستجو',
                'blocks.rating_stars' => 'ستاره‌های امتیاز',
                'blocks.toggle_switch' => 'کلید تغییر وضعیت',
                'blocks.social_icons' => 'آیکون‌های اجتماعی',
                'blocks.social_share' => 'اشتراک‌گذاری اجتماعی',
                'blocks.comment_section' => 'بخش نظرات',
                'categories.basic' => 'پایه',
                'categories.layout' => 'چیدمان',
                'categories.content' => 'محتوا',
                'categories.marketing' => 'بازاریابی',
                'categories.media' => 'رسانه',
                'categories.forms' => 'فرم',
                'categories.ecommerce' => 'فروشگاهی',
                'categories.advanced' => 'پیشرفته',
                'categories.navigation' => 'ناوبری',
                'categories.interactive' => 'تعاملی',
                'categories.social' => 'اجتماعی'
              },
              ar: {
                'blocks.text' => 'نص',
                'blocks.heading' => 'عنوان',
                'blocks.paragraph' => 'فقرة',
                'blocks.hero_section' => 'قسم البطل',
                'blocks.two_columns' => 'عمودان',
                'blocks.three_columns' => 'ثلاثة أعمدة',
                'blocks.container' => 'حاوية',
                'blocks.feature_box' => 'صندوق الميزة',
                'blocks.call_to_action' => 'دعوة للعمل',
                'blocks.stats_counter' => 'عداد الإحصائيات',
                'blocks.pricing_table' => 'جدول الأسعار',
                'blocks.testimonial' => 'شهادة',
                'blocks.team_member' => 'عضو الفريق',
                'blocks.image_gallery' => 'معرض الصور',
                'blocks.video_embed' => 'تضمين فيديو',
                'blocks.image' => 'صورة',
                'blocks.contact_form' => 'نموذج الاتصال',
                'blocks.newsletter_signup' => 'اشتراك النشرة',
                'blocks.button' => 'زر',
                'blocks.product_card' => 'بطاقة المنتج',
                'blocks.product_grid' => 'شبكة المنتجات',
                'blocks.shopping_cart' => 'سلة التسوق',
                'blocks.checkout_form' => 'نموذج الدفع',
                'blocks.accordion' => 'أكورديون',
                'blocks.tabs' => 'تبويبات',
                'blocks.carousel' => 'دوار',
                'blocks.modal' => 'نافذة منبثقة',
                'blocks.countdown_timer' => 'مؤقت العد التنازلي',
                'blocks.progress_bar' => 'شريط التقدم',
                'blocks.social_feed' => 'تغذية اجتماعية',
                'categories.basic' => 'أساسي',
                'categories.layout' => 'تخطيط',
                'categories.content' => 'محتوى',
                'categories.marketing' => 'تسويق',
                'categories.media' => 'وسائط',
                'categories.forms' => 'نماذج',
                'categories.ecommerce' => 'تجارة إلكترونية',
                'categories.advanced' => 'متقدم'
              },
              he: {
                'blocks.text' => 'טקסט',
                'blocks.heading' => 'כותרת',
                'blocks.paragraph' => 'פסקה',
                'blocks.hero_section' => 'קטע גיבור',
                'blocks.two_columns' => 'שתי עמודות',
                'blocks.three_columns' => 'שלוש עמודות',
                'blocks.container' => 'מכולה',
                'blocks.feature_box' => 'תיבת תכונה',
                'blocks.call_to_action' => 'קריאה לפעולה',
                'blocks.stats_counter' => 'מונה סטטיסטיקות',
                'blocks.pricing_table' => 'טבלת מחירים',
                'blocks.testimonial' => 'המלצה',
                'blocks.team_member' => 'חבר צוות',
                'blocks.image_gallery' => 'גלריית תמונות',
                'blocks.video_embed' => 'הטמעת וידאו',
                'blocks.image' => 'תמונה',
                'blocks.contact_form' => 'טופס יצירת קשר',
                'blocks.newsletter_signup' => 'הרשמה לניוזלטר',
                'blocks.button' => 'כפתור',
                'blocks.product_card' => 'כרטיס מוצר',
                'blocks.product_grid' => 'רשת מוצרים',
                'blocks.shopping_cart' => 'עגלת קניות',
                'blocks.checkout_form' => 'טופס תשלום',
                'blocks.accordion' => 'אקורדיון',
                'blocks.tabs' => 'לשוניות',
                'blocks.carousel' => 'קרוסלה',
                'blocks.modal' => 'חלון מודאלי',
                'blocks.countdown_timer' => 'טיימר ספירה לאחור',
                'blocks.progress_bar' => 'שורת התקדמות',
                'blocks.social_feed' => 'פיד חברתי',
                'categories.basic' => 'בסיסי',
                'categories.layout' => 'פריסה',
                'categories.content' => 'תוכן',
                'categories.marketing' => 'שיווק',
                'categories.media' => 'מדיה',
                'categories.forms' => 'טפסים',
                'categories.ecommerce' => 'מסחר אלקטרוני',
                'categories.advanced' => 'מתקדם'
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
          
          # Block content methods will be defined in separate file
          def text_block_content(language)
            rtl = rtl?(language)
            sample_text = language == :fa ? 'متن نمونه' : 'Sample text'
            
            <<~HTML
              <div class="text-block" style="padding: 10px; direction: #{dir_attr(language)}; text-align: #{text_align(language)};">
                #{sample_text}
              </div>
            HTML
          end
          
          def heading_block_content(language)
            rtl = rtl?(language)
            sample_heading = language == :fa ? 'عنوان نمونه' : 'Sample Heading'
            
            <<~HTML
              <h2 class="heading-block" style="margin: 10px 0; direction: #{dir_attr(language)}; text-align: #{text_align(language)};">
                #{sample_heading}
              </h2>
            HTML
          end
          
          def paragraph_block_content(language)
            sample_text = if language == :fa
              'این یک پاراگراف نمونه است که برای نمایش متن طولانی‌تر استفاده می‌شود.'
            else
              'This is a sample paragraph that can be used to display longer text content.'
            end
            
            <<~HTML
              <p class="paragraph-block" style="line-height: 1.6; margin: 15px 0; direction: #{dir_attr(language)}; text-align: #{text_align(language)};">
                #{sample_text}
              </p>
            HTML
          end
          
          def container_content(language)
            <<~HTML
              <div class="container-block" style="padding: 20px; border: 2px dashed #ccc; min-height: 100px; text-align: center; direction: #{dir_attr(language)};">
                #{language == :fa ? 'کانتینر - محتوای خود را اینجا بکشید' : 'Container - Drop your content here'}
              </div>
            HTML
          end

          # New block categories
          def navigation_blocks(language = :en)
            [
              {
                id: 'navbar',
                label: t('blocks.navbar', language),
                content: navbar_content(language),
                category: t('categories.navigation', language),
                icon: '🧭',
                attributes: { class: 'navbar-block' }
              },
              {
                id: 'breadcrumb',
                label: t('blocks.breadcrumb', language),
                content: breadcrumb_content(language),
                category: t('categories.navigation', language),
                icon: '🍞',
                attributes: { class: 'breadcrumb-block' }
              },
              {
                id: 'sidebar-menu',
                label: t('blocks.sidebar_menu', language),
                content: sidebar_menu_content(language),
                category: t('categories.navigation', language),
                icon: '📋',
                attributes: { class: 'sidebar-menu-block' }
              }
            ]
          end

          def interactive_blocks(language = :en)
            [
              {
                id: 'search-bar',
                label: t('blocks.search_bar', language),
                content: search_bar_content(language),
                category: t('categories.interactive', language),
                icon: '🔍',
                attributes: { class: 'search-bar-block' }
              },
              {
                id: 'rating-stars',
                label: t('blocks.rating_stars', language),
                content: rating_stars_content(language),
                category: t('categories.interactive', language),
                icon: '⭐',
                attributes: { class: 'rating-stars-block' }
              },
              {
                id: 'toggle-switch',
                label: t('blocks.toggle_switch', language),
                content: toggle_switch_content(language),
                category: t('categories.interactive', language),
                icon: '🔄',
                attributes: { class: 'toggle-switch-block' }
              }
            ]
          end

          def social_blocks(language = :en)
            [
              {
                id: 'social-icons',
                label: t('blocks.social_icons', language),
                content: social_icons_content(language),
                category: t('categories.social', language),
                icon: '📱',
                attributes: { class: 'social-icons-block' }
              },
              {
                id: 'social-share',
                label: t('blocks.social_share', language),
                content: social_share_content(language),
                category: t('categories.social', language),
                icon: '📤',
                attributes: { class: 'social-share-block' }
              },
              {
                id: 'comment-section',
                label: t('blocks.comment_section', language),
                content: comment_section_content(language),
                category: t('categories.social', language),
                icon: '💬',
                attributes: { class: 'comment-section-block' }
              }
            ]
          end

          # New block content methods
          def navbar_content(language)
            rtl = rtl?(language)
            text_dir = dir_attr(language)
            text_align = text_align(language)
            
            home_text = language == :fa ? 'خانه' : 'Home'
            about_text = language == :fa ? 'درباره ما' : 'About'
            contact_text = language == :fa ? 'تماس' : 'Contact'
            
            <<~HTML
              <nav class="navbar-block" style="background: #333; padding: 15px; direction: #{text_dir};">
                <div style="display: flex; justify-content: space-between; align-items: center; #{rtl ? 'flex-direction: row-reverse;' : ''}">
                  <div style="color: white; font-weight: bold; font-size: 18px;">#{language == :fa ? 'برند' : 'Brand'}</div>
                  <ul style="display: flex; list-style: none; margin: 0; padding: 0; gap: 20px; #{rtl ? 'flex-direction: row-reverse;' : ''}">
                    <li><a href="#" style="color: white; text-decoration: none;">#{home_text}</a></li>
                    <li><a href="#" style="color: white; text-decoration: none;">#{about_text}</a></li>
                    <li><a href="#" style="color: white; text-decoration: none;">#{contact_text}</a></li>
                  </ul>
                </div>
              </nav>
            HTML
          end

          def search_bar_content(language)
            placeholder = language == :fa ? 'جستجو کنید...' : 'Search...'
            button_text = language == :fa ? 'جستجو' : 'Search'
            
            <<~HTML
              <div class="search-bar-block" style="padding: 20px; direction: #{dir_attr(language)};">
                <div style="display: flex; max-width: 400px; margin: 0 auto;">
                  <input type="text" placeholder="#{placeholder}" style="flex: 1; padding: 12px; border: 2px solid #ddd; border-radius: 6px 0 0 6px; #{rtl?(language) ? 'border-radius: 0 6px 6px 0;' : ''}" />
                  <button style="padding: 12px 20px; background: #007bff; color: white; border: none; #{rtl?(language) ? 'border-radius: 6px 0 0 6px;' : 'border-radius: 0 6px 6px 0;'} cursor: pointer;">#{button_text}</button>
                </div>
              </div>
            HTML
          end

          def social_icons_content(language)
            <<~HTML
              <div class="social-icons-block" style="padding: 20px; text-align: center; direction: #{dir_attr(language)};">
                <div style="display: flex; justify-content: center; gap: 15px;">
                  <a href="#" style="color: #3b5998; font-size: 24px; text-decoration: none;">📘</a>
                  <a href="#" style="color: #1da1f2; font-size: 24px; text-decoration: none;">🐦</a>
                  <a href="#" style="color: #e1306c; font-size: 24px; text-decoration: none;">📷</a>
                  <a href="#" style="color: #0077b5; font-size: 24px; text-decoration: none;">💼</a>
                </div>
              </div>
            HTML
          end

          def rating_stars_content(language)
            rating_text = language == :fa ? 'امتیاز:' : 'Rating:'
            
            <<~HTML
              <div class="rating-stars-block" style="padding: 20px; text-align: center; direction: #{dir_attr(language)};">
                <div style="display: flex; align-items: center; justify-content: center; gap: 10px;">
                  <span>#{rating_text}</span>
                  <div style="display: flex; gap: 5px;">
                    <span style="color: #ffc107; font-size: 20px; cursor: pointer;">⭐</span>
                    <span style="color: #ffc107; font-size: 20px; cursor: pointer;">⭐</span>
                    <span style="color: #ffc107; font-size: 20px; cursor: pointer;">⭐</span>
                    <span style="color: #ffc107; font-size: 20px; cursor: pointer;">⭐</span>
                    <span style="color: #e9ecef; font-size: 20px; cursor: pointer;">⭐</span>
                  </div>
                  <span style="margin-#{rtl?(language) ? 'right' : 'left'}: 10px; color: #666;">4/5</span>
                </div>
              </div>
            HTML
          end

          def breadcrumb_content(language)
            home_text = language == :fa ? 'خانه' : 'Home'
            category_text = language == :fa ? 'دسته‌بندی' : 'Category'
            current_text = language == :fa ? 'صفحه فعلی' : 'Current Page'
            separator = rtl?(language) ? '‹' : '›'
            
            <<~HTML
              <div class="breadcrumb-block" style="padding: 15px; background: #f8f9fa; direction: #{dir_attr(language)};">
                <nav style="display: flex; align-items: center; gap: 10px; #{rtl?(language) ? 'flex-direction: row-reverse;' : ''}">
                  <a href="#" style="color: #007bff; text-decoration: none;">#{home_text}</a>
                  <span style="color: #6c757d;">#{separator}</span>
                  <a href="#" style="color: #007bff; text-decoration: none;">#{category_text}</a>
                  <span style="color: #6c757d;">#{separator}</span>
                  <span style="color: #6c757d;">#{current_text}</span>
                </nav>
              </div>
            HTML
          end

          def sidebar_menu_content(language)
            menu_items = if language == :fa
              ['داشبورد', 'پروفایل', 'تنظیمات', 'خروج']
            else
              ['Dashboard', 'Profile', 'Settings', 'Logout']
            end
            
            menu_html = menu_items.map do |item|
              "<li style='margin: 5px 0;'><a href='#' style='color: #333; text-decoration: none; display: block; padding: 8px 12px; border-radius: 4px;' onmouseover='this.style.background=\"#f8f9fa\"' onmouseout='this.style.background=\"transparent\"'>#{item}</a></li>"
            end.join
            
            <<~HTML
              <div class="sidebar-menu-block" style="width: 250px; background: white; border: 1px solid #dee2e6; border-radius: 8px; direction: #{dir_attr(language)};">
                <div style="padding: 15px; border-bottom: 1px solid #dee2e6; font-weight: bold; text-align: #{text_align(language)};">#{language == :fa ? 'منو' : 'Menu'}</div>
                <ul style="list-style: none; margin: 0; padding: 10px;">
                  #{menu_html}
                </ul>
              </div>
            HTML
          end

          def toggle_switch_content(language)
            label_text = language == :fa ? 'فعال/غیرفعال:' : 'Toggle:'
            
            <<~HTML
              <div class="toggle-switch-block" style="padding: 20px; direction: #{dir_attr(language)};">
                <div style="display: flex; align-items: center; gap: 10px;">
                  <label style="font-weight: 500;">#{label_text}</label>
                  <div style="position: relative; width: 50px; height: 24px; background: #ccc; border-radius: 12px; cursor: pointer;" onclick="this.classList.toggle('active'); this.style.background = this.classList.contains('active') ? '#007bff' : '#ccc';">
                    <div style="position: absolute; top: 2px; #{rtl?(language) ? 'right' : 'left'}: 2px; width: 20px; height: 20px; background: white; border-radius: 50%; transition: all 0.3s;"></div>
                  </div>
                </div>
              </div>
            HTML
          end

          def social_share_content(language)
            share_text = language == :fa ? 'اشتراک‌گذاری:' : 'Share:'
            
            <<~HTML
              <div class="social-share-block" style="padding: 20px; text-align: center; direction: #{dir_attr(language)};">
                <div style="display: flex; align-items: center; justify-content: center; gap: 15px; flex-wrap: wrap;">
                  <span style="font-weight: 500;">#{share_text}</span>
                  <button style="background: #3b5998; color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer;">Facebook</button>
                  <button style="background: #1da1f2; color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer;">Twitter</button>
                  <button style="background: #0077b5; color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer;">LinkedIn</button>
                  <button style="background: #25d366; color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer;">WhatsApp</button>
                </div>
              </div>
            HTML
          end

          def comment_section_content(language)
            title_text = language == :fa ? 'نظرات' : 'Comments'
            name_placeholder = language == :fa ? 'نام شما' : 'Your Name'
            comment_placeholder = language == :fa ? 'نظر خود را بنویسید...' : 'Write your comment...'
            submit_text = language == :fa ? 'ارسال نظر' : 'Submit Comment'
            
            <<~HTML
              <div class="comment-section-block" style="padding: 20px; direction: #{dir_attr(language)};">
                <h3 style="margin-bottom: 20px; text-align: #{text_align(language)};">#{title_text}</h3>
                <div style="background: #f8f9fa; padding: 15px; border-radius: 8px; margin-bottom: 20px;">
                  <div style="display: flex; gap: 15px; margin-bottom: 15px;">
                    <input type="text" placeholder="#{name_placeholder}" style="flex: 1; padding: 10px; border: 1px solid #ddd; border-radius: 4px;" />
                  </div>
                  <textarea placeholder="#{comment_placeholder}" style="width: 100%; height: 80px; padding: 10px; border: 1px solid #ddd; border-radius: 4px; resize: vertical; box-sizing: border-box;"></textarea>
                  <button style="margin-top: 10px; background: #007bff; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; float: #{rtl?(language) ? 'left' : 'right'};">#{submit_text}</button>
                  <div style="clear: both;"></div>
                </div>
                <div style="background: white; border: 1px solid #dee2e6; border-radius: 8px; padding: 15px;">
                  <div style="font-weight: bold; margin-bottom: 5px;">#{language == :fa ? 'کاربر نمونه' : 'Sample User'}</div>
                  <div style="color: #666; font-size: 14px; margin-bottom: 10px;">#{language == :fa ? '2 ساعت پیش' : '2 hours ago'}</div>
                  <p style="margin: 0; line-height: 1.5;">#{language == :fa ? 'این یک نظر نمونه است که نحوه نمایش نظرات را نشان می‌دهد.' : 'This is a sample comment showing how comments will be displayed.'}</p>
                </div>
              </div>
            HTML
          end
        end
      end
    end
  end
end