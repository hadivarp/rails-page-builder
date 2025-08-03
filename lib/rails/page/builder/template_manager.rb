# frozen_string_literal: true

require 'securerandom'
require 'fileutils'
require 'json'

module Rails
  module Page
    module Builder
      class TemplateManager
        class << self
          def apply_template(page, template_id, language = :en)
            template = TemplateSystem.find_template(template_id, language)
            return false unless template
            
            page.assign_attributes(
              content: template[:content],
              css: template[:css],
              language: language.to_s,
              title: page.title.present? ? page.title : template[:name]
            )
            
            page.save
          end
          
          def create_page_from_template(template_id, title, language = :en, published = false)
            template = TemplateSystem.find_template(template_id, language)
            return nil unless template
            
            Page.create(
              title: title,
              content: template[:content],
              css: template[:css],
              language: language.to_s,
              published: published
            )
          end
          
          def preview_template(template_id, language = :en)
            template = TemplateSystem.find_template(template_id, language)
            return nil unless template
            
            {
              html: template[:content],
              css: template[:css],
              rtl: template[:rtl]
            }
          end
          
          def templates_by_category(category = nil, language = :en)
            templates = TemplateSystem.all_templates(language)
            return templates unless category
            
            templates.select { |template| template[:category] == category }
          end
          
          def search_templates(query, language = :en)
            templates = TemplateSystem.all_templates(language)
            query = query.downcase
            
            templates.select do |template|
              template[:name].downcase.include?(query) ||
              template[:description].downcase.include?(query) ||
              template[:tags].any? { |tag| tag.downcase.include?(query) }
            end
          end
          
          def template_categories(language = :en)
            templates = TemplateSystem.all_templates(language)
            templates.map { |template| template[:category] }.uniq.sort
          end
          
          def template_tags(language = :en)
            templates = TemplateSystem.all_templates(language)
            templates.flat_map { |template| template[:tags] }.uniq.sort
          end
          
          def save_custom_template(page, template_data = {})
            template = {
              id: template_data[:id] || SecureRandom.uuid,
              name: template_data[:name] || page.title,
              description: template_data[:description] || "Custom template based on #{page.title}",
              category: template_data[:category] || 'Custom',
              content: page.content,
              css: page.css,
              language: page.language,
              rtl: page.rtl?,
              tags: template_data[:tags] || ['custom', 'user-generated'],
              created_at: Time.current,
              updated_at: Time.current,
              version: 1,
              author: template_data[:author] || 'User'
            }
            
            validation_errors = validate_template(template)
            return { success: false, errors: validation_errors } unless validation_errors.empty?
            
            save_template_to_storage(template)
            { success: true, template: template }
          end
          
          def load_custom_templates(language = :en)
            custom_templates = load_templates_from_storage
            custom_templates.select { |template| template[:language].to_sym == language.to_sym }
          end
          
          def delete_custom_template(template_id)
            template_path = File.join(templates_directory, "#{template_id}.json")
            return false unless File.exist?(template_path)
            
            File.delete(template_path)
            true
          end
          
          def duplicate_template(template_id, new_name = nil)
            template = find_custom_template(template_id)
            return nil unless template
            
            new_template = template.dup
            new_template[:id] = SecureRandom.uuid
            new_template[:name] = new_name || "#{template[:name]} (Copy)"
            new_template[:created_at] = Time.current
            new_template[:updated_at] = Time.current
            new_template[:version] = 1
            
            save_template_to_storage(new_template)
            new_template
          end
          
          def update_template_version(template_id, updated_content, updated_css = nil)
            template = find_custom_template(template_id)
            return nil unless template
            
            if Rails::Page::Builder.configuration.template_versioning
              # Save current version as backup
              backup_template(template)
            end
            
            template[:content] = updated_content
            template[:css] = updated_css if updated_css
            template[:updated_at] = Time.current
            template[:version] = (template[:version] || 1) + 1
            
            save_template_to_storage(template)
            template
          end
          
          def get_template_versions(template_id)
            return [] unless Rails::Page::Builder.configuration.template_versioning
            
            versions_dir = File.join(templates_directory, 'versions', template_id)
            return [] unless Dir.exist?(versions_dir)
            
            Dir.glob(File.join(versions_dir, "*.json")).map do |file|
              JSON.parse(File.read(file), symbolize_names: true)
            end.sort_by { |v| v[:version] }.reverse
          end
          
          def restore_template_version(template_id, version_number)
            versions = get_template_versions(template_id)
            version_to_restore = versions.find { |v| v[:version] == version_number }
            return nil unless version_to_restore
            
            current_template = find_custom_template(template_id)
            return nil unless current_template
            
            # Update current template with version data
            current_template.merge!(version_to_restore)
            current_template[:updated_at] = Time.current
            current_template[:version] = (current_template[:version] || 1) + 1
            
            save_template_to_storage(current_template)
            current_template
          end
          
          def find_custom_template(template_id)
            template_path = File.join(templates_directory, "#{template_id}.json")
            return nil unless File.exist?(template_path)
            
            JSON.parse(File.read(template_path), symbolize_names: true)
          end
          
          def export_template(page)
            {
              id: page.slug,
              name: page.title,
              description: "Custom template based on #{page.title}",
              category: 'Custom',
              content: page.content,
              css: page.css,
              language: page.language,
              rtl: page.rtl?,
              tags: ['custom', 'user-generated'],
              created_at: page.created_at
            }
          end
          
          def import_template(template_data)
            validation_errors = validate_template(template_data)
            return { success: false, errors: validation_errors } unless validation_errors.empty?
            
            # Ensure unique ID
            if find_custom_template(template_data[:id])
              template_data[:id] = "#{template_data[:id]}_#{SecureRandom.hex(4)}"
            end
            
            template_data[:created_at] = Time.current
            template_data[:updated_at] = Time.current
            template_data[:version] = 1
            
            save_template_to_storage(template_data)
            { success: true, template: template_data }
          end
          
          def validate_template(template_data)
            required_fields = [:id, :name, :content, :language]
            errors = []
            
            required_fields.each do |field|
              errors << "Missing required field: #{field}" unless template_data[field]
            end
            
            if template_data[:content] && !valid_html?(template_data[:content])
              errors << "Invalid HTML content"
            end
            
            if template_data[:css] && !valid_css?(template_data[:css])
              errors << "Invalid CSS content"
            end
            
            errors
          end
          
          private
          
          def templates_directory
            Rails::Page::Builder.configuration.template_storage_path || 
              Rails.root.join('storage', 'page_builder', 'templates')
          end
          
          def ensure_templates_directory_exists
            FileUtils.mkdir_p(templates_directory) unless Dir.exist?(templates_directory)
            
            if Rails::Page::Builder.configuration.template_versioning
              versions_dir = File.join(templates_directory, 'versions')
              FileUtils.mkdir_p(versions_dir) unless Dir.exist?(versions_dir)
            end
          end
          
          def save_template_to_storage(template)
            ensure_templates_directory_exists
            
            template_path = File.join(templates_directory, "#{template[:id]}.json")
            File.write(template_path, JSON.pretty_generate(template))
          end
          
          def load_templates_from_storage
            return [] unless Dir.exist?(templates_directory)
            
            Dir.glob(File.join(templates_directory, "*.json")).map do |file|
              next if File.basename(file).start_with?('versions')
              JSON.parse(File.read(file), symbolize_names: true)
            end.compact
          end
          
          def backup_template(template)
            return unless Rails::Page::Builder.configuration.template_versioning
            
            versions_dir = File.join(templates_directory, 'versions', template[:id])
            FileUtils.mkdir_p(versions_dir) unless Dir.exist?(versions_dir)
            
            backup_filename = "v#{template[:version] || 1}_#{Time.current.to_i}.json"
            backup_path = File.join(versions_dir, backup_filename)
            
            File.write(backup_path, JSON.pretty_generate(template))
          end
          
          def valid_html?(html_content)
            # Basic HTML validation - in production, use a proper HTML parser
            return false if html_content.nil? || html_content.strip.empty?
            
            # Check for balanced tags (basic validation)
            open_tags = html_content.scan(/<(\w+)(?:\s[^>]*)?>/).flatten
            close_tags = html_content.scan(/<\/(\w+)>/).flatten
            
            # Self-closing tags that don't need closing tags
            self_closing = %w[img br hr input meta link]
            open_tags.reject! { |tag| self_closing.include?(tag.downcase) }
            
            open_tags.sort == close_tags.sort
          end
          
          def valid_css?(css_content)
            # Basic CSS validation - in production, use a proper CSS parser
            return true if css_content.nil? || css_content.strip.empty?
            
            # Check for balanced braces
            open_braces = css_content.count('{')
            close_braces = css_content.count('}')
            
            open_braces == close_braces
          end
        end
      end
    end
  end
end