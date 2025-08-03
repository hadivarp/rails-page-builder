# frozen_string_literal: true

module Rails
  module Page
    module Builder
      class Permissions
        attr_reader :user, :resource, :context

        def initialize(user, resource = nil, context = {})
          @user = user
          @resource = resource
          @context = context
        end

        # Permission checking methods
        def can_view_page?(page = nil)
          page ||= @resource
          return false unless page
          
          # Public pages can be viewed by anyone
          return true if page.public?
          
          # Check user permissions
          security = Security.new(@user, page, @context)
          security.can?(:view_page, page)
        end

        def can_edit_page?(page = nil)
          page ||= @resource
          return false unless page && @user
          
          security = Security.new(@user, page, @context)
          security.can?(:edit_page, page)
        end

        def can_delete_page?(page = nil)
          page ||= @resource
          return false unless page && @user
          
          security = Security.new(@user, page, @context)
          security.can?(:delete_page, page)
        end

        def can_manage_collaborators?(page = nil)
          page ||= @resource
          return false unless page && @user
          
          security = Security.new(@user, page, @context)
          security.can?(:manage_collaborators, page)
        end

        def can_change_permissions?(page = nil)
          page ||= @resource
          return false unless page && @user
          
          security = Security.new(@user, page, @context)
          security.can?(:change_permissions, page)
        end

        def can_view_analytics?(page = nil)
          page ||= @resource
          return false unless page && @user
          
          security = Security.new(@user, page, @context)
          security.can?(:view_analytics, page)
        end

        def can_export_page?(page = nil)
          page ||= @resource
          return false unless page && @user
          
          security = Security.new(@user, page, @context)
          security.can?(:export_page, page)
        end

        def can_publish_page?(page = nil)
          page ||= @resource
          return false unless page && @user
          
          security = Security.new(@user, page, @context)
          security.can?(:publish_page, page)
        end

        def can_manage_templates?
          return false unless @user
          
          security = Security.new(@user, nil, @context)
          security.can?(:manage_templates)
        end

        def can_manage_assets?
          return false unless @user
          
          security = Security.new(@user, @resource, @context)
          security.can?(:manage_assets)
        end

        # Collaboration permissions
        def can_invite_collaborator?(page = nil, target_role = :viewer)
          page ||= @resource
          return false unless can_manage_collaborators?(page)
          
          # Can't invite someone to a higher role than your own
          user_role = Security.new(@user, page, @context).user_role
          user_level = Security::ROLES[user_role] || 0
          target_level = Security::ROLES[target_role.to_sym] || 0
          
          user_level > target_level
        end

        def can_remove_collaborator?(page = nil, collaborator_user = nil)
          page ||= @resource
          return false unless can_manage_collaborators?(page)
          return false unless collaborator_user
          
          # Can't remove someone with equal or higher role
          security = Security.new(@user, page, @context)
          user_role = security.user_role
          collaborator_role = Security.new(collaborator_user, page, @context).user_role
          
          user_level = Security::ROLES[user_role] || 0
          collaborator_level = Security::ROLES[collaborator_role] || 0
          
          user_level > collaborator_level
        end

        def can_change_collaborator_role?(page = nil, collaborator_user = nil, new_role = nil)
          page ||= @resource
          return false unless can_manage_collaborators?(page)
          return false unless collaborator_user && new_role
          
          security = Security.new(@user, page, @context)
          user_role = security.user_role
          current_collaborator_role = Security.new(collaborator_user, page, @context).user_role
          
          user_level = Security::ROLES[user_role] || 0
          current_level = Security::ROLES[current_collaborator_role] || 0
          new_level = Security::ROLES[new_role.to_sym] || 0
          
          # Must have higher role than both current and new role
          user_level > current_level && user_level > new_level
        end

        # Content permissions
        def can_edit_element?(element_id, page = nil)
          page ||= @resource
          return false unless can_edit_page?(page)
          
          # Check if element is locked by another user
          if Rails::Page::Builder.configuration.collaboration_enabled
            session = WebsocketManager.instance.page_sessions[page.id]
            if session && session.is_element_locked?(element_id, @user&.id)
              return false
            end
          end
          
          true
        end

        def can_delete_element?(element_id, page = nil)
          can_edit_element?(element_id, page)
        end

        def can_add_comment?(page = nil)
          page ||= @resource
          return false unless @user
          
          # Can comment if can view the page
          can_view_page?(page)
        end

        def can_resolve_comment?(comment, page = nil)
          page ||= @resource
          return false unless @user && comment
          
          # Comment owner or page editor can resolve
          return true if comment.user_id == @user.id
          can_edit_page?(page)
        end

        # Asset permissions
        def can_upload_asset?(file_size = 0, file_type = nil)
          return false unless @user
          return false unless can_manage_assets?
          
          security = Security.new(@user, @resource, @context)
          
          # Check file type
          if file_type && !security.send(:allowed_file_type?, file_type)
            return false
          end
          
          # Check file size limits
          user_permissions = get_user_permissions
          max_size = security.send(:get_max_file_size, user_permissions)
          
          file_size <= max_size
        end

        def can_delete_asset?(asset)
          return false unless @user && asset
          
          # Asset owner or admin can delete
          return true if asset.user_id == @user.id
          
          security = Security.new(@user, @resource, @context)
          security.has_role?(:admin)
        end

        # Template permissions
        def can_create_template?
          return false unless @user
          
          security = Security.new(@user, nil, @context)
          security.has_role?(:editor)
        end

        def can_edit_template?(template)
          return false unless @user && template
          
          # Template owner or admin can edit
          return true if template.user_id == @user.id
          
          security = Security.new(@user, nil, @context)
          security.has_role?(:admin)
        end

        def can_delete_template?(template)
          return false unless @user && template
          
          # Only template owner or admin can delete
          return true if template.user_id == @user.id
          
          security = Security.new(@user, nil, @context)
          security.has_role?(:admin)
        end

        def can_publish_template?(template)
          return false unless @user && template
          
          # Only admin can publish templates globally
          security = Security.new(@user, nil, @context)
          security.has_role?(:admin)
        end

        # Workspace permissions
        def can_create_workspace?
          return false unless @user
          
          # Check user limits
          current_workspaces = @user.workspaces.count
          max_workspaces = get_workspace_limit
          
          current_workspaces < max_workspaces
        end

        def can_manage_workspace?(workspace)
          return false unless @user && workspace
          
          # Workspace owner or admin can manage
          return true if workspace.user_id == @user.id
          
          # Check if user is workspace admin
          member = workspace.members.find_by(user_id: @user.id)
          member&.role == 'admin'
        end

        def can_invite_to_workspace?(workspace, target_role = :member)
          return false unless can_manage_workspace?(workspace)
          
          # Check invitation limits
          current_members = workspace.members.count
          max_members = get_workspace_member_limit(workspace)
          
          current_members < max_members
        end

        # Feature access permissions
        def can_use_advanced_blocks?
          return false unless @user
          
          security = Security.new(@user, nil, @context)
          security.has_role?(:editor)
        end

        def can_use_custom_css?
          return false unless @user
          
          security = Security.new(@user, @resource, @context)
          security.has_role?(:editor)
        end

        def can_use_custom_javascript?
          return false unless @user
          
          # Only admin can use custom JavaScript for security
          security = Security.new(@user, @resource, @context)
          security.has_role?(:admin)
        end

        def can_export_code?
          return false unless @user
          
          security = Security.new(@user, @resource, @context)
          security.can?(:export_page, @resource)
        end

        def can_access_api?
          return false unless @user
          
          # Check API access limits
          rate_limit = Security.new(@user, nil, @context).check_rate_limit(@user.id, 'api_access', 1000)
          rate_limit[:allowed]
        end

        # Utility methods
        def get_accessible_pages
          return [] unless @user
          
          # Pages owned by user
          owned_pages = @user.pages
          
          # Pages where user is collaborator
          collaborated_pages = Page.joins(:collaborators)
                                  .where(page_collaborators: { user_id: @user.id })
          
          # Public pages (if enabled)
          public_pages = Rails::Page::Builder.configuration.allow_public_pages ? 
                        Page.where(public: true) : Page.none
          
          (owned_pages + collaborated_pages + public_pages).uniq
        end

        def get_user_role(page = nil)
          page ||= @resource
          return :guest unless @user && page
          
          security = Security.new(@user, page, @context)
          security.user_role
        end

        def get_user_permissions
          return [] unless @user
          
          permissions = [:read]
          
          if @user.verified?
            permissions << :write
          end
          
          if @user.premium?
            permissions += [:advanced_features, :priority_support]
          end
          
          if @user.admin?
            permissions << :admin
          end
          
          permissions
        end

        private

        def get_workspace_limit
          return 1 unless @user
          
          if @user.premium?
            10
          elsif @user.verified?
            3
          else
            1
          end
        end

        def get_workspace_member_limit(workspace)
          if workspace.premium?
            100
          else
            10
          end
        end
      end

      # Controller concern for permission checking
      module PermissionsConcern
        extend ActiveSupport::Concern

        included do
          before_action :check_permissions, except: [:index, :show]
          helper_method :can?, :cannot?, :current_permissions
        end

        private

        def check_permissions
          unless current_permissions.can?(action_permission, resource_for_permission)
            render json: { error: 'Access denied' }, status: :forbidden
          end
        end

        def can?(action, resource = nil)
          current_permissions.can?(action, resource)
        end

        def cannot?(action, resource = nil)
          !can?(action, resource)
        end

        def current_permissions
          @current_permissions ||= Permissions.new(
            current_user, 
            resource_for_permission,
            permission_context
          )
        end

        def action_permission
          case action_name
          when 'create' then :create
          when 'update' then :edit
          when 'destroy' then :delete
          when 'publish' then :publish
          else action_name.to_sym
          end
        end

        def resource_for_permission
          instance_variable_get("@#{controller_name.singularize}")
        end

        def permission_context
          {
            ip_address: request.remote_ip,
            user_agent: request.user_agent,
            action: action_name,
            controller: controller_name
          }
        end
      end
    end
  end
end