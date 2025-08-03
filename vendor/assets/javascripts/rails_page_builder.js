//= require grapesjs/grapesjs.min

(function() {
  'use strict';
  
  window.RailsPageBuilder = {
    editors: {},
    
    init: function(containerId, options) {
      const container = document.getElementById(containerId);
      if (!container) {
        console.error('Page builder container not found:', containerId);
        return null;
      }
      
      const defaultOptions = this.getDefaultOptions();
      const mergedOptions = Object.assign({}, defaultOptions, options);
      
      // Initialize GrapesJS
      const editor = grapesjs.init(Object.assign({
        container: container,
        fromElement: true,
        width: 'auto',
        storageManager: this.getStorageConfig(mergedOptions),
        blockManager: this.getBlockConfig(mergedOptions),
        styleManager: this.getStyleConfig(mergedOptions),
        layerManager: { appendTo: '.layers-container' },
        traitManager: { appendTo: '.traits-container' },
        selectorManager: { appendTo: '.styles-container' },
        panels: this.getPanelConfig(mergedOptions),
        deviceManager: this.getDeviceConfig(mergedOptions),
        commands: this.getCommandConfig(mergedOptions)
      }, mergedOptions));
      
      this.setupI18n(editor, mergedOptions.language);
      this.setupRTL(editor, mergedOptions.rtl);
      this.addCustomBlocks(editor, mergedOptions.customBlocks || []);
      
      this.editors[containerId] = editor;
      return editor;
    },
    
    getDefaultOptions: function() {
      return {
        height: '100vh',
        language: 'en',
        rtl: false,
        fromElement: true,
        width: 'auto',
        storageManager: {
          type: 'remote',
          stepsBeforeSave: 3,
          urlStore: '/page_builder/pages',
          urlLoad: '/page_builder/pages',
          contentTypeJson: true,
          credentials: 'include'
        }
      };
    },
    
    getStorageConfig: function(options) {
      if (!options.storageManager) return false;
      
      return {
        type: 'remote',
        stepsBeforeSave: 3,
        urlStore: options.urlStore || '/page_builder/pages',
        urlLoad: options.urlLoad || '/page_builder/pages',
        contentTypeJson: true,
        credentials: 'include',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')
        }
      };
    },
    
    getBlockConfig: function(options) {
      const blocks = this.getAdvancedBlocks(options.language);
      return { appendTo: '.blocks-container', blocks: blocks };
    },
    
    getAdvancedBlocks: function(language) {
      const isRTL = ['fa', 'ar', 'he', 'ur'].includes(language);
      const dir = isRTL ? 'rtl' : 'ltr';
      const textAlign = isRTL ? 'right' : 'left';
      
      return [
        // Basic Blocks
        {
          id: 'text',
          label: this.t('blocks.text', language),
          content: `<div class="text-block" style="padding: 10px; direction: ${dir}; text-align: ${textAlign};">${this.t('content.sample_text', language)}</div>`,
          category: this.t('categories.basic', language)
        },
        {
          id: 'heading',
          label: this.t('blocks.heading', language),
          content: `<h2 class="heading-block" style="margin: 10px 0; direction: ${dir}; text-align: ${textAlign};">${this.t('content.sample_heading', language)}</h2>`,
          category: this.t('categories.basic', language)
        },
        {
          id: 'paragraph',
          label: this.t('blocks.paragraph', language),
          content: `<p class="paragraph-block" style="line-height: 1.6; margin: 15px 0; direction: ${dir}; text-align: ${textAlign};">${this.t('content.sample_paragraph', language)}</p>`,
          category: this.t('categories.basic', language)
        },
        
        // Layout Blocks
        {
          id: 'hero-section',
          label: this.t('blocks.hero_section', language),
          content: this.getHeroSectionContent(language),
          category: this.t('categories.layout', language)
        },
        {
          id: 'two-columns',
          label: this.t('blocks.two_columns', language),
          content: this.getTwoColumnsContent(language),
          category: this.t('categories.layout', language)
        },
        {
          id: 'three-columns',
          label: this.t('blocks.three_columns', language),
          content: this.getThreeColumnsContent(language),
          category: this.t('categories.layout', language)
        },
        
        // Content Blocks
        {
          id: 'feature-box',
          label: this.t('blocks.feature_box', language),
          content: this.getFeatureBoxContent(language),
          category: this.t('categories.content', language)
        },
        {
          id: 'call-to-action',
          label: this.t('blocks.call_to_action', language),
          content: this.getCTAContent(language),
          category: this.t('categories.content', language)
        },
        
        // Marketing Blocks
        {
          id: 'pricing-table',
          label: this.t('blocks.pricing_table', language),
          content: this.getPricingTableContent(language),
          category: this.t('categories.marketing', language)
        },
        {
          id: 'testimonial',
          label: this.t('blocks.testimonial', language),
          content: this.getTestimonialContent(language),
          category: this.t('categories.marketing', language)
        },
        
        // Media Blocks
        {
          id: 'image',
          label: this.t('blocks.image', language),
          content: '<img src="https://via.placeholder.com/300x200" alt="Image" class="image-block" style="max-width: 100%; height: auto;"/>',
          category: this.t('categories.media', language)
        },
        {
          id: 'image-gallery',
          label: this.t('blocks.image_gallery', language),
          content: this.getImageGalleryContent(language),
          category: this.t('categories.media', language)
        },
        
        // Form Blocks
        {
          id: 'contact-form',
          label: this.t('blocks.contact_form', language),
          content: this.getContactFormContent(language),
          category: this.t('categories.forms', language)
        },
        {
          id: 'button',
          label: this.t('blocks.button', language),
          content: `<div style="text-align: center; margin: 20px 0;"><button style="background: #007bff; color: white; border: none; padding: 12px 24px; border-radius: 6px; cursor: pointer;">${this.t('blocks.button', language)}</button></div>`,
          category: this.t('categories.forms', language)
        },
        
        // Container
        {
          id: 'container',
          label: this.t('blocks.container', language),
          content: `<div class="container-block" style="padding: 20px; border: 2px dashed #ccc; min-height: 100px; text-align: center; direction: ${dir};">${this.t('content.container_placeholder', language)}</div>`,
          category: this.t('categories.layout', language)
        }
      ];
    },
    
    getStyleConfig: function(options) {
      return {
        appendTo: '.styles-container',
        sectors: [
          {
            name: this.t('style.dimension', options.language),
            open: false,
            properties: ['width', 'height', 'max-width', 'min-height', 'margin', 'padding']
          },
          {
            name: this.t('style.typography', options.language),
            open: false,
            properties: ['font-family', 'font-size', 'font-weight', 'letter-spacing', 'color', 'line-height', 'text-align', 'text-decoration', 'text-shadow']
          },
          {
            name: this.t('style.decorations', options.language),
            open: false,
            properties: ['opacity', 'background-color', 'background-image', 'border-radius', 'border', 'box-shadow', 'background']
          },
          {
            name: this.t('style.extra', options.language),
            open: false,
            properties: ['transition', 'perspective', 'transform']
          }
        ]
      };
    },
    
    getPanelConfig: function(options) {
      return {
        defaults: [
          {
            id: 'layers',
            el: '.panel__right',
            resizable: {
              maxDim: 350,
              minDim: 200,
              tc: 0,
              cl: 1,
              cr: 0,
              bc: 0,
              keyWidth: 'flex-basis',
            },
          },
          {
            id: 'panel-switcher',
            el: '.panel__switcher',
            buttons: [
              {
                id: 'show-layers',
                active: true,
                label: this.t('panels.layers', options.language),
                command: 'show-layers',
                togglable: false,
              },
              {
                id: 'show-style',
                active: true,
                label: this.t('panels.styles', options.language),
                command: 'show-styles',
                togglable: false,
              },
              {
                id: 'show-traits',
                active: true,
                label: this.t('panels.traits', options.language),
                command: 'show-traits',
                togglable: false,
              }
            ],
          }
        ]
      };
    },
    
    getDeviceConfig: function(options) {
      return {
        devices: [
          {
            name: this.t('devices.desktop', options.language),
            width: '',
          },
          {
            name: this.t('devices.tablet', options.language),
            width: '768px',
            widthMedia: '992px',
          },
          {
            name: this.t('devices.mobile', options.language),
            width: '320px',
            widthMedia: '768px',
          }
        ]
      };
    },
    
    getCommandConfig: function(options) {
      return {
        defaults: [
          {
            id: 'show-layers',
            run: function(editor) {
              editor.getContainer().querySelector('.layers-container').style.display = 'block';
              editor.getContainer().querySelector('.styles-container').style.display = 'none';
              editor.getContainer().querySelector('.traits-container').style.display = 'none';
            }
          },
          {
            id: 'show-styles',
            run: function(editor) {
              editor.getContainer().querySelector('.layers-container').style.display = 'none';
              editor.getContainer().querySelector('.styles-container').style.display = 'block';
              editor.getContainer().querySelector('.traits-container').style.display = 'none';
            }
          },
          {
            id: 'show-traits',
            run: function(editor) {
              editor.getContainer().querySelector('.layers-container').style.display = 'none';
              editor.getContainer().querySelector('.styles-container').style.display = 'none';
              editor.getContainer().querySelector('.traits-container').style.display = 'block';
            }
          }
        ]
      };
    },
    
    setupI18n: function(editor, language) {
      // Add language-specific configurations
      if (language === 'fa') {
        editor.I18n.addMessages({
          fa: {
            domComponents: {
              names: {
                '': 'جعبه',
                wrapper: 'بدنه',
                text: 'متن',
                comment: 'نظر',
                image: 'تصویر',
                video: 'ویدیو',
                label: 'برچسب',
                link: 'لینک',
                map: 'نقشه',
                tfoot: 'پایین جدول',
                tbody: 'بدنه جدول',
                thead: 'سر جدول',
                table: 'جدول',
                row: 'سطر جدول',
                cell: 'خانه جدول'
              }
            },
            deviceManager: {
              device: 'دستگاه',
              devices: {
                desktop: 'دسکتاپ',
                tablet: 'تبلت',
                mobileLandscape: 'موبایل افقی',
                mobilePortrait: 'موبایل عمودی'
              }
            },
            panels: {
              buttons: {
                titles: {
                  preview: 'پیش‌نمایش',
                  fullscreen: 'تمام صفحه',
                  'sw-visibility': 'نمایش اجزا',
                  'export-template': 'مشاهده کد',
                  'open-sm': 'باز کردن مدیر استایل',
                  'open-tm': 'تنظیمات',
                  'open-layers': 'باز کردن مدیر لایه',
                  'open-blocks': 'باز کردن بلوک‌ها'
                }
              }
            }
          }
        });
        editor.I18n.setLocale('fa');
      }
    },
    
    setupRTL: function(editor, isRTL) {
      if (isRTL) {
        editor.on('load', function() {
          const iframe = editor.Canvas.getFrameEl();
          if (iframe && iframe.contentDocument) {
            iframe.contentDocument.body.style.direction = 'rtl';
            iframe.contentDocument.documentElement.style.direction = 'rtl';
          }
        });
      }
    },
    
    addCustomBlocks: function(editor, customBlocks) {
      const blockManager = editor.BlockManager;
      customBlocks.forEach(function(block) {
        blockManager.add(block.id, block);
      });
    },
    
    // Block content methods
    getHeroSectionContent: function(language) {
      const isRTL = ['fa', 'ar', 'he', 'ur'].includes(language);
      const title = language === 'fa' ? 'عنوان اصلی خود را اینجا بنویسید' : 'Write Your Main Headline Here';
      const subtitle = language === 'fa' ? 'زیرعنوان توضیحی برای جذب مخاطب' : 'An engaging subtitle to capture your audience';
      const buttonText = language === 'fa' ? 'شروع کنید' : 'Get Started';
      
      return `
        <section class="hero-section" style="
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          color: white;
          padding: 80px 20px;
          text-align: center;
          min-height: 500px;
          display: flex;
          align-items: center;
          justify-content: center;
          direction: ${isRTL ? 'rtl' : 'ltr'};
        ">
          <div class="hero-content" style="max-width: 800px;">
            <h1 style="font-size: 3.5rem; margin-bottom: 20px; font-weight: 700;">${title}</h1>
            <p style="font-size: 1.25rem; margin-bottom: 30px; opacity: 0.9;">${subtitle}</p>
            <button style="
              background: #fff;
              color: #667eea;
              padding: 15px 30px;
              border: none;
              border-radius: 50px;
              font-size: 1.1rem;
              font-weight: 600;
              cursor: pointer;
            ">${buttonText}</button>
          </div>
        </section>
      `;
    },
    
    getTwoColumnsContent: function(language) {
      const isRTL = ['fa', 'ar', 'he', 'ur'].includes(language);
      const leftContent = language === 'fa' ? 'محتوای ستون چپ' : 'Left Column Content';
      const rightContent = language === 'fa' ? 'محتوای ستون راست' : 'Right Column Content';
      
      return `
        <div class="two-columns" style="
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 30px;
          padding: 20px;
          direction: ${isRTL ? 'rtl' : 'ltr'};
        ">
          <div class="column" style="padding: 20px; background: #f8f9fa; border-radius: 8px;">
            <h3>${leftContent}</h3>
            <p>${language === 'fa' ? 'محتوای ستون اول اینجا قرار می‌گیرد.' : 'First column content goes here.'}</p>
          </div>
          <div class="column" style="padding: 20px; background: #f8f9fa; border-radius: 8px;">
            <h3>${rightContent}</h3>
            <p>${language === 'fa' ? 'محتوای ستون دوم اینجا قرار می‌گیرد.' : 'Second column content goes here.'}</p>
          </div>
        </div>
      `;
    },
    
    getThreeColumnsContent: function(language) {
      const isRTL = ['fa', 'ar', 'he', 'ur'].includes(language);
      
      return `
        <div class="three-columns" style="
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
          gap: 20px;
          padding: 20px;
          direction: ${isRTL ? 'rtl' : 'ltr'};
        ">
          ${[1,2,3].map(i => {
            const title = language === 'fa' ? `ستون ${i}` : `Column ${i}`;
            const content = language === 'fa' ? `محتوای ستون ${i} اینجا قرار می‌گیرد.` : `Column ${i} content goes here.`;
            return `
              <div class="column" style="
                padding: 20px;
                background: #fff;
                border: 1px solid #e9ecef;
                border-radius: 8px;
                text-align: ${isRTL ? 'right' : 'left'};
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
              ">
                <h4 style="margin-top: 0; color: #495057;">${title}</h4>
                <p style="color: #6c757d; line-height: 1.6;">${content}</p>
              </div>
            `;
          }).join('')}
        </div>
      `;
    },
    
    getFeatureBoxContent: function(language) {
      const title = language === 'fa' ? 'ویژگی فوق‌العاده' : 'Amazing Feature';
      const description = language === 'fa' ? 'توضیح مختصر در مورد این ویژگی و مزایای آن برای کاربران.' : 'Brief description about this feature and its benefits for users.';
      
      return `
        <div class="feature-box" style="
          background: white;
          padding: 30px;
          border-radius: 8px;
          text-align: center;
          box-shadow: 0 2px 10px rgba(0,0,0,0.1);
          direction: ${['fa', 'ar', 'he', 'ur'].includes(language) ? 'rtl' : 'ltr'};
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
          ">⭐</div>
          <h3 style="margin: 0 0 15px 0; color: #495057;">${title}</h3>
          <p style="color: #6c757d; line-height: 1.6; margin: 0;">${description}</p>
        </div>
      `;
    },
    
    getCTAContent: function(language) {
      const title = language === 'fa' ? 'آماده شروع هستید؟' : 'Ready to Get Started?';
      const subtitle = language === 'fa' ? 'همین امروز به هزاران کاربر راضی بپیوندید' : 'Join thousands of satisfied users today';
      const buttonText = language === 'fa' ? 'شروع رایگان' : 'Start Free Trial';
      
      return `
        <div class="call-to-action" style="
          background: linear-gradient(135deg, #28a745, #20c997);
          color: white;
          padding: 60px 40px;
          text-align: center;
          border-radius: 12px;
          margin: 40px 0;
          direction: ${['fa', 'ar', 'he', 'ur'].includes(language) ? 'rtl' : 'ltr'};
        ">
          <h2 style="margin: 0 0 15px 0; font-size: 2.5rem; font-weight: 700;">${title}</h2>
          <p style="margin: 0 0 30px 0; font-size: 1.2rem; opacity: 0.9;">${subtitle}</p>
          <button style="
            background: white;
            color: #28a745;
            border: none;
            padding: 15px 40px;
            border-radius: 50px;
            font-size: 1.1rem;
            font-weight: 600;
            cursor: pointer;
          ">${buttonText}</button>
        </div>
      `;
    },
    
    getPricingTableContent: function(language) {
      const plans = language === 'fa' ? [
        { name: 'پایه', price: '۱۹$', features: ['ویژگی ۱', 'ویژگی ۲', 'ویژگی ۳'] },
        { name: 'حرفه‌ای', price: '۴۹$', features: ['همه ویژگی‌های پایه', 'ویژگی پیشرفته ۱', 'ویژگی پیشرفته ۲'], popular: true },
        { name: 'سازمانی', price: '۹۹$', features: ['همه ویژگی‌های حرفه‌ای', 'پشتیبانی اختصاصی', 'تنظیمات سفارشی'] }
      ] : [
        { name: 'Basic', price: '$19', features: ['Feature 1', 'Feature 2', 'Feature 3'] },
        { name: 'Pro', price: '$49', features: ['All Basic features', 'Advanced Feature 1', 'Advanced Feature 2'], popular: true },
        { name: 'Enterprise', price: '$99', features: ['All Pro features', 'Priority Support', 'Custom Setup'] }
      ];
      
      return `
        <div class="pricing-table" style="
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
          gap: 20px;
          padding: 40px 20px;
          direction: ${['fa', 'ar', 'he', 'ur'].includes(language) ? 'rtl' : 'ltr'};
        ">
          ${plans.map(plan => {
            const popularBadge = plan.popular ? 
              `<div style='background: #28a745; color: white; padding: 5px 15px; border-radius: 20px; font-size: 0.8rem; position: absolute; top: -10px; left: 50%; transform: translateX(-50%);'>${language === 'fa' ? 'محبوب' : 'Popular'}</div>` : "";
            
            return `
              <div class="pricing-plan" style="
                background: white;
                border: ${plan.popular ? '2px solid #28a745' : '1px solid #e9ecef'};
                border-radius: 12px;
                padding: 30px 20px;
                text-align: center;
                position: relative;
                box-shadow: 0 4px 6px rgba(0,0,0,0.1);
              ">
                ${popularBadge}
                <h3 style="margin: 0 0 10px 0; color: #495057;">${plan.name}</h3>
                <div style="font-size: 2.5rem; font-weight: 700; color: #28a745; margin: 20px 0;">${plan.price}</div>
                <p style="color: #6c757d; margin-bottom: 30px;">${language === 'fa' ? 'در ماه' : 'per month'}</p>
                <ul style="list-style: none; padding: 0; margin: 20px 0;">
                  ${plan.features.map(feature => 
                    `<li style='padding: 8px 0; border-bottom: 1px solid #f8f9fa;'>✓ ${feature}</li>`
                  ).join('')}
                </ul>
                <button style="
                  background: ${plan.popular ? '#28a745' : '#007bff'};
                  color: white;
                  border: none;
                  padding: 12px 30px;
                  border-radius: 6px;
                  font-weight: 600;
                  cursor: pointer;
                  width: 100%;
                  margin-top: 20px;
                ">${language === 'fa' ? 'انتخاب طرح' : 'Choose Plan'}</button>
              </div>
            `;
          }).join('')}
        </div>
      `;
    },
    
    getTestimonialContent: function(language) {
      const testimonialText = language === 'fa' ? 
        'این محصول واقعاً فوق‌العاده است و تجربه کاری ما را بهبود بخشیده است.' :
        'This product is absolutely amazing and has improved our workflow significantly.';
      
      const authorName = language === 'fa' ? 'علی احمدی' : 'John Smith';
      const authorTitle = language === 'fa' ? 'مدیر محصول' : 'Product Manager';
      
      return `
        <div class="testimonial" style="
          background: white;
          padding: 40px;
          border-radius: 12px;
          box-shadow: 0 4px 20px rgba(0,0,0,0.1);
          max-width: 600px;
          margin: 20px auto;
          text-align: center;
          direction: ${['fa', 'ar', 'he', 'ur'].includes(language) ? 'rtl' : 'ltr'};
        ">
          <div style="font-size: 3rem; color: #007bff; margin-bottom: 20px;">"</div>
          <p style="
            font-size: 1.2rem;
            line-height: 1.8;
            color: #495057;
            margin-bottom: 30px;
            font-style: italic;
          ">${testimonialText}</p>
          <div style="display: flex; align-items: center; justify-content: center; gap: 15px;">
            <img src="https://via.placeholder.com/60x60/007bff/ffffff?text=👤" style="border-radius: 50%; width: 60px; height: 60px;">
            <div style="text-align: ${['fa', 'ar', 'he', 'ur'].includes(language) ? 'right' : 'left'};">
              <div style="font-weight: 600; color: #495057;">${authorName}</div>
              <div style="color: #6c757d; font-size: 0.9rem;">${authorTitle}</div>
            </div>
          </div>
        </div>
      `;
    },
    
    getImageGalleryContent: function(language) {
      return `
        <div class="image-gallery" style="
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
          gap: 15px;
          padding: 20px;
          direction: ${['fa', 'ar', 'he', 'ur'].includes(language) ? 'rtl' : 'ltr'};
        ">
          ${[1,2,3,4,5,6].map(i => `
            <div style="
              position: relative;
              overflow: hidden;
              border-radius: 8px;
            ">
              <img src="https://via.placeholder.com/300x200/${['007bff', '28a745', 'dc3545', 'ffc107', '17a2b8', '6f42c1'][i-1]}/ffffff?text=Image+${i}" 
                   style="width: 100%; height: 200px; object-fit: cover; display: block;">
            </div>
          `).join('')}
        </div>
      `;
    },
    
    getContactFormContent: function(language) {
      const formTitle = language === 'fa' ? 'تماس با ما' : 'Contact Us';
      const namePlaceholder = language === 'fa' ? 'نام شما' : 'Your Name';
      const emailPlaceholder = language === 'fa' ? 'ایمیل شما' : 'Your Email';
      const messagePlaceholder = language === 'fa' ? 'پیام شما' : 'Your Message';
      const submitText = language === 'fa' ? 'ارسال پیام' : 'Send Message';
      
      const isRTL = ['fa', 'ar', 'he', 'ur'].includes(language);
      
      return `
        <div class="contact-form" style="
          background: white;
          padding: 40px;
          border-radius: 12px;
          box-shadow: 0 4px 20px rgba(0,0,0,0.1);
          max-width: 600px;
          margin: 0 auto;
          direction: ${isRTL ? 'rtl' : 'ltr'};
        ">
          <h3 style="margin: 0 0 30px 0; text-align: center; color: #495057;">${formTitle}</h3>
          <form>
            <div style="margin-bottom: 20px;">
              <input type="text" placeholder="${namePlaceholder}" style="
                width: 100%;
                padding: 12px;
                border: 1px solid #dee2e6;
                border-radius: 6px;
                font-size: 1rem;
                direction: ${isRTL ? 'rtl' : 'ltr'};
                text-align: ${isRTL ? 'right' : 'left'};
              ">
            </div>
            <div style="margin-bottom: 20px;">
              <input type="email" placeholder="${emailPlaceholder}" style="
                width: 100%;
                padding: 12px;
                border: 1px solid #dee2e6;
                border-radius: 6px;
                font-size: 1rem;
                direction: ${isRTL ? 'rtl' : 'ltr'};
                text-align: ${isRTL ? 'right' : 'left'};
              ">
            </div>
            <div style="margin-bottom: 20px;">
              <textarea placeholder="${messagePlaceholder}" rows="5" style="
                width: 100%;
                padding: 12px;
                border: 1px solid #dee2e6;
                border-radius: 6px;
                font-size: 1rem;
                resize: vertical;
                direction: ${isRTL ? 'rtl' : 'ltr'};
                text-align: ${isRTL ? 'right' : 'left'};
              "></textarea>
            </div>
            <button type="submit" style="
              background: #007bff;
              color: white;
              border: none;
              padding: 12px 30px;
              border-radius: 6px;
              font-size: 1rem;
              font-weight: 600;
              cursor: pointer;
              width: 100%;
            ">${submitText}</button>
          </form>
        </div>
      `;
    },
    
    t: function(key, language) {
      const translations = {
        en: {
          'blocks.text': 'Text',
          'blocks.image': 'Image',
          'blocks.heading': 'Heading',
          'blocks.paragraph': 'Paragraph',
          'blocks.button': 'Button',
          'blocks.container': 'Container',
          'blocks.hero_section': 'Hero Section',
          'blocks.two_columns': 'Two Columns',
          'blocks.three_columns': 'Three Columns',
          'blocks.feature_box': 'Feature Box',
          'blocks.call_to_action': 'Call to Action',
          'blocks.pricing_table': 'Pricing Table',
          'blocks.testimonial': 'Testimonial',
          'blocks.image_gallery': 'Image Gallery',
          'blocks.contact_form': 'Contact Form',
          'categories.basic': 'Basic',
          'categories.media': 'Media',
          'categories.forms': 'Forms',
          'categories.layout': 'Layout',
          'categories.content': 'Content',
          'categories.marketing': 'Marketing',
          'content.sample_text': 'Sample text',
          'content.sample_heading': 'Sample Heading',
          'content.sample_paragraph': 'This is a sample paragraph that can be used to display longer text content.',
          'content.container_placeholder': 'Container - Drop your content here',
          'style.dimension': 'Dimension',
          'style.typography': 'Typography',
          'style.decorations': 'Decorations',
          'style.extra': 'Extra',
          'panels.layers': 'Layers',
          'panels.styles': 'Styles',
          'panels.traits': 'Traits',
          'devices.desktop': 'Desktop',
          'devices.tablet': 'Tablet',
          'devices.mobile': 'Mobile'
        },
        fa: {
          'blocks.text': 'متن',
          'blocks.image': 'تصویر',
          'blocks.heading': 'عنوان',
          'blocks.paragraph': 'پاراگراف',
          'blocks.button': 'دکمه',
          'blocks.container': 'ظرف',
          'blocks.hero_section': 'بخش اصلی',
          'blocks.two_columns': 'دو ستون',
          'blocks.three_columns': 'سه ستون',
          'blocks.feature_box': 'جعبه ویژگی',
          'blocks.call_to_action': 'فراخوان عمل',
          'blocks.pricing_table': 'جدول قیمت',
          'blocks.testimonial': 'نظرات مشتریان',
          'blocks.image_gallery': 'گالری تصاویر',
          'blocks.contact_form': 'فرم تماس',
          'categories.basic': 'پایه',
          'categories.media': 'رسانه',
          'categories.forms': 'فرم',
          'categories.layout': 'چیدمان',
          'categories.content': 'محتوا',
          'categories.marketing': 'بازاریابی',
          'content.sample_text': 'متن نمونه',
          'content.sample_heading': 'عنوان نمونه',
          'content.sample_paragraph': 'این یک پاراگراف نمونه است که برای نمایش متن طولانی‌تر استفاده می‌شود.',
          'content.container_placeholder': 'کانتینر - محتوای خود را اینجا بکشید',
          'style.dimension': 'ابعاد',
          'style.typography': 'تایپوگرافی',
          'style.decorations': 'تزئینات',
          'style.extra': 'اضافی',
          'panels.layers': 'لایه‌ها',
          'panels.styles': 'استایل‌ها',
          'panels.traits': 'خصوصیات',
          'devices.desktop': 'دسکتاپ',
          'devices.tablet': 'تبلت',
          'devices.mobile': 'موبایل'
        }
      };
      
      return translations[language] && translations[language][key] || key;
    }
  };
  
  // Auto-initialize page builders
  document.addEventListener('DOMContentLoaded', function() {
    const containers = document.querySelectorAll('[data-page-builder-options]');
    containers.forEach(function(container) {
      const options = JSON.parse(container.getAttribute('data-page-builder-options'));
      RailsPageBuilder.init(container.id, options);
    });
  });
})();