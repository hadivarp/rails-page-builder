# frozen_string_literal: true

module Rails
  module Page
    module Builder
      module BlockContents
        def self.included(base)
          base.extend(ClassMethods)
        end
        
        module ClassMethods
          def hero_section_content(language)
            title = language == :fa ? 'عنوان اصلی خود را اینجا بنویسید' : 'Write Your Main Headline Here'
            subtitle = language == :fa ? 'زیرعنوان توضیحی برای جذب مخاطب' : 'An engaging subtitle to capture your audience'
            button_text = language == :fa ? 'شروع کنید' : 'Get Started'
            
            <<~HTML
              <section class="hero-section" style="
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                padding: 80px 20px;
                text-align: center;
                min-height: 500px;
                display: flex;
                align-items: center;
                justify-content: center;
                direction: #{dir_attr(language)};
              ">
                <div class="hero-content" style="max-width: 800px;">
                  <h1 style="font-size: 3.5rem; margin-bottom: 20px; font-weight: 700;">#{title}</h1>
                  <p style="font-size: 1.25rem; margin-bottom: 30px; opacity: 0.9;">#{subtitle}</p>
                  <button style="
                    background: #fff;
                    color: #667eea;
                    padding: 15px 30px;
                    border: none;
                    border-radius: 50px;
                    font-size: 1.1rem;
                    font-weight: 600;
                    cursor: pointer;
                    transition: transform 0.3s ease;
                  " onmouseover="this.style.transform='translateY(-2px)'" onmouseout="this.style.transform='translateY(0)'">
                    #{button_text}
                  </button>
                </div>
              </section>
            HTML
          end
          
          def two_columns_content(language)
            left_content = language == :fa ? 'محتوای ستون چپ' : 'Left Column Content'
            right_content = language == :fa ? 'محتوای ستون راست' : 'Right Column Content'
            
            <<~HTML
              <div class="two-columns" style="
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 30px;
                padding: 20px;
                direction: #{dir_attr(language)};
              ">
                <div class="column" style="
                  padding: 20px;
                  background: #f8f9fa;
                  border-radius: 8px;
                  text-align: #{text_align(language)};
                ">
                  <h3 style="margin-top: 0;">#{left_content}</h3>
                  <p>#{language == :fa ? 'محتوای ستون اول اینجا قرار می‌گیرد.' : 'First column content goes here.'}</p>
                </div>
                <div class="column" style="
                  padding: 20px;
                  background: #f8f9fa;
                  border-radius: 8px;
                  text-align: #{text_align(language)};
                ">
                  <h3 style="margin-top: 0;">#{right_content}</h3>
                  <p>#{language == :fa ? 'محتوای ستون دوم اینجا قرار می‌گیرد.' : 'Second column content goes here.'}</p>
                </div>
              </div>
            HTML
          end
          
          def three_columns_content(language)
            <<~HTML
              <div class="three-columns" style="
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
                gap: 20px;
                padding: 20px;
                direction: #{dir_attr(language)};
              ">
                #{(1..3).map { |i| 
                  title = language == :fa ? "ستون #{i}" : "Column #{i}"
                  content = language == :fa ? "محتوای ستون #{i} اینجا قرار می‌گیرد." : "Column #{i} content goes here."
                  
                  <<~COLUMN
                    <div class="column" style="
                      padding: 20px;
                      background: #fff;
                      border: 1px solid #e9ecef;
                      border-radius: 8px;
                      text-align: #{text_align(language)};
                      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                    ">
                      <h4 style="margin-top: 0; color: #495057;">#{title}</h4>
                      <p style="color: #6c757d; line-height: 1.6;">#{content}</p>
                    </div>
                  COLUMN
                }.join}
              </div>
            HTML
          end
          
          def pricing_table_content(language)
            plans = if language == :fa
              [
                { name: 'پایه', price: '۱۹', features: ['ویژگی ۱', 'ویژگی ۲', 'ویژگی ۳'] },
                { name: 'حرفه‌ای', price: '۴۹', features: ['همه ویژگی‌های پایه', 'ویژگی پیشرفته ۱', 'ویژگی پیشرفته ۲'], popular: true },
                { name: 'سازمانی', price: '۹۹', features: ['همه ویژگی‌های حرفه‌ای', 'پشتیبانی اختصاصی', 'تنظیمات سفارشی'] }
              ]
            else
              [
                { name: 'Basic', price: '$19', features: ['Feature 1', 'Feature 2', 'Feature 3'] },
                { name: 'Pro', price: '$49', features: ['All Basic features', 'Advanced Feature 1', 'Advanced Feature 2'], popular: true },
                { name: 'Enterprise', price: '$99', features: ['All Pro features', 'Priority Support', 'Custom Setup'] }
              ]
            end
            
            <<~HTML
              <div class="pricing-table" style="
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
                gap: 20px;
                padding: 40px 20px;
                direction: #{dir_attr(language)};
              ">
                #{plans.map { |plan|
                  popular_badge = plan[:popular] ? 
                    "<div style='background: #28a745; color: white; padding: 5px 15px; border-radius: 20px; font-size: 0.8rem; position: absolute; top: -10px; #{language == :fa ? 'right' : 'left'}: 50%; transform: translateX(-50%);'>#{language == :fa ? 'محبوب' : 'Popular'}</div>" : ""
                  
                  <<~PLAN
                    <div class="pricing-plan" style="
                      background: white;
                      border: #{plan[:popular] ? '2px solid #28a745' : '1px solid #e9ecef'};
                      border-radius: 12px;
                      padding: 30px 20px;
                      text-align: center;
                      position: relative;
                      box-shadow: 0 4px 6px rgba(0,0,0,0.1);
                      transition: transform 0.3s ease;
                    " onmouseover="this.style.transform='translateY(-5px)'" onmouseout="this.style.transform='translateY(0)'">
                      #{popular_badge}
                      <h3 style="margin: 0 0 10px 0; color: #495057;"># {plan[:name]}</h3>
                      <div style="font-size: 2.5rem; font-weight: 700; color: #28a745; margin: 20px 0;">#{plan[:price]}</div>
                      <p style="color: #6c757d; margin-bottom: 30px;">#{language == :fa ? 'در ماه' : 'per month'}</p>
                      <ul style="list-style: none; padding: 0; margin: 20px 0;">
                        #{plan[:features].map { |feature| 
                          "<li style='padding: 8px 0; border-bottom: 1px solid #f8f9fa;'>✓ #{feature}</li>"
                        }.join}
                      </ul>
                      <button style="
                        background: #{plan[:popular] ? '#28a745' : '#007bff'};
                        color: white;
                        border: none;
                        padding: 12px 30px;
                        border-radius: 6px;
                        font-weight: 600;
                        cursor: pointer;
                        width: 100%;
                        margin-top: 20px;
                      ">#{language == :fa ? 'انتخاب طرح' : 'Choose Plan'}</button>
                    </div>
                  PLAN
                }.join}
              </div>
            HTML
          end
          
          def testimonial_content(language)
            testimonial_text = language == :fa ? 
              'این محصول واقعاً فوق‌العاده است و تجربه کاری ما را بهبود بخشیده است.' :
              'This product is absolutely amazing and has improved our workflow significantly.'
            
            author_name = language == :fa ? 'علی احمدی' : 'John Smith'
            author_title = language == :fa ? 'مدیر محصول' : 'Product Manager'
            
            <<~HTML
              <div class="testimonial" style="
                background: white;
                padding: 40px;
                border-radius: 12px;
                box-shadow: 0 4px 20px rgba(0,0,0,0.1);
                max-width: 600px;
                margin: 20px auto;
                text-align: center;
                direction: #{dir_attr(language)};
              ">
                <div style="font-size: 3rem; color: #007bff; margin-bottom: 20px;">"</div>
                <p style="
                  font-size: 1.2rem;
                  line-height: 1.8;
                  color: #495057;
                  margin-bottom: 30px;
                  font-style: italic;
                ">#{testimonial_text}</p>
                <div style="display: flex; align-items: center; justify-content: center; gap: 15px;">
                  <img src="https://via.placeholder.com/60x60/007bff/ffffff?text=👤" style="border-radius: 50%; width: 60px; height: 60px;">
                  <div style="text-align: #{text_align(language)};">
                    <div style="font-weight: 600; color: #495057;">#{author_name}</div>
                    <div style="color: #6c757d; font-size: 0.9rem;">#{author_title}</div>
                  </div>
                </div>
              </div>
            HTML
          end
          
          def feature_box_content(language)
            title = language == :fa ? 'ویژگی فوق‌العاده' : 'Amazing Feature'
            description = language == :fa ? 
              'توضیح مختصر در مورد این ویژگی و مزایای آن برای کاربران.' :
              'Brief description about this feature and its benefits for users.'
            
            <<~HTML
              <div class="feature-box" style="
                background: white;
                padding: 30px;
                border-radius: 8px;
                text-align: center;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                transition: transform 0.3s ease;
                direction: #{dir_attr(language)};
              " onmouseover="this.style.transform='translateY(-5px)'" onmouseout="this.style.transform='translateY(0)'">
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
                <h3 style="margin: 0 0 15px 0; color: #495057;">#{title}</h3>
                <p style="color: #6c757d; line-height: 1.6; margin: 0;">#{description}</p>
              </div>
            HTML
          end
          
          def cta_content(language)
            title = language == :fa ? 'آماده شروع هستید؟' : 'Ready to Get Started?'
            subtitle = language == :fa ? 'همین امروز به هزاران کاربر راضی بپیوندید' : 'Join thousands of satisfied users today'
            button_text = language == :fa ? 'شروع رایگان' : 'Start Free Trial'
            
            <<~HTML
              <div class="call-to-action" style="
                background: linear-gradient(135deg, #28a745, #20c997);
                color: white;
                padding: 60px 40px;
                text-align: center;
                border-radius: 12px;
                margin: 40px 0;
                direction: #{dir_attr(language)};
              ">
                <h2 style="margin: 0 0 15px 0; font-size: 2.5rem; font-weight: 700;">#{title}</h2>
                <p style="margin: 0 0 30px 0; font-size: 1.2rem; opacity: 0.9;">#{subtitle}</p>
                <button style="
                  background: white;
                  color: #28a745;
                  border: none;
                  padding: 15px 40px;
                  border-radius: 50px;
                  font-size: 1.1rem;
                  font-weight: 600;
                  cursor: pointer;
                  transition: transform 0.3s ease;
                " onmouseover="this.style.transform='translateY(-2px)'" onmouseout="this.style.transform='translateY(0)'">
                  #{button_text}
                </button>
              </div>
            HTML
          end
          
          def stats_counter_content(language)
            stats = if language == :fa
              [
                { number: '۱۰۰۰+', label: 'مشتری راضی' },
                { number: '۵۰+', label: 'پروژه موفق' },
                { number: '۲۴/۷', label: 'پشتیبانی' },
                { number: '۹۹%', label: 'رضایت مندی' }
              ]
            else
              [
                { number: '1000+', label: 'Happy Customers' },
                { number: '50+', label: 'Successful Projects' },
                { number: '24/7', label: 'Support' },
                { number: '99%', label: 'Satisfaction' }
              ]
            end
            
            <<~HTML
              <div class="stats-counter" style="
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 30px;
                padding: 40px 20px;
                background: #f8f9fa;
                direction: #{dir_attr(language)};
              ">
                #{stats.map { |stat|
                  <<~STAT
                    <div class="stat-item" style="text-align: center;">
                      <div style="
                        font-size: 3rem;
                        font-weight: 700;
                        color: #007bff;
                        margin-bottom: 10px;
                        font-family: 'Arial', sans-serif;
                      ">#{stat[:number]}</div>
                      <div style="
                        color: #6c757d;
                        font-weight: 600;
                        text-transform: uppercase;
                        letter-spacing: 1px;
                        font-size: 0.9rem;
                      ">#{stat[:label]}</div>
                    </div>
                  STAT
                }.join}
              </div>
            HTML
          end
          
          def contact_form_content(language)
            form_title = language == :fa ? 'تماس با ما' : 'Contact Us'
            name_placeholder = language == :fa ? 'نام شما' : 'Your Name'
            email_placeholder = language == :fa ? 'ایمیل شما' : 'Your Email'
            message_placeholder = language == :fa ? 'پیام شما' : 'Your Message'
            submit_text = language == :fa ? 'ارسال پیام' : 'Send Message'
            
            <<~HTML
              <div class="contact-form" style="
                background: white;
                padding: 40px;
                border-radius: 12px;
                box-shadow: 0 4px 20px rgba(0,0,0,0.1);
                max-width: 600px;
                margin: 0 auto;
                direction: #{dir_attr(language)};
              ">
                <h3 style="margin: 0 0 30px 0; text-align: center; color: #495057;">#{form_title}</h3>
                <form>
                  <div style="margin-bottom: 20px;">
                    <input type="text" placeholder="#{name_placeholder}" style="
                      width: 100%;
                      padding: 12px;
                      border: 1px solid #dee2e6;
                      border-radius: 6px;
                      font-size: 1rem;
                      direction: #{dir_attr(language)};
                      text-align: #{text_align(language)};
                    ">
                  </div>
                  <div style="margin-bottom: 20px;">
                    <input type="email" placeholder="#{email_placeholder}" style="
                      width: 100%;
                      padding: 12px;
                      border: 1px solid #dee2e6;
                      border-radius: 6px;
                      font-size: 1rem;
                      direction: #{dir_attr(language)};
                      text-align: #{text_align(language)};
                    ">
                  </div>
                  <div style="margin-bottom: 20px;">
                    <textarea placeholder="#{message_placeholder}" rows="5" style="
                      width: 100%;
                      padding: 12px;
                      border: 1px solid #dee2e6;
                      border-radius: 6px;
                      font-size: 1rem;
                      resize: vertical;
                      direction: #{dir_attr(language)};
                      text-align: #{text_align(language)};
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
                  ">#{submit_text}</button>
                </form>
              </div>
            HTML
          end
          
          def image_gallery_content(language)
            <<~HTML
              <div class="image-gallery" style="
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
                gap: 15px;
                padding: 20px;
                direction: #{dir_attr(language)};
              ">
                #{(1..6).map { |i|
                  <<~IMAGE
                    <div style="
                      position: relative;
                      overflow: hidden;
                      border-radius: 8px;
                      transition: transform 0.3s ease;
                    " onmouseover="this.style.transform='scale(1.05)'" onmouseout="this.style.transform='scale(1)'">
                      <img src="https://via.placeholder.com/300x200/#{['007bff', '28a745', 'dc3545', 'ffc107', '17a2b8', '6f42c1'][i-1]}/ffffff?text=Image+#{i}" 
                           style="width: 100%; height: 200px; object-fit: cover; display: block;">
                    </div>
                  IMAGE
                }.join}
              </div>
            HTML
          end
          
          def video_embed_content(language)
            <<~HTML
              <div class="video-embed" style="
                position: relative;
                width: 100%;
                max-width: 800px;
                margin: 20px auto;
                background: #000;
                border-radius: 8px;
                overflow: hidden;
                direction: #{dir_attr(language)};
              ">
                <div style="
                  position: relative;
                  padding-bottom: 56.25%;
                  height: 0;
                  overflow: hidden;
                ">
                  <div style="
                    position: absolute;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    background: linear-gradient(45deg, #667eea, #764ba2);
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    color: white;
                    font-size: 4rem;
                  ">▶️</div>
                </div>
                <p style="
                  text-align: center;
                  margin: 15px 0;
                  color: #6c757d;
                ">#{language == :fa ? 'جای‌گزین کننده ویدیو - URL ویدیو خود را اینجا قرار دهید' : 'Video Placeholder - Replace with your video URL'}</p>
              </div>
            HTML
          end
          
          def image_content(language)
            <<~HTML
              <div class="image-block" style="text-align: center; margin: 20px 0;">
                <img src="https://via.placeholder.com/600x400/007bff/ffffff?text=#{language == :fa ? 'تصویر+نمونه' : 'Sample+Image'}" 
                     alt="#{language == :fa ? 'تصویر نمونه' : 'Sample Image'}"
                     style="max-width: 100%; height: auto; border-radius: 8px; box-shadow: 0 4px 8px rgba(0,0,0,0.1);">
              </div>
            HTML
          end
          
          def newsletter_signup_content(language)
            title = language == :fa ? 'عضویت در خبرنامه' : 'Subscribe to Newsletter'
            subtitle = language == :fa ? 'آخرین اخبار و بروزرسانی‌ها را دریافت کنید' : 'Get the latest news and updates'
            placeholder = language == :fa ? 'ایمیل شما' : 'Your email address'
            button_text = language == :fa ? 'عضویت' : 'Subscribe'
            
            <<~HTML
              <div class="newsletter-signup" style="
                background: linear-gradient(135deg, #667eea, #764ba2);
                color: white;
                padding: 40px;
                border-radius: 12px;
                text-align: center;
                margin: 20px 0;
                direction: #{dir_attr(language)};
              ">
                <h3 style="margin: 0 0 10px 0; font-size: 1.8rem;">#{title}</h3>
                <p style="margin: 0 0 25px 0; opacity: 0.9;">#{subtitle}</p>
                <form style="display: flex; gap: 10px; max-width: 400px; margin: 0 auto; flex-wrap: wrap;">
                  <input type="email" placeholder="#{placeholder}" style="
                    flex: 1;
                    min-width: 250px;
                    padding: 12px;
                    border: none;
                    border-radius: 6px;
                    font-size: 1rem;
                    direction: #{dir_attr(language)};
                    text-align: #{text_align(language)};
                  ">
                  <button type="submit" style="
                    background: #28a745;
                    color: white;
                    border: none;
                    padding: 12px 20px;
                    border-radius: 6px;
                    font-weight: 600;
                    cursor: pointer;
                    white-space: nowrap;
                  ">#{button_text}</button>
                </form>
              </div>
            HTML
          end
          
          def button_content(language)
            button_text = language == :fa ? 'دکمه' : 'Button'
            
            <<~HTML
              <div class="button-block" style="text-align: center; margin: 20px 0;">
                <button style="
                  background: #007bff;
                  color: white;
                  border: none;
                  padding: 12px 24px;
                  border-radius: 6px;
                  font-size: 1rem;
                  font-weight: 600;
                  cursor: pointer;
                  transition: background-color 0.3s ease;
                " onmouseover="this.style.backgroundColor='#0056b3'" onmouseout="this.style.backgroundColor='#007bff'">
                  #{button_text}
                </button>
              </div>
            HTML
          end
          
          def team_member_content(language)
            name = language == :fa ? 'نام عضو تیم' : 'Team Member Name'
            position = language == :fa ? 'سمت' : 'Position'
            bio = language == :fa ? 'توضیح مختصر درباره عضو تیم و تخصص‌های وی.' : 'Brief description about the team member and their expertise.'
            
            <<~HTML
              <div class="team-member" style="
                background: white;
                padding: 30px;
                border-radius: 12px;
                text-align: center;
                box-shadow: 0 4px 20px rgba(0,0,0,0.1);
                max-width: 300px;
                margin: 20px auto;
                direction: #{dir_attr(language)};
              ">
                <img src="https://via.placeholder.com/150x150/007bff/ffffff?text=👤" style="
                  width: 120px;
                  height: 120px;
                  border-radius: 50%;
                  margin: 0 auto 20px;
                  display: block;
                  object-fit: cover;
                ">
                <h4 style="margin: 0 0 5px 0; color: #495057; font-size: 1.3rem;">#{name}</h4>
                <p style="margin: 0 0 15px 0; color: #007bff; font-weight: 600;">#{position}</p>
                <p style="margin: 0; color: #6c757d; line-height: 1.6; font-size: 0.9rem;">#{bio}</p>
                <div style="margin-top: 20px; display: flex; justify-content: center; gap: 10px;">
                  <a href="#" style="color: #007bff; text-decoration: none; font-size: 1.2rem;">📧</a>
                  <a href="#" style="color: #007bff; text-decoration: none; font-size: 1.2rem;">🔗</a>
                  <a href="#" style="color: #007bff; text-decoration: none; font-size: 1.2rem;">📱</a>
                </div>
              </div>
            HTML
          end
          
          def product_card_content(language)
            name = language == :fa ? 'نام محصول' : 'Product Name'
            price = language == :fa ? '۹۹,۰۰۰ تومان' : '$99.00'
            description = language == :fa ? 'توضیح مختصر محصول و ویژگی‌های آن.' : 'Brief product description and its features.'
            button_text = language == :fa ? 'افزودن به سبد' : 'Add to Cart'
            
            <<~HTML
              <div class="product-card" style="
                background: white;
                border: 1px solid #e9ecef;
                border-radius: 12px;
                overflow: hidden;
                max-width: 300px;
                margin: 20px auto;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                transition: transform 0.3s ease;
                direction: #{dir_attr(language)};
              " onmouseover="this.style.transform='translateY(-5px)'" onmouseout="this.style.transform='translateY(0)'">
                <img src="https://via.placeholder.com/300x200/007bff/ffffff?text=#{language == :fa ? 'محصول' : 'Product'}" style="
                  width: 100%;
                  height: 200px;
                  object-fit: cover;
                  display: block;
                ">
                <div style="padding: 20px;">
                  <h4 style="margin: 0 0 10px 0; color: #495057;">#{name}</h4>
                  <p style="margin: 0 0 15px 0; color: #6c757d; font-size: 0.9rem; line-height: 1.5;">#{description}</p>
                  <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
                    <span style="font-size: 1.5rem; font-weight: 700; color: #28a745;">#{price}</span>
                    <div style="color: #ffc107;">★★★★★</div>
                  </div>
                  <button style="
                    background: #007bff;
                    color: white;
                    border: none;
                    padding: 10px 20px;
                    border-radius: 6px;
                    width: 100%;
                    font-weight: 600;
                    cursor: pointer;
                  ">#{button_text}</button>
                </div>
              </div>
            HTML
          end
          
          def product_grid_content(language)
            <<~HTML
              <div class="product-grid" style="
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
                gap: 20px;
                padding: 20px;
                direction: #{dir_attr(language)};
              ">
                #{(1..4).map { |i|
                  name = language == :fa ? "محصول #{i}" : "Product #{i}"
                  price = language == :fa ? "#{i * 50},۰۰۰ تومان" : "$#{i * 25}.00"
                  
                  <<~PRODUCT
                    <div style="
                      background: white;
                      border: 1px solid #e9ecef;
                      border-radius: 8px;
                      overflow: hidden;
                      transition: transform 0.3s ease;
                    " onmouseover="this.style.transform='translateY(-5px)'" onmouseout="this.style.transform='translateY(0)'">
                      <img src="https://via.placeholder.com/250x150/#{['007bff', '28a745', 'dc3545', 'ffc107'][i-1]}/ffffff?text=#{name}" style="
                        width: 100%;
                        height: 150px;
                        object-fit: cover;
                      ">
                      <div style="padding: 15px;">
                        <h5 style="margin: 0 0 8px 0;">#{name}</h5>
                        <p style="margin: 0 0 10px 0; color: #28a745; font-weight: 600;">#{price}</p>
                        <button style="
                          background: #007bff;
                          color: white;
                          border: none;
                          padding: 8px 16px;
                          border-radius: 4px;
                          width: 100%;
                          cursor: pointer;
                        ">#{language == :fa ? 'مشاهده' : 'View'}</button>
                      </div>
                    </div>
                  PRODUCT
                }.join}
              </div>
            HTML
          end
          
          # Advanced blocks content methods
          def shopping_cart_content(language)
            title = language == :fa ? 'سبد خرید' : 'Shopping Cart'
            empty_message = language == :fa ? 'سبد خرید شما خالی است' : 'Your cart is empty'
            continue_shopping = language == :fa ? 'ادامه خرید' : 'Continue Shopping'
            
            <<~HTML
              <div class="shopping-cart" style="
                background: white;
                border: 1px solid #e9ecef;
                border-radius: 12px;
                padding: 30px;
                max-width: 600px;
                margin: 20px auto;
                direction: #{dir_attr(language)};
              ">
                <h3 style="margin: 0 0 20px 0; color: #495057; text-align: center;">#{title}</h3>
                <div style="
                  text-align: center;
                  padding: 40px 20px;
                  color: #6c757d;
                ">
                  <div style="font-size: 3rem; margin-bottom: 15px;">🛒</div>
                  <p style="margin: 0 0 20px 0;">#{empty_message}</p>
                  <button style="
                    background: #007bff;
                    color: white;
                    border: none;
                    padding: 12px 24px;
                    border-radius: 6px;
                    font-weight: 600;
                    cursor: pointer;
                  ">#{continue_shopping}</button>
                </div>
              </div>
            HTML
          end
          
          def checkout_form_content(language)
            title = language == :fa ? 'تسویه حساب' : 'Checkout'
            
            <<~HTML
              <div class="checkout-form" style="
                background: white;
                border: 1px solid #e9ecef;
                border-radius: 12px;
                padding: 30px;
                max-width: 800px;
                margin: 20px auto;
                direction: #{dir_attr(language)};
              ">
                <h3 style="margin: 0 0 30px 0; color: #495057; text-align: center;">#{title}</h3>
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 30px;">
                  <div>
                    <h4 style="margin: 0 0 15px 0; color: #495057;">#{language == :fa ? 'اطلاعات پرداخت' : 'Billing Information'}</h4>
                    <form>
                      <input type="text" placeholder="#{language == :fa ? 'نام کامل' : 'Full Name'}" style="width: 100%; padding: 12px; margin-bottom: 15px; border: 1px solid #dee2e6; border-radius: 6px; direction: #{dir_attr(language)};">
                      <input type="email" placeholder="#{language == :fa ? 'ایمیل' : 'Email'}" style="width: 100%; padding: 12px; margin-bottom: 15px; border: 1px solid #dee2e6; border-radius: 6px; direction: #{dir_attr(language)};">
                      <input type="text" placeholder="#{language == :fa ? 'آدرس' : 'Address'}" style="width: 100%; padding: 12px; margin-bottom: 15px; border: 1px solid #dee2e6; border-radius: 6px; direction: #{dir_attr(language)};">
                    </form>
                  </div>
                  <div>
                    <h4 style="margin: 0 0 15px 0; color: #495057;">#{language == :fa ? 'خلاصه سفارش' : 'Order Summary'}</h4>
                    <div style="background: #f8f9fa; padding: 20px; border-radius: 8px;">
                      <div style="display: flex; justify-content: space-between; margin-bottom: 10px;">
                        <span>#{language == :fa ? 'جمع کل:' : 'Total:'}</span>
                        <strong>#{language == :fa ? '۲۵۰,۰۰۰ تومان' : '$250.00'}</strong>
                      </div>
                      <button style="
                        background: #28a745;
                        color: white;
                        border: none;
                        padding: 15px;
                        width: 100%;
                        border-radius: 6px;
                        font-weight: 600;
                        cursor: pointer;
                        margin-top: 15px;
                      ">#{language == :fa ? 'تکمیل خرید' : 'Complete Purchase'}</button>
                    </div>
                  </div>
                </div>
              </div>
            HTML
          end
          
          def accordion_content(language)
            items = if language == :fa
              [
                { title: 'سوال اول', content: 'پاسخ سوال اول اینجا قرار می‌گیرد.' },
                { title: 'سوال دوم', content: 'پاسخ سوال دوم اینجا قرار می‌گیرد.' },
                { title: 'سوال سوم', content: 'پاسخ سوال سوم اینجا قرار می‌گیرد.' }
              ]
            else
              [
                { title: 'First Question', content: 'Answer to the first question goes here.' },
                { title: 'Second Question', content: 'Answer to the second question goes here.' },
                { title: 'Third Question', content: 'Answer to the third question goes here.' }
              ]
            end
            
            <<~HTML
              <div class="accordion-block" style="
                max-width: 800px;
                margin: 20px auto;
                direction: #{dir_attr(language)};
              ">
                #{items.map.with_index { |item, index|
                  <<~ITEM
                    <div style="border: 1px solid #e9ecef; border-radius: 8px; margin-bottom: 10px; overflow: hidden;">
                      <div style="
                        background: #f8f9fa;
                        padding: 15px 20px;
                        cursor: pointer;
                        font-weight: 600;
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                      " onclick="
                        var content = this.nextElementSibling;
                        var icon = this.querySelector('.accordion-icon');
                        if (content.style.display === 'none' || content.style.display === '') {
                          content.style.display = 'block';
                          icon.innerHTML = '−';
                        } else {
                          content.style.display = 'none';
                          icon.innerHTML = '+';
                        }
                      ">
                        <span>#{item[:title]}</span>
                        <span class="accordion-icon" style="font-size: 1.2rem; color: #007bff;">#{index == 0 ? '−' : '+'}</span>
                      </div>
                      <div style="padding: 15px 20px; background: white; #{index == 0 ? '' : 'display: none;'}">
                        #{item[:content]}
                      </div>
                    </div>
                  ITEM
                }.join}
              </div>
            HTML
          end
          
          def tabs_content(language)
            tabs = if language == :fa
              [
                { id: 'tab1', title: 'تب اول', content: 'محتوای تب اول اینجا قرار می‌گیرد.' },
                { id: 'tab2', title: 'تب دوم', content: 'محتوای تب دوم اینجا قرار می‌گیرد.' },
                { id: 'tab3', title: 'تب سوم', content: 'محتوای تب سوم اینجا قرار می‌گیرد.' }
              ]
            else
              [
                { id: 'tab1', title: 'Tab 1', content: 'Content for tab 1 goes here.' },
                { id: 'tab2', title: 'Tab 2', content: 'Content for tab 2 goes here.' },
                { id: 'tab3', title: 'Tab 3', content: 'Content for tab 3 goes here.' }
              ]
            end
            
            <<~HTML
              <div class="tabs-block" style="
                max-width: 800px;
                margin: 20px auto;
                direction: #{dir_attr(language)};
              ">
                <div style="
                  display: flex;
                  border-bottom: 2px solid #e9ecef;
                  margin-bottom: 20px;
                ">
                  #{tabs.map.with_index { |tab, index|
                    <<~TAB_BUTTON
                      <button style="
                        background: #{index == 0 ? '#007bff' : 'transparent'};
                        color: #{index == 0 ? 'white' : '#007bff'};
                        border: none;
                        padding: 12px 20px;
                        cursor: pointer;
                        font-weight: 600;
                        border-radius: 6px 6px 0 0;
                        margin-#{language == :fa ? 'left' : 'right'}: 5px;
                      " onclick="
                        // Hide all tab contents
                        var contents = document.querySelectorAll('.tab-content');
                        contents.forEach(function(content) { content.style.display = 'none'; });
                        
                        // Reset all tab buttons
                        var buttons = this.parentNode.querySelectorAll('button');
                        buttons.forEach(function(btn) {
                          btn.style.background = 'transparent';
                          btn.style.color = '#007bff';
                        });
                        
                        // Show selected tab content
                        document.getElementById('#{tab[:id]}').style.display = 'block';
                        
                        // Highlight selected tab button
                        this.style.background = '#007bff';
                        this.style.color = 'white';
                      ">#{tab[:title]}</button>
                    TAB_BUTTON
                  }.join}
                </div>
                #{tabs.map.with_index { |tab, index|
                  <<~TAB_CONTENT
                    <div id="#{tab[:id]}" class="tab-content" style="
                      padding: 20px;
                      background: #f8f9fa;
                      border-radius: 8px;
                      #{index == 0 ? '' : 'display: none;'}
                    ">
                      #{tab[:content]}
                    </div>
                  TAB_CONTENT
                }.join}
              </div>
            HTML
          end
          
          def carousel_content(language)
            images = (1..3).map { |i| 
              {
                url: "https://via.placeholder.com/800x400/#{['007bff', '28a745', 'dc3545'][i-1]}/ffffff?text=Slide+#{i}",
                title: language == :fa ? "اسلاید #{i}" : "Slide #{i}",
                description: language == :fa ? "توضیح اسلاید #{i}" : "Description for slide #{i}"
              }
            }
            
            <<~HTML
              <div class="carousel-block" style="
                position: relative;
                max-width: 800px;
                margin: 20px auto;
                border-radius: 12px;
                overflow: hidden;
                direction: #{dir_attr(language)};
              ">
                <div class="carousel-inner">
                  #{images.map.with_index { |image, index|
                    <<~SLIDE
                      <div class="carousel-slide" style="
                        #{index == 0 ? '' : 'display: none;'}
                        position: relative;
                      ">
                        <img src="#{image[:url]}" style="width: 100%; height: 400px; object-fit: cover;">
                        <div style="
                          position: absolute;
                          bottom: 0;
                          left: 0;
                          right: 0;
                          background: linear-gradient(transparent, rgba(0,0,0,0.7));
                          color: white;
                          padding: 30px 20px 20px;
                          text-align: center;
                        ">
                          <h3 style="margin: 0 0 10px 0;">#{image[:title]}</h3>
                          <p style="margin: 0; opacity: 0.9;">#{image[:description]}</p>
                        </div>
                      </div>
                    SLIDE
                  }.join}
                </div>
                <button style="
                  position: absolute;
                  top: 50%;
                  #{language == :fa ? 'right' : 'left'}: 10px;
                  transform: translateY(-50%);
                  background: rgba(0,0,0,0.5);
                  color: white;
                  border: none;
                  padding: 10px 15px;
                  border-radius: 50%;
                  cursor: pointer;
                " onclick="previousSlide()">#{language == :fa ? '❯' : '❮'}</button>
                <button style="
                  position: absolute;
                  top: 50%;
                  #{language == :fa ? 'left' : 'right'}: 10px;
                  transform: translateY(-50%);
                  background: rgba(0,0,0,0.5);
                  color: white;
                  border: none;
                  padding: 10px 15px;
                  border-radius: 50%;
                  cursor: pointer;
                " onclick="nextSlide()">#{language == :fa ? '❮' : '❯'}</button>
                <script>
                  let currentSlide = 0;
                  const slides = document.querySelectorAll('.carousel-slide');
                  
                  function showSlide(n) {
                    slides.forEach(slide => slide.style.display = 'none');
                    slides[n].style.display = 'block';
                  }
                  
                  function nextSlide() {
                    currentSlide = (currentSlide + 1) % slides.length;
                    showSlide(currentSlide);
                  }
                  
                  function previousSlide() {
                    currentSlide = (currentSlide - 1 + slides.length) % slides.length;
                    showSlide(currentSlide);
                  }
                </script>
              </div>
            HTML
          end
          
          def modal_content(language)
            title = language == :fa ? 'عنوان مودال' : 'Modal Title'
            content = language == :fa ? 'محتوای مودال اینجا قرار می‌گیرد.' : 'Modal content goes here.'
            button_text = language == :fa ? 'باز کردن مودال' : 'Open Modal'
            close_text = language == :fa ? 'بستن' : 'Close'
            
            <<~HTML
              <div class="modal-block" style="text-align: center; margin: 20px 0; direction: #{dir_attr(language)};">
                <button style="
                  background: #007bff;
                  color: white;
                  border: none;
                  padding: 12px 24px;
                  border-radius: 6px;
                  font-weight: 600;
                  cursor: pointer;
                " onclick="document.getElementById('modal').style.display='flex'">#{button_text}</button>
                
                <div id="modal" style="
                  display: none;
                  position: fixed;
                  top: 0;
                  left: 0;
                  width: 100%;
                  height: 100%;
                  background: rgba(0,0,0,0.5);
                  z-index: 1000;
                  align-items: center;
                  justify-content: center;
                ">
                  <div style="
                    background: white;
                    padding: 30px;
                    border-radius: 12px;
                    max-width: 500px;
                    max-height: 80vh;
                    overflow-y: auto;
                    position: relative;
                    margin: 20px;
                  ">
                    <button style="
                      position: absolute;
                      top: 15px;
                      #{language == :fa ? 'left' : 'right'}: 15px;
                      background: none;
                      border: none;
                      font-size: 1.5rem;
                      cursor: pointer;
                      color: #6c757d;
                    " onclick="document.getElementById('modal').style.display='none'">×</button>
                    <h3 style="margin: 0 0 20px 0; color: #495057;">#{title}</h3>
                    <p style="margin: 0 0 20px 0; color: #6c757d; line-height: 1.6;">#{content}</p>
                    <button style="
                      background: #6c757d;
                      color: white;
                      border: none;
                      padding: 10px 20px;
                      border-radius: 6px;
                      cursor: pointer;
                    " onclick="document.getElementById('modal').style.display='none'">#{close_text}</button>
                  </div>
                </div>
              </div>
            HTML
          end
          
          def countdown_timer_content(language)
            title = language == :fa ? 'شمارش معکوس' : 'Countdown Timer'
            
            <<~HTML
              <div class="countdown-timer" style="
                background: linear-gradient(135deg, #dc3545, #fd7e14);
                color: white;
                padding: 40px 20px;
                border-radius: 12px;
                text-align: center;
                margin: 20px auto;
                max-width: 600px;
                direction: #{dir_attr(language)};
              ">
                <h3 style="margin: 0 0 20px 0; font-size: 1.8rem;">#{title}</h3>
                <div style="
                  display: flex;
                  justify-content: center;
                  gap: 20px;
                  flex-wrap: wrap;
                ">
                  #{['days', 'hours', 'minutes', 'seconds'].map.with_index { |unit, index|
                    label = if language == :fa
                      {'days' => 'روز', 'hours' => 'ساعت', 'minutes' => 'دقیقه', 'seconds' => 'ثانیه'}[unit]
                    else
                      unit.capitalize
                    end
                    
                    <<~TIME_UNIT
                      <div style="text-align: center;">
                        <div style="
                          background: rgba(255,255,255,0.2);
                          border-radius: 8px;
                          padding: 15px;
                          min-width: 80px;
                        ">
                          <div id="#{unit}" style="font-size: 2rem; font-weight: 700;">#{['05', '14', '32', '18'][index]}</div>
                          <div style="font-size: 0.8rem; opacity: 0.9; margin-top: 5px;">#{label}</div>
                        </div>
                      </div>
                    TIME_UNIT
                  }.join}
                </div>
                <script>
                  // Simple countdown demo - in real implementation, set actual target date
                  setInterval(function() {
                    var seconds = parseInt(document.getElementById('seconds').textContent);
                    if (seconds > 0) {
                      document.getElementById('seconds').textContent = String(seconds - 1).padStart(2, '0');
                    }
                  }, 1000);
                </script>
              </div>
            HTML
          end
          
          def progress_bar_content(language)
            title = language == :fa ? 'نوار پیشرفت' : 'Progress Bar'
            
            <<~HTML
              <div class="progress-bar" style="
                background: white;
                padding: 30px;
                border-radius: 12px;
                max-width: 600px;
                margin: 20px auto;
                box-shadow: 0 4px 20px rgba(0,0,0,0.1);
                direction: #{dir_attr(language)};
              ">
                <h3 style="margin: 0 0 20px 0; text-align: center; color: #495057;">#{title}</h3>
                <div style="margin-bottom: 20px;">
                  <div style="display: flex; justify-content: space-between; margin-bottom: 5px;">
                    <span style="color: #6c757d;">#{language == :fa ? 'مهارت ۱' : 'Skill 1'}</span>
                    <span style="color: #6c757d;">85%</span>
                  </div>
                  <div style="background: #e9ecef; border-radius: 10px; overflow: hidden;">
                    <div style="background: linear-gradient(90deg, #007bff, #0056b3); width: 85%; height: 10px; border-radius: 10px;"></div>
                  </div>
                </div>
                <div style="margin-bottom: 20px;">
                  <div style="display: flex; justify-content: space-between; margin-bottom: 5px;">
                    <span style="color: #6c757d;">#{language == :fa ? 'مهارت ۲' : 'Skill 2'}</span>
                    <span style="color: #6c757d;">72%</span>
                  </div>
                  <div style="background: #e9ecef; border-radius: 10px; overflow: hidden;">
                    <div style="background: linear-gradient(90deg, #28a745, #1e7e34); width: 72%; height: 10px; border-radius: 10px;"></div>
                  </div>
                </div>
                <div>
                  <div style="display: flex; justify-content: space-between; margin-bottom: 5px;">
                    <span style="color: #6c757d;">#{language == :fa ? 'مهارت ۳' : 'Skill 3'}</span>
                    <span style="color: #6c757d;">93%</span>
                  </div>
                  <div style="background: #e9ecef; border-radius: 10px; overflow: hidden;">
                    <div style="background: linear-gradient(90deg, #ffc107, #e0a800); width: 93%; height: 10px; border-radius: 10px;"></div>
                  </div>
                </div>
              </div>
            HTML
          end
          
          def social_feed_content(language)
            title = language == :fa ? 'فید اجتماعی' : 'Social Feed'
            
            posts = if language == :fa
              [
                { author: 'کاربر ۱', content: 'این یک پست نمونه در شبکه اجتماعی است.', time: '۲ ساعت پیش' },
                { author: 'کاربر ۲', content: 'پست دیگری با محتوای جالب و مفید.', time: '۵ ساعت پیش' }
              ]
            else
              [
                { author: 'User 1', content: 'This is a sample social media post.', time: '2 hours ago' },
                { author: 'User 2', content: 'Another post with interesting and useful content.', time: '5 hours ago' }
              ]
            end
            
            <<~HTML
              <div class="social-feed" style="
                max-width: 600px;
                margin: 20px auto;
                direction: #{dir_attr(language)};
              ">
                <h3 style="margin: 0 0 20px 0; text-align: center; color: #495057;">#{title}</h3>
                #{posts.map { |post|
                  <<~POST
                    <div style="
                      background: white;
                      border: 1px solid #e9ecef;
                      border-radius: 12px;
                      padding: 20px;
                      margin-bottom: 15px;
                      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                    ">
                      <div style="display: flex; align-items: center; margin-bottom: 15px;">
                        <img src="https://via.placeholder.com/40x40/007bff/ffffff?text=👤" style="
                          width: 40px;
                          height: 40px;
                          border-radius: 50%;
                          margin-#{language == :fa ? 'left' : 'right'}: 10px;
                        ">
                        <div>
                          <div style="font-weight: 600; color: #495057;">#{post[:author]}</div>
                          <div style="font-size: 0.8rem; color: #6c757d;">#{post[:time]}</div>
                        </div>
                      </div>
                      <p style="margin: 0 0 15px 0; color: #495057; line-height: 1.6;">#{post[:content]}</p>
                      <div style="display: flex; gap: 20px; color: #6c757d; font-size: 0.9rem;">
                        <span style="cursor: pointer;">👍 #{language == :fa ? 'پسند' : 'Like'}</span>
                        <span style="cursor: pointer;">💬 #{language == :fa ? 'نظر' : 'Comment'}</span>
                        <span style="cursor: pointer;">📤 #{language == :fa ? 'اشتراک' : 'Share'}</span>
                      </div>
                    </div>
                  POST
                }.join}
              </div>
            HTML
          end
        end
      end
    end
  end
end