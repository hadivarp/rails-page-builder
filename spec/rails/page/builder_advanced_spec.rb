# frozen_string_literal: true

require_relative '../../../spec_helper'

RSpec.describe Rails::Page::Builder do
  before(:all) do
    Rails::Page::Builder.configure do |config|
      config.supported_languages = [:en, :fa, :ar, :he]
      config.max_file_size = 10.megabytes
    end
  end

  describe 'Advanced Block Library' do
    it 'loads all blocks including advanced ones' do
      all_blocks = Rails::Page::Builder::BlockLibrary.all_blocks(:en)
      expect(all_blocks).not_to be_empty
      expect(all_blocks.count).to be > 20
    end

    it 'includes advanced blocks' do
      advanced_blocks = Rails::Page::Builder::BlockLibrary.advanced_blocks(:en)
      expect(advanced_blocks).not_to be_empty
      
      block_ids = advanced_blocks.map { |block| block[:id] }
      expect(block_ids).to include('accordion', 'tabs', 'carousel', 'modal')
    end

    it 'supports multiple languages for blocks' do
      [:en, :fa, :ar, :he].each do |language|
        blocks = Rails::Page::Builder::BlockLibrary.all_blocks(language)
        expect(blocks).not_to be_empty
        expect(blocks.first[:label]).to be_a(String)
      end
    end

    it 'generates proper block content' do
      accordion_content = Rails::Page::Builder::BlockLibrary.send(:accordion_content, :en)
      expect(accordion_content).to include('accordion-block')
      expect(accordion_content).to include('onclick')
    end
  end

  describe 'RTL Language Support' do
    it 'correctly identifies RTL languages' do
      config = Rails::Page::Builder.configuration
      
      expect(config.rtl_language?(:ar)).to be true
      expect(config.rtl_language?(:he)).to be true
      expect(config.rtl_language?(:fa)).to be true
      expect(config.rtl_language?(:en)).to be false
    end

    it 'includes RTL languages in supported languages' do
      supported = Rails::Page::Builder.configuration.supported_languages
      expect(supported).to include(:ar, :he)
    end

    it 'generates RTL-appropriate content' do
      text_block_ar = Rails::Page::Builder::BlockLibrary.send(:text_block_content, :ar)
      expect(text_block_ar).to include('direction: rtl')
      expect(text_block_ar).to include('text-align: right')
    end
  end

  describe 'Template System' do
    it 'loads all built-in templates' do
      templates = Rails::Page::Builder::TemplateSystem.all_templates(:en)
      expect(templates).not_to be_empty
      expect(templates.count).to be >= 8
    end

    it 'finds specific templates' do
      landing_template = Rails::Page::Builder::TemplateSystem.find_template('landing-page', :en)
      expect(landing_template).not_to be_nil
      expect(landing_template[:name]).to eq('Landing Page')
    end

    it 'supports templates in multiple languages' do
      [:fa, :ar, :he].each do |language|
        templates = Rails::Page::Builder::TemplateSystem.all_templates(language)
        expect(templates).not_to be_empty
        
        business_template = templates.find { |t| t[:id] == 'business' }
        expect(business_template).not_to be_nil
        expect(business_template[:name]).to be_a(String)
      end
    end

    it 'sets RTL flag correctly for templates' do
      ar_templates = Rails::Page::Builder::TemplateSystem.all_templates(:ar)
      ar_templates.each do |template|
        expect(template[:rtl]).to be true
      end

      en_templates = Rails::Page::Builder::TemplateSystem.all_templates(:en)
      en_templates.each do |template|
        expect(template[:rtl]).to be false
      end
    end
  end

  describe 'Template Manager' do
    let(:mock_page) do
      double('Page', 
        content: '<div>Test content</div>',
        css: 'body { margin: 0; }',
        language: 'en',
        title: 'Test Page',
        slug: 'test-page',
        rtl?: false,
        created_at: Time.now
      )
    end

    it 'validates templates correctly' do
      valid_template = {
        id: 'test-template',
        name: 'Test Template',
        content: '<div>Valid content</div>',
        language: :en
      }

      errors = Rails::Page::Builder::TemplateManager.validate_template(valid_template)
      expect(errors).to be_empty
    end

    it 'rejects invalid templates' do
      invalid_template = {
        id: 'test-template'
        # Missing required fields
      }

      errors = Rails::Page::Builder::TemplateManager.validate_template(invalid_template)
      expect(errors).not_to be_empty
    end

    it 'searches templates correctly' do
      results = Rails::Page::Builder::TemplateManager.search_templates('business', :en)
      expect(results).not_to be_empty
      expect(results.first[:name]).to include('Business')
    end

    it 'groups templates by category' do
      categories = Rails::Page::Builder::TemplateManager.template_categories(:en)
      expect(categories).to include('Marketing', 'Business', 'Creative')
    end
  end

  describe 'Asset Manager' do
    it 'provides asset categories' do
      categories = Rails::Page::Builder::AssetManager.get_asset_categories
      expect(categories).to include('image', 'video', 'audio', 'document')
    end

    it 'validates file types correctly' do
      # Valid types
      expect(Rails::Page::Builder::AssetManager.send(:allowed_file_type?, 'image/jpeg')).to be true
      expect(Rails::Page::Builder::AssetManager.send(:allowed_file_type?, 'video/mp4')).to be true
      expect(Rails::Page::Builder::AssetManager.send(:allowed_file_type?, 'application/pdf')).to be true
      
      # Invalid types
      expect(Rails::Page::Builder::AssetManager.send(:allowed_file_type?, 'application/exe')).to be false
    end

    it 'determines categories correctly' do
      expect(Rails::Page::Builder::AssetManager.send(:determine_category, 'image/jpeg')).to eq('image')
      expect(Rails::Page::Builder::AssetManager.send(:determine_category, 'video/mp4')).to eq('video')
      expect(Rails::Page::Builder::AssetManager.send(:determine_category, 'application/pdf')).to eq('document')
    end

    it 'lists assets (empty initially)' do
      assets = Rails::Page::Builder::AssetManager.list_assets
      expect(assets).to be_an(Array)
    end
  end

  describe 'Configuration' do
    it 'includes new configuration options' do
      config = Rails::Page::Builder.configuration
      
      expect(config).to respond_to(:max_file_size)
      expect(config).to respond_to(:assets_path)
      expect(config).to respond_to(:template_storage_path)
      expect(config).to respond_to(:template_versioning)
    end

    it 'has proper default values' do
      config = Rails::Page::Builder.configuration
      
      expect(config.max_file_size).to eq(10.megabytes)
      expect(config.template_versioning).to be true
      expect(config.auto_save_templates).to be true
    end
  end
end