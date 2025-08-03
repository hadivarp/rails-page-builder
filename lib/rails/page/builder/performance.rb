# frozen_string_literal: true

module Rails
  module Page
    module Builder
      class Performance
        include Singleton

        attr_reader :cache_store, :metrics

        def initialize
          @cache_store = Rails.cache
          @metrics = {}
          @compression_enabled = true
          @lazy_loading_enabled = true
        end

        # Content caching
        def cache_page_content(page_id, content, language = 'en', ttl = 1.hour)
          cache_key = page_content_cache_key(page_id, language)
          
          # Compress content if enabled
          cached_content = @compression_enabled ? compress_content(content) : content
          
          @cache_store.write(cache_key, {
            content: cached_content,
            compressed: @compression_enabled,
            cached_at: Time.current,
            language: language
          }, expires_in: ttl)
          
          record_cache_operation('page_content', 'write', cache_key)
        end

        def get_cached_page_content(page_id, language = 'en')
          cache_key = page_content_cache_key(page_id, language)
          cached_data = @cache_store.read(cache_key)
          
          if cached_data
            record_cache_operation('page_content', 'hit', cache_key)
            content = cached_data[:compressed] ? decompress_content(cached_data[:content]) : cached_data[:content]
            return {
              content: content,
              cached_at: cached_data[:cached_at],
              language: cached_data[:language]
            }
          end
          
          record_cache_operation('page_content', 'miss', cache_key)
          nil
        end

        def invalidate_page_cache(page_id, language = nil)
          if language
            cache_key = page_content_cache_key(page_id, language)
            @cache_store.delete(cache_key)
            record_cache_operation('page_content', 'delete', cache_key)
          else
            # Invalidate all language versions
            supported_languages = Rails::Page::Builder.configuration.supported_languages || ['en']
            supported_languages.each do |lang|
              invalidate_page_cache(page_id, lang)
            end
          end
        end

        # Block library caching
        def cache_block_library(language = 'en', ttl = 4.hours)
          cache_key = "block_library:#{language}"
          
          block_library = Rails::Page::Builder::BlockLibrary.new
          blocks = block_library.get_all_blocks(language)
          
          # Optimize block data for caching
          optimized_blocks = optimize_blocks_for_cache(blocks)
          
          @cache_store.write(cache_key, {
            blocks: optimized_blocks,
            cached_at: Time.current,
            language: language,
            version: block_library_version
          }, expires_in: ttl)
          
          record_cache_operation('block_library', 'write', cache_key)
        end

        def get_cached_block_library(language = 'en')
          cache_key = "block_library:#{language}"
          cached_data = @cache_store.read(cache_key)
          
          if cached_data && cached_data[:version] == block_library_version
            record_cache_operation('block_library', 'hit', cache_key)
            return cached_data[:blocks]
          end
          
          record_cache_operation('block_library', 'miss', cache_key)
          
          # Cache miss - generate and cache
          cache_block_library(language)
          get_cached_block_library(language)
        end

        # Template caching
        def cache_template(template_id, language = 'en', ttl = 2.hours)
          cache_key = "template:#{template_id}:#{language}"
          
          template_manager = Rails::Page::Builder::TemplateManager.new
          template_data = template_manager.get_template(template_id, language)
          
          return nil unless template_data
          
          # Optimize template for caching
          optimized_template = optimize_template_for_cache(template_data)
          
          @cache_store.write(cache_key, {
            template: optimized_template,
            cached_at: Time.current,
            language: language
          }, expires_in: ttl)
          
          record_cache_operation('template', 'write', cache_key)
        end

        def get_cached_template(template_id, language = 'en')
          cache_key = "template:#{template_id}:#{language}"
          cached_data = @cache_store.read(cache_key)
          
          if cached_data
            record_cache_operation('template', 'hit', cache_key)
            return cached_data[:template]
          end
          
          record_cache_operation('template', 'miss', cache_key)
          
          # Cache miss - generate and cache
          cache_template(template_id, language)
          get_cached_template(template_id, language)
        end

        # Asset optimization
        def optimize_css_assets(css_content)
          return css_content unless css_content.present?
          
          # Remove comments
          css_content = css_content.gsub(/\/\*.*?\*\//m, '')
          
          # Remove unnecessary whitespace
          css_content = css_content.gsub(/\s+/, ' ')
          
          # Remove whitespace around specific characters
          css_content = css_content.gsub(/\s*([{}:;,>+~])\s*/, '\1')
          
          # Remove trailing semicolon
          css_content = css_content.gsub(/;+}/, '}')
          
          css_content.strip
        end

        def optimize_js_assets(js_content)
          return js_content unless js_content.present?
          
          # Basic JavaScript minification
          # Remove single-line comments
          js_content = js_content.gsub(/\/\/.*$/, '')
          
          # Remove multi-line comments
          js_content = js_content.gsub(/\/\*.*?\*\//m, '')
          
          # Remove unnecessary whitespace (basic)
          js_content = js_content.gsub(/\s+/, ' ')
          
          # Remove whitespace around operators
          js_content = js_content.gsub(/\s*([{}();,=])\s*/, '\1')
          
          js_content.strip
        end

        def optimize_html_content(html_content)
          return html_content unless html_content.present?
          
          # Remove comments
          html_content = html_content.gsub(/<!--.*?-->/m, '')
          
          # Remove unnecessary whitespace between tags
          html_content = html_content.gsub(/>\s+</, '><')
          
          # Remove leading/trailing whitespace from lines
          html_content = html_content.lines.map(&:strip).join
          
          html_content
        end

        # Lazy loading implementation
        def add_lazy_loading_attributes(html_content)
          return html_content unless @lazy_loading_enabled
          
          # Add lazy loading to images
          html_content = html_content.gsub(/<img([^>]*?)src=["']([^"']+)["']([^>]*?)>/i) do |match|
            attributes = "#{$1}#{$3}"
            src = $2
            
            # Skip if already has loading attribute
            next match if attributes.include?('loading=')
            
            # Add lazy loading attributes
            "<img#{attributes} src=\"#{src}\" loading=\"lazy\" decoding=\"async\">"
          end
          
          # Add lazy loading to iframes
          html_content = html_content.gsub(/<iframe([^>]*?)>/i) do |match|
            attributes = $1
            
            # Skip if already has loading attribute
            next match if attributes.include?('loading=')
            
            "<iframe#{attributes} loading=\"lazy\">"
          end
          
          html_content
        end

        def generate_image_srcset(image_url, sizes = [480, 768, 1024, 1200])
          return image_url unless image_url.present?
          
          srcset_parts = sizes.map do |size|
            # This would integrate with your image processing service
            resized_url = resize_image_url(image_url, size)
            "#{resized_url} #{size}w"
          end
          
          srcset_parts.join(', ')
        end

        # Database query optimization
        def preload_page_associations(page_query)
          page_query.includes(
            :user,
            :collaborators,
            :page_assets,
            :page_comments,
            :page_versions
          )
        end

        def optimize_page_query(conditions = {})
          query = Page.all
          
          # Add only necessary conditions
          query = query.where(conditions) if conditions.any?
          
          # Preload associations
          query = preload_page_associations(query)
          
          # Add pagination to prevent large result sets
          query.limit(50)
        end

        # Memory management
        def monitor_memory_usage
          if defined?(GC)
            {
              objects_count: GC.stat[:heap_live_slots],
              gc_runs: GC.stat[:count],
              memory_usage: get_memory_usage
            }
          else
            {}
          end
        end

        def cleanup_expired_cache
          # Clean up expired cache entries
          expired_keys = find_expired_cache_keys
          expired_keys.each { |key| @cache_store.delete(key) }
          
          record_cache_operation('cleanup', 'expired_keys_removed', expired_keys.size)
        end

        def force_garbage_collection
          if defined?(GC)
            GC.start
            GC.compact if GC.respond_to?(:compact)
          end
        end

        # Performance monitoring
        def benchmark_operation(operation_name, &block)
          start_time = Time.current
          memory_before = get_memory_usage
          
          result = yield
          
          end_time = Time.current
          memory_after = get_memory_usage
          
          record_performance_metric(operation_name, {
            duration: end_time - start_time,
            memory_used: memory_after - memory_before,
            timestamp: start_time
          })
          
          result
        end

        def get_performance_metrics(operation_name = nil, since = 1.hour.ago)
          if operation_name
            @metrics[operation_name]&.select { |m| m[:timestamp] >= since } || []
          else
            @metrics.transform_values { |metrics| metrics.select { |m| m[:timestamp] >= since } }
          end
        end

        def get_cache_statistics
          cache_stats = {}
          
          @metrics.each do |operation, metrics|
            next unless operation.include?('cache')
            
            cache_stats[operation] = {
              total_operations: metrics.size,
              recent_operations: metrics.count { |m| m[:timestamp] >= 1.hour.ago }
            }
          end
          
          cache_stats
        end

        # CDN integration helpers
        def should_use_cdn?(asset_type, file_size = 0)
          cdn_config = Rails::Page::Builder.configuration.cdn_config
          return false unless cdn_config&.dig(:enabled)
          
          case asset_type
          when :image
            file_size >= (cdn_config[:image_threshold] || 100.kilobytes)
          when :video
            file_size >= (cdn_config[:video_threshold] || 1.megabyte)
          when :css, :js
            cdn_config[:static_assets] || false
          else
            false
          end
        end

        def generate_cdn_url(asset_path, options = {})
          cdn_config = Rails::Page::Builder.configuration.cdn_config
          return asset_path unless cdn_config&.dig(:enabled)
          
          base_url = cdn_config[:base_url]
          version = options[:version] || 'v1'
          
          "#{base_url}/#{version}/#{asset_path.gsub(/^\//, '')}"
        end

        private

        def page_content_cache_key(page_id, language)
          "page_content:#{page_id}:#{language}"
        end

        def block_library_version
          # Version based on configuration and block modifications
          @block_library_version ||= Digest::MD5.hexdigest([
            Rails::Page::Builder::VERSION,
            Rails::Page::Builder.configuration.to_h.to_s,
            File.mtime(Rails.root.join('lib', 'rails', 'page', 'builder', 'block_library.rb')).to_i
          ].join(':'))
        end

        def compress_content(content)
          return content unless content.present?
          
          if defined?(Zlib)
            Zlib::Deflate.deflate(content)
          else
            content
          end
        end

        def decompress_content(compressed_content)
          return compressed_content unless compressed_content.present?
          
          if defined?(Zlib)
            Zlib::Inflate.inflate(compressed_content)
          else
            compressed_content
          end
        end

        def optimize_blocks_for_cache(blocks)
          blocks.map do |block|
            {
              id: block[:id],
              label: block[:label],
              category: block[:category],
              content: optimize_html_content(block[:content]),
              css: optimize_css_assets(block[:css]),
              js: optimize_js_assets(block[:js]),
              preview: block[:preview]
            }
          end
        end

        def optimize_template_for_cache(template_data)
          {
            id: template_data[:id],
            name: template_data[:name],
            category: template_data[:category],
            content: optimize_html_content(template_data[:content]),
            css: optimize_css_assets(template_data[:css]),
            js: optimize_js_assets(template_data[:js]),
            thumbnail: template_data[:thumbnail],
            description: template_data[:description]
          }
        end

        def resize_image_url(original_url, width)
          # This would integrate with your image processing service
          # For example: ImageKit, Cloudinary, or custom service
          if original_url.include?('cloudinary.com')
            original_url.gsub('/upload/', "/upload/w_#{width}/")
          else
            # Fallback to original URL
            original_url
          end
        end

        def get_memory_usage
          if defined?(GC)
            GC.stat[:heap_live_slots] * 40 # Approximate bytes per object
          else
            0
          end
        end

        def find_expired_cache_keys
          # This would need to be implemented based on your cache store
          # For Redis: scan for keys and check TTL
          # For memory store: iterate through stored keys
          []
        end

        def record_cache_operation(type, operation, key_or_count)
          operation_name = "cache_#{type}_#{operation}"
          @metrics[operation_name] ||= []
          @metrics[operation_name] << {
            key: key_or_count.is_a?(String) ? key_or_count : nil,
            count: key_or_count.is_a?(Integer) ? key_or_count : 1,
            timestamp: Time.current
          }
          
          # Keep only last 1000 metrics for memory management
          @metrics[operation_name] = @metrics[operation_name].last(1000)
        end

        def record_performance_metric(operation_name, data)
          @metrics[operation_name] ||= []
          @metrics[operation_name] << data
          
          # Keep only last 500 metrics for memory management
          @metrics[operation_name] = @metrics[operation_name].last(500)
        end
      end

      # Middleware for performance monitoring
      class PerformanceMiddleware
        def initialize(app)
          @app = app
          @performance = Performance.instance
        end

        def call(env)
          request = ActionDispatch::Request.new(env)
          
          # Skip non-page-builder requests
          unless request.path.start_with?('/page_builder')
            return @app.call(env)
          end

          # Benchmark the request
          @performance.benchmark_operation("http_#{request.method.downcase}_#{request.path}") do
            @app.call(env)
          end
        end
      end

      # Controller concern for performance optimization
      module PerformanceConcern
        extend ActiveSupport::Concern

        included do
          before_action :enable_compression
          after_action :add_performance_headers
        end

        private

        def enable_compression
          if request.env['HTTP_ACCEPT_ENCODING']&.include?('gzip')
            response.headers['Content-Encoding'] = 'gzip'
          end
        end

        def add_performance_headers
          response.headers['X-Page-Builder-Cache'] = cache_status
          response.headers['X-Page-Builder-Performance'] = performance_info
        end

        def cache_status
          if performed_caching?
            'HIT'
          else
            'MISS'
          end
        end

        def performance_info
          {
            response_time: response_time_ms,
            memory_usage: current_memory_usage
          }.to_json
        end

        def response_time_ms
          if defined?(@request_start_time)
            ((Time.current - @request_start_time) * 1000).round(2)
          else
            0
          end
        end

        def current_memory_usage
          Performance.instance.monitor_memory_usage[:memory_usage] || 0
        end

        def performed_caching?
          response.headers['X-Cache'] == 'HIT'
        end
      end
    end
  end
end