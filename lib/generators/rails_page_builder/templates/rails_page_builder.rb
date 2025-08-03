# frozen_string_literal: true

Rails::Page::Builder.configure do |config|
  # Default language for the page builder
  # Supported: :en, :fa
  config.default_language = :en
  
  # List of supported languages
  config.supported_languages = [:en, :fa]
  
  # Storage adapter for pages
  # Currently supports: :active_record
  config.storage_adapter = :active_record
  
  # Custom blocks for the page builder
  # Add your own custom blocks here
  config.custom_blocks = [
    # Example custom block:
    # {
    #   id: 'custom-block',
    #   label: 'Custom Block',
    #   content: '<div class="custom-block">Custom Content</div>',
    #   category: 'Custom'
    # }
  ]
end