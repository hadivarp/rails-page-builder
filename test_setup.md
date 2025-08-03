# Testing Rails Page Builder

## Quick Test Setup

### Option 1: Manual Test in Existing Rails App

1. **Add to your Rails app's Gemfile:**
```ruby
gem 'rails-page-builder', path: '/path/to/rails-page-builder'
```

2. **Run bundle install:**
```bash
bundle install
```

3. **Run the install generator:**
```bash
rails generate rails_page_builder:install
```

4. **Run migrations:**
```bash
rails db:migrate
```

5. **Add to your layout (app/views/layouts/application.html.erb):**
```erb
<!-- In <head> section -->
<link rel="stylesheet" href="https://unpkg.com/grapesjs/dist/css/grapes.min.css">
<%= page_builder_assets %>

<!-- Before closing </body> tag -->
<script src="https://unpkg.com/grapesjs"></script>
```

6. **Start your Rails server:**
```bash
rails server
```

7. **Visit the page builder:**
Navigate to `http://localhost:3000/page_builder/pages`

### Option 2: Test Individual Components

You can test specific components directly:

#### Test Configuration:
```ruby
# In rails console
Rails::Page::Builder.configure do |config|
  config.default_language = :fa
  config.supported_languages = [:en, :fa]
end

Rails::Page::Builder.configuration.default_language
# => :fa

Rails::Page::Builder.configuration.rtl_language?(:fa)
# => true
```

#### Test Model:
```ruby
# Create a test page
page = Page.create!(
  title: 'صفحه نمونه',
  slug: 'sample-page',
  content: '<div>محتوای فارسی</div>',
  language: 'fa'
)

page.rtl?
# => true

page.render_content
# => "<div>محتوای فارسی</div>"
```

#### Test Helpers:
```erb
<!-- In a view -->
<%= page_builder_editor(language: :fa, height: '500px') %>

<%= render_page_content('<div dir="rtl">متن فارسی</div>', :fa) %>
```

### Option 3: Manual File Testing

You can manually test the JavaScript and CSS files by creating a simple HTML file:

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Page Builder Test</title>
  <link rel="stylesheet" href="https://unpkg.com/grapesjs/dist/css/grapes.min.css">
  <link rel="stylesheet" href="vendor/assets/stylesheets/rails_page_builder.css">
</head>
<body>
  <div id="gjs" style="height: 100vh;"></div>
  
  <script src="https://unpkg.com/grapesjs"></script>
  <script src="vendor/assets/javascripts/rails_page_builder.js"></script>
  
  <script>
    // Initialize page builder
    const editor = RailsPageBuilder.init('gjs', {
      language: 'fa',
      rtl: true,
      height: '100vh'
    });
  </script>
</body>
</html>
```

## Testing Features

### 1. English Interface
- Set language to 'en'
- Check that interface shows English labels
- Test LTR text direction

### 2. Farsi Interface  
- Set language to 'fa'
- Check that interface shows Farsi labels (متن، تصویر، etc.)
- Test RTL text direction
- Verify Persian text renders correctly

### 3. Page Operations
- Create new page
- Edit existing page
- Save page content
- Load page content
- Delete page

### 4. Visual Editor
- Drag and drop blocks
- Style components
- Preview mode
- Device responsive testing
- Undo/Redo functionality

### 5. Database Storage
- Content saves to database
- CSS saves separately
- Metadata handling
- Language-specific queries

## Troubleshooting

**If GrapesJS doesn't load:**
- Check browser console for errors
- Ensure CDN links are accessible
- Verify JavaScript files are loaded correctly

**If styles look broken:**
- Check CSS file paths
- Ensure stylesheets are included
- Verify RTL styles for Farsi

**If generator fails:**
- Check Rails version compatibility
- Ensure all dependencies are installed
- Verify file permissions