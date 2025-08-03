# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'base64'

module Rails
  module Page
    module Builder
      class ApiIntegration
        class ApiError < StandardError; end
        class AuthenticationError < ApiError; end
        class RateLimitError < ApiError; end
        class ServiceUnavailableError < ApiError; end

        class << self
          attr_accessor :registered_apis, :api_cache

          def initialize_system
            @registered_apis = {}
            @api_cache = {}
            @request_count = {}
            @last_request_time = {}
          end

          # API Registration and Management
          def register_api(api_name, config)
            validate_api_config!(config)
            
            @registered_apis[api_name.to_sym] = {
              name: api_name,
              base_url: config[:base_url],
              authentication: config[:authentication] || {},
              rate_limit: config[:rate_limit] || { requests: 100, period: 3600 },
              timeout: config[:timeout] || 30,
              retries: config[:retries] || 3,
              headers: config[:headers] || {},
              endpoints: config[:endpoints] || {},
              cache_ttl: config[:cache_ttl] || 300,
              active: config[:active].nil? ? true : config[:active]
            }
          end

          def unregister_api(api_name)
            @registered_apis.delete(api_name.to_sym)
            @api_cache.delete(api_name.to_sym)
            @request_count.delete(api_name.to_sym)
            @last_request_time.delete(api_name.to_sym)
          end

          def get_api_config(api_name)
            @registered_apis[api_name.to_sym]
          end

          def list_apis
            @registered_apis.keys
          end

          def active_apis
            @registered_apis.select { |_, config| config[:active] }.keys
          end

          # Generic API Request Method
          def make_request(api_name, endpoint, options = {})
            api_config = get_api_config(api_name)
            raise ApiError, "API '#{api_name}' not registered" unless api_config
            raise ApiError, "API '#{api_name}' is disabled" unless api_config[:active]

            # Check rate limiting
            check_rate_limit!(api_name, api_config)

            # Check cache first
            cache_key = generate_cache_key(api_name, endpoint, options)
            if cached_response = get_cached_response(cache_key, api_config[:cache_ttl])
              return cached_response
            end

            # Prepare request
            url = build_url(api_config[:base_url], endpoint)
            headers = build_headers(api_config, options[:headers] || {})
            
            response = nil
            retries = api_config[:retries]

            (retries + 1).times do |attempt|
              begin
                response = execute_request(url, options.merge(headers: headers), api_config)
                break
              rescue Net::TimeoutError, Net::ReadTimeout => e
                if attempt < retries
                  sleep(2 ** attempt) # Exponential backoff
                  next
                else
                  raise ApiError, "Request timeout after #{retries} retries: #{e.message}"
                end
              rescue => e
                raise ApiError, "Request failed: #{e.message}"
              end
            end

            # Update request tracking
            update_request_tracking(api_name)

            # Parse and cache response
            parsed_response = parse_response(response)
            cache_response(cache_key, parsed_response, api_config[:cache_ttl])

            parsed_response
          end

          # Specific API Methods
          def get(api_name, endpoint, params = {}, options = {})
            make_request(api_name, endpoint, options.merge(
              method: :get,
              params: params
            ))
          end

          def post(api_name, endpoint, data = {}, options = {})
            make_request(api_name, endpoint, options.merge(
              method: :post,
              data: data
            ))
          end

          def put(api_name, endpoint, data = {}, options = {})
            make_request(api_name, endpoint, options.merge(
              method: :put,
              data: data
            ))
          end

          def delete(api_name, endpoint, options = {})
            make_request(api_name, endpoint, options.merge(
              method: :delete
            ))
          end

          # Predefined API Integrations
          def setup_common_apis
            setup_unsplash_api
            setup_youtube_api
            setup_google_fonts_api
            setup_stripe_api
            setup_mailchimp_api
            setup_social_media_apis
          end

          # Content APIs
          def fetch_unsplash_images(query, per_page = 10)
            get(:unsplash, '/search/photos', {
              query: query,
              per_page: per_page,
              orientation: 'landscape'
            })
          end

          def fetch_youtube_videos(query, max_results = 10)
            get(:youtube, '/search', {
              part: 'snippet',
              q: query,
              maxResults: max_results,
              type: 'video'
            })
          end

          def fetch_google_fonts
            get(:google_fonts, '/webfonts', {
              sort: 'popularity'
            })
          end

          # E-commerce APIs
          def create_stripe_payment_intent(amount, currency = 'usd')
            post(:stripe, '/payment_intents', {
              amount: amount,
              currency: currency,
              automatic_payment_methods: { enabled: true }
            })
          end

          # Marketing APIs
          def add_mailchimp_subscriber(list_id, email, merge_fields = {})
            post(:mailchimp, "/lists/#{list_id}/members", {
              email_address: email,
              status: 'subscribed',
              merge_fields: merge_fields
            })
          end

          # Social Media APIs
          def fetch_twitter_timeline(username, count = 10)
            get(:twitter, '/statuses/user_timeline', {
              screen_name: username,
              count: count,
              include_rts: false
            })
          end

          def fetch_instagram_media(user_id, count = 10)
            get(:instagram, "/#{user_id}/media", {
              fields: 'id,caption,media_type,media_url,thumbnail_url,timestamp',
              limit: count
            })
          end

          # Cache Management
          def clear_cache(api_name = nil)
            if api_name
              @api_cache.delete(api_name.to_sym)
            else
              @api_cache.clear
            end
          end

          def cache_stats
            total_entries = @api_cache.values.sum { |api_cache| api_cache.keys.count }
            {
              total_entries: total_entries,
              apis_cached: @api_cache.keys.count,
              cache_size_mb: estimate_cache_size
            }
          end

          # Rate Limiting and Monitoring
          def api_stats(api_name)
            config = get_api_config(api_name)
            return nil unless config

            {
              requests_made: @request_count[api_name.to_sym] || 0,
              last_request: @last_request_time[api_name.to_sym],
              rate_limit: config[:rate_limit],
              cache_entries: (@api_cache[api_name.to_sym] || {}).keys.count
            }
          end

          def all_api_stats
            @registered_apis.keys.map { |api_name| [api_name, api_stats(api_name)] }.to_h
          end

          private

          def validate_api_config!(config)
            required_fields = [:base_url]
            missing_fields = required_fields.select { |field| config[field].nil? }
            
            if missing_fields.any?
              raise ApiError, "Missing required API config fields: #{missing_fields.join(', ')}"
            end

            # Validate URL format
            begin
              URI.parse(config[:base_url])
            rescue URI::InvalidURIError
              raise ApiError, "Invalid base_url format"
            end
          end

          def check_rate_limit!(api_name, config)
            return unless config[:rate_limit]

            now = Time.now
            period = config[:rate_limit][:period]
            max_requests = config[:rate_limit][:requests]

            # Reset count if period has passed
            if @last_request_time[api_name.to_sym].nil? || 
               (now - @last_request_time[api_name.to_sym]) > period
              @request_count[api_name.to_sym] = 0
            end

            current_count = @request_count[api_name.to_sym] || 0
            if current_count >= max_requests
              raise RateLimitError, "Rate limit exceeded for API '#{api_name}'"
            end
          end

          def build_url(base_url, endpoint)
            base_url = base_url.chomp('/')
            endpoint = endpoint.start_with?('/') ? endpoint : "/#{endpoint}"
            "#{base_url}#{endpoint}"
          end

          def build_headers(api_config, custom_headers)
            headers = api_config[:headers].dup
            headers.merge!(custom_headers)

            # Add authentication headers
            if auth = api_config[:authentication]
              case auth[:type]
              when 'bearer'
                headers['Authorization'] = "Bearer #{auth[:token]}"
              when 'api_key'
                if auth[:header]
                  headers[auth[:header]] = auth[:key]
                else
                  headers['X-API-Key'] = auth[:key]
                end
              when 'basic'
                credentials = Base64.strict_encode64("#{auth[:username]}:#{auth[:password]}")
                headers['Authorization'] = "Basic #{credentials}"
              end
            end

            headers['Content-Type'] ||= 'application/json'
            headers['User-Agent'] ||= 'Rails-Page-Builder/1.0'

            headers
          end

          def execute_request(url, options, api_config)
            uri = URI(url)
            
            # Add query parameters for GET requests
            if options[:method] == :get && options[:params]
              uri.query = URI.encode_www_form(options[:params])
            end

            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = uri.scheme == 'https'
            http.read_timeout = api_config[:timeout]
            http.open_timeout = api_config[:timeout]

            case options[:method]
            when :get
              request = Net::HTTP::Get.new(uri)
            when :post
              request = Net::HTTP::Post.new(uri)
              request.body = options[:data].to_json if options[:data]
            when :put
              request = Net::HTTP::Put.new(uri)
              request.body = options[:data].to_json if options[:data]
            when :delete
              request = Net::HTTP::Delete.new(uri)
            else
              raise ApiError, "Unsupported HTTP method: #{options[:method]}"
            end

            # Set headers
            options[:headers].each { |key, value| request[key] = value }

            response = http.request(request)
            
            # Handle HTTP errors
            case response.code.to_i
            when 200..299
              response
            when 401
              raise AuthenticationError, "Authentication failed for #{uri.host}"
            when 429
              raise RateLimitError, "Rate limit exceeded for #{uri.host}"
            when 500..599
              raise ServiceUnavailableError, "Service unavailable: #{uri.host}"
            else
              raise ApiError, "HTTP #{response.code}: #{response.message}"
            end
          end

          def parse_response(response)
            content_type = response['content-type'] || ''
            
            if content_type.include?('application/json')
              JSON.parse(response.body)
            else
              response.body
            end
          rescue JSON::ParserError
            response.body
          end

          def generate_cache_key(api_name, endpoint, options)
            key_parts = [api_name, endpoint, options[:params], options[:data]].compact
            Digest::MD5.hexdigest(key_parts.to_json)
          end

          def get_cached_response(cache_key, ttl)
            @api_cache.each do |api_name, api_cache|
              if cached_data = api_cache[cache_key]
                if Time.now - cached_data[:timestamp] < ttl
                  return cached_data[:response]
                else
                  api_cache.delete(cache_key)
                end
              end
            end
            nil
          end

          def cache_response(cache_key, response, ttl)
            # Determine which API this belongs to (simplified approach)
            api_name = :general
            @api_cache[api_name] ||= {}
            @api_cache[api_name][cache_key] = {
              response: response,
              timestamp: Time.now
            }
          end

          def update_request_tracking(api_name)
            @request_count[api_name.to_sym] = (@request_count[api_name.to_sym] || 0) + 1
            @last_request_time[api_name.to_sym] = Time.now
          end

          def estimate_cache_size
            # Rough estimation in MB
            total_size = @api_cache.values.sum do |api_cache|
              api_cache.values.sum { |cached_data| cached_data.to_json.bytesize }
            end
            (total_size / (1024.0 * 1024.0)).round(2)
          end

          # Predefined API Configurations
          def setup_unsplash_api
            register_api(:unsplash, {
              base_url: 'https://api.unsplash.com',
              authentication: {
                type: 'api_key',
                header: 'Authorization',
                key: 'Client-ID YOUR_UNSPLASH_ACCESS_KEY'
              },
              rate_limit: { requests: 50, period: 3600 },
              cache_ttl: 3600
            })
          end

          def setup_youtube_api
            register_api(:youtube, {
              base_url: 'https://www.googleapis.com/youtube/v3',
              authentication: {
                type: 'api_key',
                header: 'key'
              },
              rate_limit: { requests: 100, period: 3600 },
              cache_ttl: 1800
            })
          end

          def setup_google_fonts_api
            register_api(:google_fonts, {
              base_url: 'https://www.googleapis.com/webfonts/v1',
              authentication: {
                type: 'api_key',
                header: 'key'
              },
              rate_limit: { requests: 1000, period: 3600 },
              cache_ttl: 86400 # 24 hours
            })
          end

          def setup_stripe_api
            register_api(:stripe, {
              base_url: 'https://api.stripe.com/v1',
              authentication: {
                type: 'bearer',
                token: 'YOUR_STRIPE_SECRET_KEY'
              },
              rate_limit: { requests: 100, period: 60 },
              cache_ttl: 0 # No caching for payment APIs
            })
          end

          def setup_mailchimp_api
            register_api(:mailchimp, {
              base_url: 'https://YOUR_DC.api.mailchimp.com/3.0',
              authentication: {
                type: 'api_key',
                header: 'Authorization',
                key: 'apikey YOUR_MAILCHIMP_API_KEY'
              },
              rate_limit: { requests: 10, period: 60 },
              cache_ttl: 300
            })
          end

          def setup_social_media_apis
            # Twitter API
            register_api(:twitter, {
              base_url: 'https://api.twitter.com/1.1',
              authentication: {
                type: 'bearer',
                token: 'YOUR_TWITTER_BEARER_TOKEN'
              },
              rate_limit: { requests: 15, period: 900 },
              cache_ttl: 300
            })

            # Instagram Basic Display API
            register_api(:instagram, {
              base_url: 'https://graph.instagram.com',
              authentication: {
                type: 'bearer',
                token: 'YOUR_INSTAGRAM_ACCESS_TOKEN'
              },
              rate_limit: { requests: 200, period: 3600 },
              cache_ttl: 600
            })
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

# Initialize the API integration system
Rails::Page::Builder::ApiIntegration.initialize_system