# frozen_string_literal: true

require 'fileutils'
require 'securerandom'
require 'mime/types'

module Rails
  module Page
    module Builder
      class AssetManager
        class << self
          def upload_asset(file, options = {})
            validate_file(file)
            
            asset_id = SecureRandom.uuid
            filename = sanitize_filename(file.original_filename || 'unnamed')
            file_extension = File.extname(filename)
            stored_filename = "#{asset_id}#{file_extension}"
            
            asset_info = {
              id: asset_id,
              original_filename: filename,
              stored_filename: stored_filename,
              content_type: file.content_type || detect_content_type(filename),
              file_size: file.size,
              category: determine_category(file.content_type || detect_content_type(filename)),
              uploaded_at: Time.current,
              metadata: extract_metadata(file, options),
              url: generate_asset_url(stored_filename),
              thumbnail_url: nil
            }
            
            store_file(file, stored_filename)
            generate_thumbnail(asset_info) if image?(asset_info[:content_type])
            save_asset_metadata(asset_info)
            
            asset_info
          end
          
          def get_asset(asset_id)
            asset_metadata = load_asset_metadata(asset_id)
            return nil unless asset_metadata
            
            file_path = File.join(assets_directory, asset_metadata[:stored_filename])
            return nil unless File.exist?(file_path)
            
            asset_metadata
          end
          
          def delete_asset(asset_id)
            asset_info = get_asset(asset_id)
            return false unless asset_info
            
            file_path = File.join(assets_directory, asset_info[:stored_filename])
            thumbnail_path = File.join(thumbnails_directory, "thumb_#{asset_info[:stored_filename]}")
            
            File.delete(file_path) if File.exist?(file_path)
            File.delete(thumbnail_path) if File.exist?(thumbnail_path)
            
            delete_asset_metadata(asset_id)
            true
          end
          
          def list_assets(category: nil, limit: 50, offset: 0)
            assets = load_all_assets_metadata
            
            assets = assets.select { |asset| asset[:category] == category } if category
            assets = assets.sort_by { |asset| asset[:uploaded_at] }.reverse
            assets = assets.drop(offset).take(limit)
            
            assets
          end
          
          def get_asset_categories
            %w[image video audio document archive other]
          end
          
          def optimize_image(asset_id, options = {})
            asset_info = get_asset(asset_id)
            return nil unless asset_info && image?(asset_info[:content_type])
            
            original_path = File.join(assets_directory, asset_info[:stored_filename])
            optimized_filename = "optimized_#{asset_info[:stored_filename]}"
            optimized_path = File.join(assets_directory, optimized_filename)
            
            # In a real implementation, you would use image processing libraries
            # like ImageMagick, Vips, or similar
            FileUtils.cp(original_path, optimized_path)
            
            {
              original_url: asset_info[:url],
              optimized_url: generate_asset_url(optimized_filename),
              size_reduction: calculate_size_reduction(original_path, optimized_path)
            }
          end
          
          def create_asset_variant(asset_id, variant_options = {})
            asset_info = get_asset(asset_id)
            return nil unless asset_info && image?(asset_info[:content_type])
            
            variant_id = SecureRandom.uuid
            variant_filename = "#{variant_id}_#{variant_options[:width]}x#{variant_options[:height]}_#{asset_info[:stored_filename]}"
            
            # In a real implementation, you would resize the image here
            original_path = File.join(assets_directory, asset_info[:stored_filename])
            variant_path = File.join(assets_directory, variant_filename)
            FileUtils.cp(original_path, variant_path)
            
            {
              id: variant_id,
              parent_asset_id: asset_id,
              filename: variant_filename,
              url: generate_asset_url(variant_filename),
              dimensions: {
                width: variant_options[:width],
                height: variant_options[:height]
              }
            }
          end
          
          private
          
          def validate_file(file)
            raise ArgumentError, "File is required" unless file
            raise ArgumentError, "File is too large" if file.size > max_file_size
            raise ArgumentError, "File type not allowed" unless allowed_file_type?(file.content_type)
          end
          
          def sanitize_filename(filename)
            # Remove any path components and sanitize the filename
            filename = File.basename(filename)
            filename.gsub(/[^a-zA-Z0-9\-_\.]/, '_')
          end
          
          def determine_category(content_type)
            case content_type
            when /^image\//
              'image'
            when /^video\//
              'video'
            when /^audio\//
              'audio'
            when /^application\/(pdf|msword|vnd\.ms-excel|vnd\.ms-powerpoint)/
              'document'
            when /^application\/(zip|x-rar|x-tar|gzip)/
              'archive'
            else
              'other'
            end
          end
          
          def extract_metadata(file, options)
            metadata = {
              title: options[:title],
              alt_text: options[:alt_text],
              description: options[:description],
              tags: options[:tags] || []
            }
            
            if image?(file.content_type)
              # In a real implementation, you would extract EXIF data here
              metadata.merge!({
                dimensions: { width: nil, height: nil },
                exif: {}
              })
            end
            
            metadata
          end
          
          def store_file(file, stored_filename)
            ensure_directories_exist
            
            file_path = File.join(assets_directory, stored_filename)
            File.open(file_path, 'wb') do |f|
              if file.respond_to?(:read)
                f.write(file.read)
              else
                f.write(file)
              end
            end
          end
          
          def generate_thumbnail(asset_info)
            return unless image?(asset_info[:content_type])
            
            original_path = File.join(assets_directory, asset_info[:stored_filename])
            thumbnail_filename = "thumb_#{asset_info[:stored_filename]}"
            thumbnail_path = File.join(thumbnails_directory, thumbnail_filename)
            
            # In a real implementation, you would generate a thumbnail here
            FileUtils.cp(original_path, thumbnail_path)
            
            asset_info[:thumbnail_url] = generate_thumbnail_url(thumbnail_filename)
          end
          
          def save_asset_metadata(asset_info)
            ensure_directories_exist
            
            metadata_file = File.join(metadata_directory, "#{asset_info[:id]}.json")
            File.write(metadata_file, asset_info.to_json)
          end
          
          def load_asset_metadata(asset_id)
            metadata_file = File.join(metadata_directory, "#{asset_id}.json")
            return nil unless File.exist?(metadata_file)
            
            JSON.parse(File.read(metadata_file), symbolize_names: true)
          end
          
          def load_all_assets_metadata
            return [] unless Dir.exist?(metadata_directory)
            
            Dir.glob(File.join(metadata_directory, "*.json")).map do |file|
              JSON.parse(File.read(file), symbolize_names: true)
            end
          end
          
          def delete_asset_metadata(asset_id)
            metadata_file = File.join(metadata_directory, "#{asset_id}.json")
            File.delete(metadata_file) if File.exist?(metadata_file)
          end
          
          def image?(content_type)
            content_type&.start_with?('image/')
          end
          
          def allowed_file_type?(content_type)
            allowed_types = [
              'image/jpeg', 'image/png', 'image/gif', 'image/svg+xml', 'image/webp',
              'video/mp4', 'video/webm', 'video/ogg',
              'audio/mp3', 'audio/wav', 'audio/ogg',
              'application/pdf', 'application/msword', 'application/vnd.ms-excel',
              'text/plain', 'text/css', 'text/javascript',
              'application/zip', 'application/x-rar'
            ]
            
            allowed_types.include?(content_type)
          end
          
          def max_file_size
            begin
              Rails::Page::Builder.configuration.max_file_size || 10 * 1024 * 1024
            rescue
              10 * 1024 * 1024
            end
          end
          
          def assets_directory
            begin
              Rails::Page::Builder.configuration.assets_path || default_assets_path
            rescue
              default_assets_path
            end
          end
          
          def thumbnails_directory
            begin
              Rails::Page::Builder.configuration.thumbnails_path || default_thumbnails_path
            rescue
              default_thumbnails_path
            end
          end
          
          def metadata_directory
            begin
              Rails::Page::Builder.configuration.metadata_path || default_metadata_path
            rescue
              default_metadata_path
            end
          end
          
          def default_assets_path
            if defined?(Rails) && Rails.respond_to?(:root)
              Rails.root.join('storage', 'page_builder', 'assets')
            else
              File.join(Dir.pwd, 'storage', 'page_builder', 'assets')
            end
          end
          
          def default_thumbnails_path
            if defined?(Rails) && Rails.respond_to?(:root)
              Rails.root.join('storage', 'page_builder', 'thumbnails')
            else
              File.join(Dir.pwd, 'storage', 'page_builder', 'thumbnails')
            end
          end
          
          def default_metadata_path
            if defined?(Rails) && Rails.respond_to?(:root)
              Rails.root.join('storage', 'page_builder', 'metadata')
            else
              File.join(Dir.pwd, 'storage', 'page_builder', 'metadata')
            end
          end
          
          def ensure_directories_exist
            [assets_directory, thumbnails_directory, metadata_directory].each do |dir|
              FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
            end
          end
          
          def generate_asset_url(filename)
            begin
              base_url = Rails::Page::Builder.configuration.asset_host || "/page_builder/assets"
            rescue
              base_url = "/page_builder/assets"
            end
            "#{base_url}/#{filename}"
          end
          
          def generate_thumbnail_url(filename)
            begin
              base_url = Rails::Page::Builder.configuration.asset_host || "/page_builder/thumbnails"
            rescue
              base_url = "/page_builder/thumbnails"
            end
            "#{base_url}/#{filename}"
          end
          
          def detect_content_type(filename)
            mime_type = MIME::Types.type_for(filename).first
            mime_type ? mime_type.content_type : 'application/octet-stream'
          end
          
          def calculate_size_reduction(original_path, optimized_path)
            original_size = File.size(original_path)
            optimized_size = File.size(optimized_path)
            
            {
              original_size: original_size,
              optimized_size: optimized_size,
              percentage_reduction: ((original_size - optimized_size).to_f / original_size * 100).round(2)
            }
          end
        end
      end
    end
  end
end