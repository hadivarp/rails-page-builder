# Rails Page Builder

[English](#english) | [فارسی](#فارسی)

---

## English

A visual drag-and-drop page builder for Ruby on Rails applications, designed to simplify view development for developers without extensive frontend experience. Similar to Elementor or WPBakery, but built specifically for Rails.

### 🚀 Features

- 🎨 **Visual Page Builder**: Intuitive drag-and-drop interface
- 🌍 **Multi-language Support**: Built-in support for English, Persian (Farsi), Arabic, and Hebrew
- ↔️ **RTL Support**: Full right-to-left text support for RTL languages
- 📱 **Responsive Design**: Mobile-friendly design with device preview
- 🔧 **Configurable**: Easy configuration through Rails initializers
- 📦 **Custom Blocks**: Add your own custom content blocks
- 🎯 **Rails Integration**: Seamless integration with Rails applications
- 🔌 **Plugin System**: Extensible plugin architecture
- 📊 **Analytics**: Built-in analytics and reporting features
- 🔒 **Security**: Permission-based access control

### 📦 Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails-page-builder'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install rails-page-builder
```

### ⚙️ Setup

After installing the gem, run the install generator:

```bash
rails generate rails_page_builder:install
```

This will:
- Create the pages migration
- Generate controller, views, and model files
- Add the engine route to your application
- Create an initializer for configuration

Run the migration:

```bash
rails db:migrate
```

### 🎯 Usage

#### Basic Configuration

Configure the page builder in `config/initializers/rails_page_builder.rb`:

```ruby
Rails::Page::Builder.configure do |config|
  # Set default language
  config.default_language = :en  # :en, :fa, :ar, :he
  
  # Supported languages
  config.supported_languages = [:en, :fa, :ar, :he]
  
  # Enable plugins
  config.enable_plugins = true
  
  # Enable analytics
  config.enable_analytics = true
end
```

#### Using the Page Builder

1. **Access the builder**: Visit `/rails_page_builder` in your Rails application
2. **Create pages**: Use the visual interface to build pages
3. **Save and publish**: Save your pages and integrate them into your Rails views

#### Rendering Pages

In your Rails views:

```erb
<!-- Render a page builder editor -->
<%= rails_page_builder_editor(language: :fa) %>

<!-- Render saved page content -->
<%= rails_page_builder_content(@page) %>
```

#### Custom Blocks

Add custom blocks through configuration:

```ruby
Rails::Page::Builder.configure do |config|
  config.custom_blocks = [
    {
      id: 'custom-hero',
      label: 'Hero Section',
      content: '<div class="hero">Hero Content</div>',
      category: 'Layout',
      icon: '🎯'
    }
  ]
end
```

### 🌍 Multi-language Support

The gem automatically detects RTL languages and adjusts the interface accordingly:

```ruby
# Supported languages with RTL detection
languages = {
  en: { name: 'English', rtl: false },
  fa: { name: 'فارسی', rtl: true },
  ar: { name: 'العربية', rtl: true },
  he: { name: 'עברית', rtl: true }
}
```

### 🔧 Advanced Features

#### Plugin System
```ruby
# Register a plugin
Rails::Page::Builder::PluginSystem.register_plugin('my-plugin', {
  name: 'My Custom Plugin',
  version: '1.0.0',
  assets: ['my-plugin.js', 'my-plugin.css']
})
```

#### Analytics
```ruby
# Track page events
Rails::Page::Builder::Analytics.track_event(:page_view, {
  page_id: @page.id,
  user_id: current_user.id
})
```

### 🛠️ Development

To test the gem locally:

```bash
# Clone the repository
git clone https://github.com/hadivarp/rails-page-builder.git
cd rails-page-builder

# Install dependencies
bundle install

# Run the demo server
./start_demo.sh

# Visit http://localhost:4567/interactive
```

### 📄 License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

### 🤝 Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hadivarp/rails-page-builder.

---

## فارسی

سازنده صفحه بصری کشیدن و رها کردن برای اپلیکیشن‌های Ruby on Rails، طراحی شده برای ساده‌سازی توسعه view برای توسعه‌دهندگانی که تجربه گسترده‌ای در frontend ندارند. شبیه به Elementor یا WPBakery، اما مخصوص Rails ساخته شده است.

### 🚀 ویژگی‌ها

- 🎨 **سازنده صفحه بصری**: رابط کاربری بصری کشیدن و رها کردن
- 🌍 **پشتیبانی چند زبانه**: پشتیبانی داخلی از انگلیسی، فارسی، عربی و عبری
- ↔️ **پشتیبانی RTL**: پشتیبانی کامل از متن راست به چپ برای زبان‌های RTL
- 📱 **طراحی ریسپانسیو**: طراحی موبایل-فرندلی با پیش‌نمایش دستگاه
- 🔧 **قابل پیکربندی**: پیکربندی آسان از طریق initializer های Rails
- 📦 **بلوک‌های سفارشی**: اضافه کردن بلوک‌های محتوای سفارشی
- 🎯 **یکپارچگی Rails**: یکپارچگی بدون درز با اپلیکیشن‌های Rails
- 🔌 **سیستم پلاگین**: معماری پلاگین قابل گسترش
- 📊 **آنالیتیکس**: ویژگی‌های آنالیتیکس و گزارش‌گیری داخلی
- 🔒 **امنیت**: کنترل دسترسی مبتنی بر مجوز

### 📦 نصب

این خط را به Gemfile اپلیکیشن خود اضافه کنید:

```ruby
gem 'rails-page-builder'
```

و سپس اجرا کنید:

```bash
bundle install
```

یا خودتان نصب کنید:

```bash
gem install rails-page-builder
```

### ⚙️ راه‌اندازی

پس از نصب gem، generator نصب را اجرا کنید:

```bash
rails generate rails_page_builder:install
```

این کار موارد زیر را انجام می‌دهد:
- ایجاد migration صفحات
- تولید فایل‌های controller، view و model
- اضافه کردن مسیر engine به اپلیکیشن شما
- ایجاد initializer برای پیکربندی

migration را اجرا کنید:

```bash
rails db:migrate
```

### 🎯 استفاده

#### پیکربندی پایه

سازنده صفحه را در `config/initializers/rails_page_builder.rb` پیکربندی کنید:

```ruby
Rails::Page::Builder.configure do |config|
  # تنظیم زبان پیش‌فرض
  config.default_language = :fa  # :en, :fa, :ar, :he
  
  # زبان‌های پشتیبانی شده
  config.supported_languages = [:en, :fa, :ar, :he]
  
  # فعال‌سازی پلاگین‌ها
  config.enable_plugins = true
  
  # فعال‌سازی آنالیتیکس
  config.enable_analytics = true
end
```

#### استفاده از سازنده صفحه

1. **دسترسی به سازنده**: `/rails_page_builder` را در اپلیکیشن Rails خود بازدید کنید
2. **ایجاد صفحات**: از رابط بصری برای ساخت صفحات استفاده کنید
3. **ذخیره و انتشار**: صفحات خود را ذخیره کنید و در view های Rails خود یکپارچه کنید

#### رندر کردن صفحات

در view های Rails خود:

```erb
<!-- رندر کردن ویرایشگر سازنده صفحه -->
<%= rails_page_builder_editor(language: :fa) %>

<!-- رندر کردن محتوای صفحه ذخیره شده -->
<%= rails_page_builder_content(@page) %>
```

#### بلوک‌های سفارشی

بلوک‌های سفارشی را از طریق پیکربندی اضافه کنید:

```ruby
Rails::Page::Builder.configure do |config|
  config.custom_blocks = [
    {
      id: 'hero-farsi',
      label: 'بخش هیرو',
      content: '<div class="hero">محتوای هیرو</div>',
      category: 'لایه‌بندی',
      icon: '🎯'
    }
  ]
end
```

### 🌍 پشتیبانی چند زبانه

gem به طور خودکار زبان‌های RTL را تشخیص می‌دهد و رابط را متناسب تنظیم می‌کند:

```ruby
# زبان‌های پشتیبانی شده با تشخیص RTL
languages = {
  en: { name: 'English', rtl: false },
  fa: { name: 'فارسی', rtl: true },
  ar: { name: 'العربية', rtl: true },
  he: { name: 'עברית', rtl: true }
}
```

### 🔧 ویژگی‌های پیشرفته

#### سیستم پلاگین
```ruby
# ثبت یک پلاگین
Rails::Page::Builder::PluginSystem.register_plugin('my-plugin', {
  name: 'پلاگین سفارشی من',
  version: '1.0.0',
  assets: ['my-plugin.js', 'my-plugin.css']
})
```

#### آنالیتیکس
```ruby
# ردیابی رویدادهای صفحه
Rails::Page::Builder::Analytics.track_event(:page_view, {
  page_id: @page.id,
  user_id: current_user.id
})
```

### 🛠️ توسعه

برای تست gem به صورت محلی:

```bash
# کلون کردن مخزن
git clone https://github.com/hadivarp/rails-page-builder.git
cd rails-page-builder

# نصب وابستگی‌ها
bundle install

# اجرای سرور نمایشی
./start_demo.sh

# بازدید از http://localhost:4567/interactive
```

### 📄 مجوز

این gem تحت شرایط [مجوز MIT](https://opensource.org/licenses/MIT) به عنوان منبع باز در دسترس است.

### 🤝 مشارکت

گزارش باگ و pull request ها در GitHub به آدرس https://github.com/hadivarp/rails-page-builder خوش‌آمد هستند.

---

## Demo & Examples

### Interactive Demo
Start the demo server to see the page builder in action:

```bash
./start_demo.sh
```

Visit:
- **Interactive Builder**: http://localhost:4567/interactive
- **Dashboard**: http://localhost:4567/dashboard
- **Persian Showcase**: http://localhost:4567/showcase/fa
- **English Showcase**: http://localhost:4567/showcase/en

### Example Usage in Rails App

```ruby
# In your controller
class PagesController < ApplicationController
  def show
    @page = Rails::Page::Builder::Page.find(params[:id])
  end
  
  def edit
    @page = Rails::Page::Builder::Page.find(params[:id])
  end
end
```

```erb
<!-- In your view -->
<div class="page-content" dir="<%= @page.rtl? ? 'rtl' : 'ltr' %>">
  <%= rails_page_builder_content(@page) %>
</div>
```

### API Examples

```ruby
# Create a new page
page = Rails::Page::Builder::Page.create!(
  title: 'صفحه نمونه',
  language: 'fa',
  content: Rails::Page::Builder::BlockLibrary.build_page([
    { type: 'hero', title: 'عنوان اصلی', content: 'محتوای توضیحی' },
    { type: 'features', items: ['ویژگی ۱', 'ویژگی ۲', 'ویژگی ۳'] }
  ])
)

# Render in different languages
english_content = page.render(language: :en)
persian_content = page.render(language: :fa)
```