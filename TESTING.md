# Testing Rails Page Builder Advanced Features

This guide shows you how to test all the new advanced features I implemented.

## 🚀 Quick Start Testing

### 1. Basic Feature Test
Run the comprehensive feature test:

```bash
ruby test_features.rb
```

This will test:
- ✅ Advanced Block Library (30+ blocks)
- ✅ Template System (8 templates in 4 languages)  
- ✅ RTL Language Support (Arabic, Hebrew, Persian)
- ✅ Asset Management System
- ✅ Template Manager functionality

### 2. Visual Block Showcase
Generate HTML showcases for all blocks:

```bash
ruby examples/block_showcase.rb
```

Then open the generated files:
- `examples/output/block_showcase_en.html` - English blocks
- `examples/output/block_showcase_fa.html` - Persian blocks (RTL)
- `examples/output/block_showcase_ar.html` - Arabic blocks (RTL)
- `examples/output/block_showcase_he.html` - Hebrew blocks (RTL)

### 3. Template System Demo
Test template functionality:

```bash
ruby examples/template_demo.rb
```

This generates:
- Template previews in all languages
- Custom template creation demo
- Template search functionality test

### 4. Asset Management Demo
Test asset management:

```bash
ruby examples/asset_demo.rb
```

Generates: `examples/output/asset_management_demo.html`

### 5. RSpec Tests
Run the test suite:

```bash
bundle exec rspec spec/rails/page/builder_advanced_spec.rb
```

## 📋 Manual Testing Checklist

### Advanced Block Library
- [ ] Can load all blocks in English
- [ ] Can load blocks in RTL languages (Arabic, Hebrew, Persian)
- [ ] Advanced blocks work (Accordion, Tabs, Carousel, Modal, etc.)
- [ ] E-commerce blocks display properly
- [ ] Interactive JavaScript features work

### Template System  
- [ ] Can load built-in templates
- [ ] Templates work in all 4 languages
- [ ] RTL templates have proper direction/alignment
- [ ] Template search finds correct results
- [ ] Custom template creation works

### Asset Management
- [ ] File type validation works
- [ ] Asset categories are correct
- [ ] Mock file upload succeeds
- [ ] Asset retrieval works
- [ ] Asset listing by category works

### RTL Language Support
- [ ] Arabic text displays right-to-left
- [ ] Hebrew text displays right-to-left  
- [ ] Persian text displays right-to-left
- [ ] Text alignment is correct for RTL
- [ ] UI elements are mirrored appropriately

## 🧪 Testing Individual Features

### Testing Block Library

```ruby
require_relative 'lib/rails/page/builder'

# Get all blocks
blocks = Rails::Page::Builder::BlockLibrary.all_blocks(:en)
puts "Total blocks: #{blocks.count}"

# Get advanced blocks only
advanced = Rails::Page::Builder::BlockLibrary.advanced_blocks(:en)
puts "Advanced blocks: #{advanced.count}"

# Test RTL blocks
arabic_blocks = Rails::Page::Builder::BlockLibrary.all_blocks(:ar)
puts "Arabic blocks: #{arabic_blocks.count}"
```

### Testing Templates

```ruby
require_relative 'lib/rails/page/builder'

# Load templates
templates = Rails::Page::Builder::TemplateSystem.all_templates(:en)
puts "Templates: #{templates.count}"

# Find specific template
landing = Rails::Page::Builder::TemplateSystem.find_template('landing-page', :ar)
puts "Arabic landing page: #{landing[:name]}"
```

### Testing Asset Management

```ruby
require_relative 'lib/rails/page/builder'

# Test file types
puts Rails::Page::Builder::AssetManager.send(:allowed_file_type?, 'image/jpeg')
puts Rails::Page::Builder::AssetManager.send(:determine_category, 'video/mp4')

# List assets
assets = Rails::Page::Builder::AssetManager.list_assets
puts "Current assets: #{assets.count}"
```

### Testing Configuration

```ruby
require_relative 'lib/rails/page/builder'

Rails::Page::Builder.configure do |config|
  config.supported_languages = [:en, :fa, :ar, :he]
  config.max_file_size = 5.megabytes
  config.template_versioning = true
end

config = Rails::Page::Builder.configuration
puts "RTL support for Arabic: #{config.rtl_language?(:ar)}"
puts "Max file size: #{config.max_file_size}"
```

## 🌐 Language Testing

### English (LTR)
```ruby
blocks = Rails::Page::Builder::BlockLibrary.all_blocks(:en)
# Should return blocks with English labels and LTR content
```

### Persian/Farsi (RTL)  
```ruby
blocks = Rails::Page::Builder::BlockLibrary.all_blocks(:fa)
# Should return blocks with Persian labels and RTL content
```

### Arabic (RTL)
```ruby
blocks = Rails::Page::Builder::BlockLibrary.all_blocks(:ar)
# Should return blocks with Arabic labels and RTL content  
```

### Hebrew (RTL)
```ruby
blocks = Rails::Page::Builder::BlockLibrary.all_blocks(:he)
# Should return blocks with Hebrew labels and RTL content
```

## 🔍 Debugging Tips

### Check File Loading
```ruby
# Verify all files load correctly
require_relative 'lib/rails/page/builder'
puts "✅ All files loaded successfully"
```

### Check Dependencies
```ruby
# Verify required gems
puts defined?(SecureRandom) ? "✅ SecureRandom available" : "❌ SecureRandom missing"
puts defined?(JSON) ? "✅ JSON available" : "❌ JSON missing"
```

### Check Directory Structure
```bash
ls -la lib/rails/page/builder/
# Should show: asset_manager.rb, block_library.rb, template_manager.rb, etc.
```

## 📁 Expected Output Files

After running all tests, you should have:

```
examples/output/
├── asset_management_demo.html
├── block_showcase_en.html
├── block_showcase_fa.html  
├── block_showcase_ar.html
├── block_showcase_he.html
├── business_template_ar.html
├── business_template_fa.html
├── business_template_he.html
├── custom_template_preview.html
└── landing_page_preview.html
```

## ⚠️ Troubleshooting

### Common Issues

1. **Missing dependencies**: Install required gems
   ```bash
   bundle install
   ```

2. **File not found**: Check that all files are in correct locations
   ```bash
   find lib/ -name "*.rb" | grep builder
   ```

3. **Permission errors**: Ensure write permissions for examples/output/
   ```bash
   chmod 755 examples/output/
   ```

4. **RTL not working**: Check font support in browser for Arabic/Hebrew characters

## 🎯 What Each Test Validates

- **Block Library**: 30+ blocks load correctly in all languages
- **Advanced Blocks**: Interactive components work (accordion, tabs, etc.)
- **Templates**: 8 templates × 4 languages = 32 template variations
- **RTL Support**: Proper right-to-left rendering for Arabic, Hebrew, Persian
- **Asset Management**: File upload, validation, categorization
- **Template Manager**: Save, load, search, version control

## 🏆 Success Criteria

All tests pass if:
- ✅ No Ruby errors or exceptions
- ✅ HTML files generate correctly  
- ✅ RTL languages display properly
- ✅ Interactive features work in browser
- ✅ All translations are present
- ✅ Asset management functions correctly

## 📞 Need Help?

If you encounter issues:
1. Check the generated HTML files for visual inspection
2. Run individual feature tests to isolate problems
3. Verify all dependencies are installed
4. Check file permissions and directory structure