# frozen_string_literal: true

module Rails
  module Page
    module Builder
      class Security
        include ActiveSupport::Callbacks
        define_callbacks :permission_check, :access_denied

        ROLES = {
          guest: 0,
          viewer: 10,
          editor: 20,
          admin: 30,
          owner: 40
        }.freeze

        PERMISSIONS = {
          view_page: [:viewer, :editor, :admin, :owner],
          edit_page: [:editor, :admin, :owner],
          delete_page: [:admin, :owner],
          manage_collaborators: [:admin, :owner],
          change_permissions: [:owner],
          view_analytics: [:admin, :owner],
          export_page: [:editor, :admin, :owner],
          duplicate_page: [:editor, :admin, :owner],
          publish_page: [:admin, :owner],
          manage_templates: [:admin, :owner],
          manage_assets: [:editor, :admin, :owner]
        }.freeze

        attr_reader :user, :page, :context

        def initialize(user, page = nil, context = {})
          @user = user
          @page = page
          @context = context
        end

        # Permission checking
        def can?(action, resource = nil)
          run_callbacks :permission_check do
            case action
            when Symbol
              check_permission(action, resource)
            when String
              check_custom_permission(action, resource)
            else
              false
            end
          end
        end

        def cannot?(action, resource = nil)
          !can?(action, resource)
        end

        def authorize!(action, resource = nil)
          unless can?(action, resource)
            run_callbacks :access_denied do
              raise SecurityError, "Access denied for action: #{action}"
            end
          end
          true
        end

        # Role management
        def user_role(target_page = nil)
          target_page ||= @page
          return :guest unless @user && target_page

          if target_page.user_id == @user.id
            :owner
          elsif collaborator = target_page.collaborators.find_by(user_id: @user.id)
            collaborator.role.to_sym
          else
            :guest
          end
        end

        def has_role?(role, target_page = nil)
          user_role_level = ROLES[user_role(target_page)] || 0
          required_level = ROLES[role.to_sym] || 0
          user_role_level >= required_level
        end

        # Content security
        def sanitize_content(html_content)
          # Remove potentially dangerous HTML elements and attributes
          sanitized = Loofah.fragment(html_content).scrub!(:escape)
          
          # Additional custom sanitization
          sanitized = remove_script_tags(sanitized.to_s)
          sanitized = sanitize_event_handlers(sanitized)
          sanitized = validate_external_links(sanitized)
          
          sanitized
        end

        def validate_asset_upload(file, user_permissions = [])
          errors = []

          # File type validation
          unless allowed_file_type?(file.content_type)
            errors << "File type '#{file.content_type}' is not allowed"
          end

          # File size validation
          max_size = get_max_file_size(user_permissions)
          if file.size > max_size
            errors << "File size exceeds maximum allowed size of #{max_size / 1.megabyte}MB"
          end

          # File name validation
          unless valid_filename?(file.original_filename)
            errors << "Invalid filename: #{file.original_filename}"
          end

          # Virus scanning (if configured)
          if virus_scanning_enabled? && has_virus?(file)
            errors << "File contains malicious content"
          end

          errors.empty? ? { valid: true } : { valid: false, errors: errors }
        end

        # API rate limiting
        def check_rate_limit(user_id, action, limit_per_minute = 60)
          key = "rate_limit:#{user_id}:#{action}:#{Time.current.strftime('%Y%m%d%H%M')}"
          current_count = Rails.cache.read(key) || 0
          
          if current_count >= limit_per_minute
            return { allowed: false, retry_after: 60 - Time.current.sec }
          end

          Rails.cache.write(key, current_count + 1, expires_in: 1.minute)
          { allowed: true, remaining: limit_per_minute - current_count - 1 }
        end

        # Session security
        def validate_session_token(token, user_id)
          return false unless token && user_id

          stored_token = Rails.cache.read("session_token:#{user_id}")
          return false unless stored_token

          # Constant time comparison to prevent timing attacks
          ActiveSupport::SecurityUtils.secure_compare(token, stored_token)
        end

        def generate_csrf_token(session_id)
          timestamp = Time.current.to_i
          data = "#{session_id}:#{timestamp}"
          signature = OpenSSL::HMAC.hexdigest('SHA256', csrf_secret_key, data)
          Base64.strict_encode64("#{data}:#{signature}")
        end

        def validate_csrf_token(token, session_id)
          return false unless token && session_id

          begin
            decoded = Base64.strict_decode64(token)
            data, signature = decoded.rsplit(':', 2)
            session_from_token, timestamp = data.split(':', 2)
            
            # Validate session ID matches
            return false unless ActiveSupport::SecurityUtils.secure_compare(session_from_token, session_id)
            
            # Validate timestamp (token expires in 1 hour)
            return false if Time.current.to_i - timestamp.to_i > 3600
            
            # Validate signature
            expected_signature = OpenSSL::HMAC.hexdigest('SHA256', csrf_secret_key, data)
            ActiveSupport::SecurityUtils.secure_compare(signature, expected_signature)
          rescue => e
            Rails.logger.warn "CSRF token validation error: #{e.message}"
            false
          end
        end

        # IP-based restrictions
        def ip_allowed?(ip_address, user_role = :guest)
          return true unless ip_restrictions_enabled?

          allowed_ranges = get_allowed_ip_ranges(user_role)
          return true if allowed_ranges.empty?

          allowed_ranges.any? do |range|
            if range.include?('/')
              IPAddr.new(range).include?(ip_address)
            else
              range == ip_address
            end
          end
        end

        # Audit logging
        def log_security_event(event_type, details = {})
          Rails.logger.info({
            event: 'page_builder_security',
            type: event_type,
            user_id: @user&.id,
            page_id: @page&.id,
            ip_address: @context[:ip_address],
            user_agent: @context[:user_agent],
            timestamp: Time.current.iso8601,
            details: details
          }.to_json)
        end

        private

        def check_permission(action, resource = nil)
          return false unless PERMISSIONS.key?(action)
          
          required_roles = PERMISSIONS[action]
          current_role = user_role(resource)
          
          required_roles.include?(current_role)
        end

        def check_custom_permission(action, resource = nil)
          # Handle custom permissions defined in configuration
          custom_permissions = Rails::Page::Builder.configuration.custom_permissions || {}
          return false unless custom_permissions.key?(action.to_sym)
          
          permission_config = custom_permissions[action.to_sym]
          required_roles = permission_config[:roles] || []
          
          current_role = user_role(resource)
          required_roles.include?(current_role)
        end

        def remove_script_tags(html)
          html.gsub(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/mi, '')
        end

        def sanitize_event_handlers(html)
          # Remove common event handlers
          event_handlers = %w[onclick onload onmouseover onfocus onblur onchange onsubmit]
          event_handlers.each do |handler|
            html = html.gsub(/#{handler}\s*=\s*["'][^"']*["']/i, '')
          end
          html
        end

        def validate_external_links(html)
          # Ensure external links have proper security attributes
          html.gsub(/<a\s+([^>]*href\s*=\s*["']https?:\/\/[^"']+["'][^>]*)>/i) do |match|
            attributes = $1
            unless attributes.include?('rel=')
              attributes += ' rel="noopener noreferrer"'
            end
            unless attributes.include?('target=')
              attributes += ' target="_blank"'
            end
            "<a #{attributes}>"
          end
        end

        def allowed_file_type?(content_type)
          allowed_types = Rails::Page::Builder.configuration.allowed_file_types || [
            'image/jpeg', 'image/png', 'image/gif', 'image/webp',
            'video/mp4', 'video/webm',
            'audio/mp3', 'audio/wav',
            'application/pdf',
            'text/plain', 'text/css'
          ]
          allowed_types.include?(content_type)
        end

        def get_max_file_size(user_permissions)
          if user_permissions.include?(:admin)
            50.megabytes
          elsif user_permissions.include?(:editor)
            25.megabytes
          else
            10.megabytes
          end
        end

        def valid_filename?(filename)
          # Check for suspicious filename patterns
          return false if filename.blank?
          return false if filename.include?('..')
          return false if filename.match?(/[<>:"|?*]/)
          return false if filename.length > 255
          
          true
        end

        def virus_scanning_enabled?
          Rails::Page::Builder.configuration.virus_scanning_enabled || false
        end

        def has_virus?(file)
          # Placeholder for virus scanning integration
          # In production, integrate with ClamAV or similar
          false
        end

        def csrf_secret_key
          Rails.application.secret_key_base || 'fallback_secret_key'
        end

        def ip_restrictions_enabled?
          Rails::Page::Builder.configuration.ip_restrictions_enabled || false
        end

        def get_allowed_ip_ranges(user_role)
          restrictions = Rails::Page::Builder.configuration.ip_restrictions || {}
          restrictions[user_role] || restrictions[:default] || []
        end
      end

      # Middleware for request security
      class SecurityMiddleware
        def initialize(app)
          @app = app
        end

        def call(env)
          request = ActionDispatch::Request.new(env)
          
          # Skip non-page-builder requests
          unless request.path.start_with?('/page_builder')
            return @app.call(env)
          end

          # Check IP restrictions
          if ip_restricted?(request)
            return [403, {}, ['IP address not allowed']]
          end

          # Add security headers
          status, headers, response = @app.call(env)
          add_security_headers(headers)
          
          [status, headers, response]
        end

        private

        def ip_restricted?(request)
          return false unless Rails::Page::Builder.configuration.ip_restrictions_enabled
          
          security = Security.new(nil, nil, { ip_address: request.remote_ip })
          !security.ip_allowed?(request.remote_ip, :guest)
        end

        def add_security_headers(headers)
          headers['X-Frame-Options'] = 'SAMEORIGIN'
          headers['X-Content-Type-Options'] = 'nosniff'
          headers['X-XSS-Protection'] = '1; mode=block'
          headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
          headers['Content-Security-Policy'] = generate_csp_header
        end

        def generate_csp_header
          directives = [
            "default-src 'self'",
            "script-src 'self' 'unsafe-inline' 'unsafe-eval' unpkg.com cdnjs.cloudflare.com",
            "style-src 'self' 'unsafe-inline' unpkg.com fonts.googleapis.com",
            "font-src 'self' fonts.gstatic.com",
            "img-src 'self' data: blob: https:",
            "media-src 'self' blob:",
            "connect-src 'self' ws: wss:",
            "frame-ancestors 'self'"
          ]
          directives.join('; ')
        end
      end
    end
  end
end