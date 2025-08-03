# frozen_string_literal: true

require 'json'
require 'securerandom'
require 'fileutils'

module Rails
  module Page
    module Builder
      class ComponentLibrary
        class ComponentError < StandardError; end
        class ComponentValidationError < ComponentError; end

        class << self
          attr_accessor :components, :component_categories, :component_instances

          def initialize_system
            @components = {}
            @component_categories = {}
            @component_instances = {}
            @component_dependencies = {}
            setup_default_categories
            setup_default_components
          end

          # Component Registration
          def register_component(component_id, config)
            validate_component_config!(config)
            
            component = Component.new(component_id, config)
            @components[component_id.to_sym] = component
            
            # Add to category
            category = config[:category] || 'general'
            @component_categories[category.to_sym] ||= []
            @component_categories[category.to_sym] << component_id.to_sym
            
            component
          end

          def unregister_component(component_id)
            component = @components.delete(component_id.to_sym)
            return false unless component

            # Remove from categories
            @component_categories.each do |category, components|
              components.delete(component_id.to_sym)
            end

            # Remove instances
            @component_instances.delete(component_id.to_sym)
            
            true
          end

          # Component Discovery
          def get_component(component_id)
            @components[component_id.to_sym]
          end

          def list_components(category = nil)
            if category
              component_ids = @component_categories[category.to_sym] || []
              component_ids.map { |id| @components[id] }.compact
            else
              @components.values
            end
          end

          def search_components(query)
            query = query.downcase
            @components.values.select do |component|
              component.name.downcase.include?(query) ||
              component.description.downcase.include?(query) ||
              component.tags.any? { |tag| tag.downcase.include?(query) }
            end
          end

          def get_categories
            @component_categories.keys
          end

          def get_category_info(category)
            components = list_components(category)
            {
              name: category,
              count: components.count,
              components: components.map(&:to_summary)
            }
          end

          # Component Creation and Instantiation
          def create_component_instance(component_id, instance_config = {})
            component = get_component(component_id)
            raise ComponentError, "Component '#{component_id}' not found" unless component

            instance_id = instance_config[:id] || SecureRandom.uuid
            
            instance = ComponentInstance.new(
              instance_id,
              component,
              instance_config
            )

            @component_instances[instance_id] = instance
            instance
          end

          def get_component_instance(instance_id)
            @component_instances[instance_id]
          end

          def update_component_instance(instance_id, updates)
            instance = get_component_instance(instance_id)
            return false unless instance

            instance.update_properties(updates)
            true
          end

          def delete_component_instance(instance_id)
            @component_instances.delete(instance_id)
          end

          # Component Rendering
          def render_component(component_id, props = {}, language = :en)
            component = get_component(component_id)
            raise ComponentError, "Component '#{component_id}' not found" unless component

            component.render(props, language)
          end

          def render_component_instance(instance_id, language = :en)
            instance = get_component_instance(instance_id)
            raise ComponentError, "Component instance '#{instance_id}' not found" unless instance

            instance.render(language)
          end

          # Component Dependencies
          def register_dependency(component_id, dependency_config)
            @component_dependencies[component_id.to_sym] ||= []
            @component_dependencies[component_id.to_sym] << dependency_config
          end

          def get_component_dependencies(component_id)
            dependencies = @component_dependencies[component_id.to_sym] || []
            
            # Resolve dependencies recursively
            all_dependencies = []
            dependencies.each do |dep|
              all_dependencies << dep
              all_dependencies.concat(get_component_dependencies(dep[:component_id]))
            end
            
            all_dependencies.uniq { |dep| dep[:component_id] }
          end

          # Component Templates and Presets
          def create_component_preset(component_id, preset_name, preset_config)
            component = get_component(component_id)
            raise ComponentError, "Component '#{component_id}' not found" unless component

            component.add_preset(preset_name, preset_config)
          end

          def get_component_presets(component_id)
            component = get_component(component_id)
            return [] unless component

            component.presets
          end

          def apply_component_preset(instance_id, preset_name)
            instance = get_component_instance(instance_id)
            return false unless instance

            preset = instance.component.get_preset(preset_name)
            return false unless preset

            instance.update_properties(preset[:properties])
            true
          end

          # Component Import/Export
          def export_component(component_id)
            component = get_component(component_id)
            return nil unless component

            {
              component: component.to_h,
              dependencies: get_component_dependencies(component_id),
              presets: component.presets,
              exported_at: Time.now.iso8601
            }
          end

          def import_component(component_data)
            component_config = component_data[:component]
            component_id = component_config[:id]

            # Import dependencies first
            if component_data[:dependencies]
              component_data[:dependencies].each do |dep|
                register_dependency(component_id, dep)
              end
            end

            # Register the component
            component = register_component(component_id, component_config)

            # Import presets
            if component_data[:presets]
              component_data[:presets].each do |preset_name, preset_config|
                component.add_preset(preset_name, preset_config)
              end
            end

            component
          end

          # Component Validation and Testing
          def validate_component(component_id, test_props = {})
            component = get_component(component_id)
            return { valid: false, errors: ['Component not found'] } unless component

            errors = []
            
            # Validate required properties
            missing_props = component.required_properties - test_props.keys.map(&:to_sym)
            if missing_props.any?
              errors << "Missing required properties: #{missing_props.join(', ')}"
            end

            # Validate property types
            test_props.each do |prop, value|
              expected_type = component.get_property_type(prop)
              if expected_type && !validate_property_type(value, expected_type)
                errors << "Invalid type for property '#{prop}': expected #{expected_type}"
              end
            end

            # Test rendering
            begin
              rendered = component.render(test_props)
              errors << "Component rendering failed" if rendered.nil? || rendered.empty?
            rescue => e
              errors << "Rendering error: #{e.message}"
            end

            {
              valid: errors.empty?,
              errors: errors,
              warnings: []
            }
          end

          # Component Analytics
          def get_component_usage_stats
            usage_stats = {}
            
            @component_instances.values.each do |instance|
              component_id = instance.component.id
              usage_stats[component_id] ||= { instances: 0, last_used: nil }
              usage_stats[component_id][:instances] += 1
              usage_stats[component_id][:last_used] = [
                usage_stats[component_id][:last_used],
                instance.created_at
              ].compact.max
            end

            usage_stats
          end

          def get_popular_components(limit = 10)
            usage_stats = get_component_usage_stats
            sorted_components = usage_stats.sort_by { |_, stats| -stats[:instances] }
            
            sorted_components.first(limit).map do |component_id, stats|
              component = get_component(component_id)
              {
                component: component&.to_summary,
                instances: stats[:instances],
                last_used: stats[:last_used]
              }
            end
          end

          private

          def validate_component_config!(config)
            required_fields = [:name, :template]
            missing_fields = required_fields.select { |field| config[field].nil? }
            
            if missing_fields.any?
              raise ComponentValidationError, "Missing required component fields: #{missing_fields.join(', ')}"
            end

            # Validate template
            unless config[:template].is_a?(String) && !config[:template].strip.empty?
              raise ComponentValidationError, "Component template must be a non-empty string"
            end
          end

          def validate_property_type(value, expected_type)
            case expected_type.to_sym
            when :string
              value.is_a?(String)
            when :number
              value.is_a?(Numeric)
            when :boolean
              [true, false].include?(value)
            when :array
              value.is_a?(Array)
            when :object
              value.is_a?(Hash)
            when :color
              value.is_a?(String) && value.match?(/^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/)
            when :url
              value.is_a?(String) && value.match?(/\Ahttps?:\/\//)
            else
              true # Unknown type, allow anything
            end
          end

          def setup_default_categories
            @component_categories = {
              layout: [],
              navigation: [],
              content: [],
              forms: [],
              media: [],
              ecommerce: [],
              social: [],
              ui_elements: [],
              advanced: []
            }
          end

          def setup_default_components
            # Layout Components
            register_component('container', {
              name: 'Container',
              description: 'A responsive container component',
              category: 'layout',
              template: '<div class="container {{classes}}" style="{{styles}}">{{content}}</div>',
              properties: {
                max_width: { type: 'string', default: '1200px' },
                padding: { type: 'string', default: '0 20px' },
                content: { type: 'string', default: 'Container content' }
              },
              css: '.container { margin: 0 auto; }'
            })

            register_component('grid', {
              name: 'Grid Layout',
              description: 'CSS Grid layout component',
              category: 'layout',
              template: '<div class="grid-layout" style="grid-template-columns: repeat({{columns}}, 1fr); gap: {{gap}};">{{content}}</div>',
              properties: {
                columns: { type: 'number', default: 3, min: 1, max: 12 },
                gap: { type: 'string', default: '20px' },
                content: { type: 'string', default: 'Grid content' }
              },
              css: '.grid-layout { display: grid; }'
            })

            # Navigation Components
            register_component('navbar', {
              name: 'Navigation Bar',
              description: 'Responsive navigation bar',
              category: 'navigation',
              template: <<~HTML
                <nav class="navbar" style="{{styles}}">
                  <div class="navbar-brand">{{brand}}</div>
                  <ul class="navbar-nav">
                    {{#each nav_items}}
                    <li class="nav-item">
                      <a href="{{url}}" class="nav-link">{{title}}</a>
                    </li>
                    {{/each}}
                  </ul>
                </nav>
              HTML,
              properties: {
                brand: { type: 'string', default: 'Brand' },
                nav_items: { 
                  type: 'array', 
                  default: [
                    { title: 'Home', url: '#' },
                    { title: 'About', url: '#' },
                    { title: 'Contact', url: '#' }
                  ]
                }
              },
              css: <<~CSS
                .navbar { display: flex; justify-content: space-between; align-items: center; padding: 1rem; }
                .navbar-nav { display: flex; list-style: none; margin: 0; padding: 0; }
                .nav-item { margin: 0 1rem; }
                .nav-link { text-decoration: none; color: inherit; }
              CSS
            })

            # Content Components
            register_component('card', {
              name: 'Card',
              description: 'Flexible content card',
              category: 'content',
              template: <<~HTML
                <div class="card" style="{{styles}}">
                  {{#if image}}
                  <img src="{{image}}" alt="{{title}}" class="card-image">
                  {{/if}}
                  <div class="card-body">
                    {{#if title}}
                    <h3 class="card-title">{{title}}</h3>
                    {{/if}}
                    {{#if description}}
                    <p class="card-description">{{description}}</p>
                    {{/if}}
                    {{#if button_text}}
                    <button class="card-button">{{button_text}}</button>
                    {{/if}}
                  </div>
                </div>
              HTML,
              properties: {
                title: { type: 'string', default: 'Card Title' },
                description: { type: 'string', default: 'Card description goes here.' },
                image: { type: 'url', default: '' },
                button_text: { type: 'string', default: 'Learn More' }
              },
              css: <<~CSS
                .card { border: 1px solid #ddd; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
                .card-image { width: 100%; height: 200px; object-fit: cover; }
                .card-body { padding: 1.5rem; }
                .card-title { margin: 0 0 1rem 0; }
                .card-description { margin: 0 0 1.5rem 0; color: #666; }
                .card-button { background: #007bff; color: white; border: none; padding: 0.5rem 1rem; border-radius: 4px; cursor: pointer; }
              CSS
            })

            # Form Components
            register_component('contact_form', {
              name: 'Contact Form',
              description: 'Complete contact form with validation',
              category: 'forms',
              template: <<~HTML
                <form class="contact-form" action="{{action}}" method="{{method}}">
                  <div class="form-group">
                    <label for="name">{{labels.name}}</label>
                    <input type="text" id="name" name="name" required>
                  </div>
                  <div class="form-group">
                    <label for="email">{{labels.email}}</label>
                    <input type="email" id="email" name="email" required>
                  </div>
                  <div class="form-group">
                    <label for="message">{{labels.message}}</label>
                    <textarea id="message" name="message" rows="5" required></textarea>
                  </div>
                  <button type="submit" class="submit-button">{{submit_text}}</button>
                </form>
              HTML,
              properties: {
                action: { type: 'string', default: '/contact' },
                method: { type: 'string', default: 'POST' },
                submit_text: { type: 'string', default: 'Send Message' },
                labels: {
                  type: 'object',
                  default: {
                    name: 'Name',
                    email: 'Email',
                    message: 'Message'
                  }
                }
              },
              css: <<~CSS
                .contact-form { max-width: 500px; }
                .form-group { margin-bottom: 1.5rem; }
                .form-group label { display: block; margin-bottom: 0.5rem; font-weight: 600; }
                .form-group input, .form-group textarea { width: 100%; padding: 0.75rem; border: 1px solid #ddd; border-radius: 4px; }
                .submit-button { background: #28a745; color: white; border: none; padding: 0.75rem 1.5rem; border-radius: 4px; cursor: pointer; }
              CSS
            })

            # E-commerce Components
            register_component('product_card', {
              name: 'Product Card',
              description: 'E-commerce product display card',
              category: 'ecommerce',
              template: <<~HTML
                <div class="product-card">
                  <img src="{{image}}" alt="{{name}}" class="product-image">
                  <div class="product-info">
                    <h4 class="product-name">{{name}}</h4>
                    <p class="product-price">{{currency}}{{price}}</p>
                    {{#if rating}}
                    <div class="product-rating">
                      {{#each stars}}⭐{{/each}}
                    </div>
                    {{/if}}
                    <button class="add-to-cart-btn" data-product-id="{{id}}">{{add_to_cart_text}}</button>
                  </div>
                </div>
              HTML,
              properties: {
                id: { type: 'string', required: true },
                name: { type: 'string', default: 'Product Name' },
                price: { type: 'number', default: 99.99 },
                currency: { type: 'string', default: '$' },
                image: { type: 'url', default: 'https://via.placeholder.com/300x200' },
                rating: { type: 'number', default: 5, min: 1, max: 5 },
                add_to_cart_text: { type: 'string', default: 'Add to Cart' }
              },
              css: <<~CSS
                .product-card { border: 1px solid #eee; border-radius: 8px; overflow: hidden; transition: transform 0.2s; }
                .product-card:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
                .product-image { width: 100%; height: 200px; object-fit: cover; }
                .product-info { padding: 1rem; }
                .product-name { margin: 0 0 0.5rem 0; font-size: 1.1rem; }
                .product-price { font-size: 1.25rem; font-weight: 600; color: #28a745; margin: 0 0 0.5rem 0; }
                .product-rating { margin: 0 0 1rem 0; }
                .add-to-cart-btn { width: 100%; background: #007bff; color: white; border: none; padding: 0.75rem; border-radius: 4px; cursor: pointer; }
              CSS
            })

            # Advanced Components
            register_component('tabs', {
              name: 'Tabs',
              description: 'Tabbed content interface',
              category: 'advanced',
              template: <<~HTML
                <div class="tabs-component">
                  <div class="tabs-nav">
                    {{#each tabs}}
                    <button class="tab-button {{#if @first}}active{{/if}}" data-tab="{{@index}}">{{title}}</button>
                    {{/each}}
                  </div>
                  <div class="tabs-content">
                    {{#each tabs}}
                    <div class="tab-panel {{#if @first}}active{{/if}}" data-panel="{{@index}}">
                      {{content}}
                    </div>
                    {{/each}}
                  </div>
                </div>
              HTML,
              properties: {
                tabs: {
                  type: 'array',
                  default: [
                    { title: 'Tab 1', content: 'Content for tab 1' },
                    { title: 'Tab 2', content: 'Content for tab 2' },
                    { title: 'Tab 3', content: 'Content for tab 3' }
                  ]
                }
              },
              css: <<~CSS
                .tabs-nav { display: flex; border-bottom: 1px solid #ddd; }
                .tab-button { background: none; border: none; padding: 1rem 1.5rem; cursor: pointer; border-bottom: 2px solid transparent; }
                .tab-button.active { border-bottom-color: #007bff; color: #007bff; }
                .tab-panel { display: none; padding: 1.5rem; }
                .tab-panel.active { display: block; }
              CSS,
              javascript: <<~JAVASCRIPT
                document.querySelectorAll('.tab-button').forEach(button => {
                  button.addEventListener('click', function() {
                    const tabIndex = this.getAttribute('data-tab');
                    const tabsComponent = this.closest('.tabs-component');
                    
                    // Remove active class from all buttons and panels
                    tabsComponent.querySelectorAll('.tab-button').forEach(btn => btn.classList.remove('active'));
                    tabsComponent.querySelectorAll('.tab-panel').forEach(panel => panel.classList.remove('active'));
                    
                    // Add active class to clicked button and corresponding panel
                    this.classList.add('active');
                    tabsComponent.querySelector('[data-panel="' + tabIndex + '"]').classList.add('active');
                  });
                });
              JAVASCRIPT
            })
          end
        end

        # Component Class
        class Component
          attr_reader :id, :name, :description, :category, :template, :properties, 
                      :css, :javascript, :tags, :presets

          def initialize(id, config)
            @id = id.to_sym
            @name = config[:name]
            @description = config[:description] || ''
            @category = config[:category] || 'general'
            @template = config[:template]
            @properties = config[:properties] || {}
            @css = config[:css] || ''
            @javascript = config[:javascript] || ''
            @tags = config[:tags] || []
            @presets = {}
            @created_at = Time.now
          end

          def render(props = {}, language = :en)
            # Merge default properties with provided props
            merged_props = default_properties.merge(props)
            
            # Simple template rendering (in real implementation, use a proper template engine)
            rendered_template = @template.dup
            
            merged_props.each do |key, value|
              placeholder = "{{#{key}}}"
              rendered_template.gsub!(placeholder, value.to_s)
            end
            
            # Handle conditionals (simplified)
            rendered_template.gsub!(/\{\{#if\s+(\w+)\}\}(.*?)\{\{\/if\}\}/m) do |match|
              condition = $1
              content = $2
              merged_props[condition.to_sym] ? content : ''
            end
            
            # Handle iterations (simplified)
            rendered_template.gsub!(/\{\{#each\s+(\w+)\}\}(.*?)\{\{\/each\}\}/m) do |match|
              array_name = $1
              content_template = $2
              array_data = merged_props[array_name.to_sym] || []
              
              array_data.map.with_index do |item, index|
                item_content = content_template.dup
                if item.is_a?(Hash)
                  item.each { |k, v| item_content.gsub!("{{#{k}}}", v.to_s) }
                end
                item_content.gsub!('{{@index}}', index.to_s)
                item_content.gsub!('{{@first}}', (index == 0).to_s)
                item_content
              end.join
            end
            
            rendered_template
          end

          def required_properties
            @properties.select { |_, config| config[:required] }.keys
          end

          def get_property_type(property)
            @properties.dig(property.to_sym, :type)
          end

          def default_properties
            defaults = {}
            @properties.each do |key, config|
              defaults[key] = config[:default] if config.key?(:default)
            end
            defaults
          end

          def add_preset(name, config)
            @presets[name.to_sym] = config
          end

          def get_preset(name)
            @presets[name.to_sym]
          end

          def to_h
            {
              id: @id,
              name: @name,
              description: @description,
              category: @category,
              template: @template,
              properties: @properties,
              css: @css,
              javascript: @javascript,
              tags: @tags,
              created_at: @created_at
            }
          end

          def to_summary
            {
              id: @id,
              name: @name,
              description: @description,
              category: @category,
              tags: @tags
            }
          end
        end

        # Component Instance Class
        class ComponentInstance
          attr_reader :id, :component, :properties, :created_at

          def initialize(id, component, config = {})
            @id = id
            @component = component
            @properties = component.default_properties.merge(config[:properties] || {})
            @created_at = Time.now
            @updated_at = @created_at
          end

          def update_properties(updates)
            @properties.merge!(updates)
            @updated_at = Time.now
          end

          def render(language = :en)
            @component.render(@properties, language)
          end

          def to_h
            {
              id: @id,
              component_id: @component.id,
              properties: @properties,
              created_at: @created_at,
              updated_at: @updated_at
            }
          end
        end

        # Initialize the system
        def self.included(base)
          initialize_system
        end
      end
    end
  end
end

# Initialize the component library system
Rails::Page::Builder::ComponentLibrary.initialize_system