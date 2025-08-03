# frozen_string_literal: true

module Rails
  module Page
    module Builder
      class Collaboration
        include ActiveSupport::Callbacks
        define_callbacks :user_join, :user_leave, :content_change

        attr_reader :page_id, :connected_users, :changes_log

        def initialize(page_id)
          @page_id = page_id
          @connected_users = {}
          @changes_log = []
          @cursor_positions = {}
          @locked_elements = {}
        end

        # User management
        def add_user(user_id, user_data = {})
          run_callbacks :user_join do
            @connected_users[user_id] = {
              id: user_id,
              name: user_data[:name] || "User #{user_id}",
              avatar: user_data[:avatar],
              color: user_data[:color] || generate_user_color,
              joined_at: Time.current,
              cursor: { x: 0, y: 0 },
              selection: nil,
              permissions: user_data[:permissions] || [:read, :write]
            }
          end
          
          broadcast_user_list
          @connected_users[user_id]
        end

        def remove_user(user_id)
          return unless @connected_users[user_id]
          
          run_callbacks :user_leave do
            # Release any locked elements
            unlock_elements_by_user(user_id)
            @connected_users.delete(user_id)
            @cursor_positions.delete(user_id)
          end
          
          broadcast_user_list
        end

        def update_user_cursor(user_id, x, y)
          return unless @connected_users[user_id]
          
          @connected_users[user_id][:cursor] = { x: x, y: y }
          @cursor_positions[user_id] = { x: x, y: y, updated_at: Time.current }
          
          broadcast_cursor_update(user_id, x, y)
        end

        def update_user_selection(user_id, element_id)
          return unless @connected_users[user_id]
          
          @connected_users[user_id][:selection] = element_id
          broadcast_selection_update(user_id, element_id)
        end

        # Content change management
        def apply_change(user_id, change_data)
          return { success: false, error: 'User not found' } unless @connected_users[user_id]
          return { success: false, error: 'No write permission' } unless can_write?(user_id)

          change = {
            id: SecureRandom.uuid,
            user_id: user_id,
            timestamp: Time.current,
            type: change_data[:type],
            element_id: change_data[:element_id],
            data: change_data[:data],
            previous_data: change_data[:previous_data]
          }

          run_callbacks :content_change do
            @changes_log << change
            
            # Keep only last 100 changes for memory management
            @changes_log = @changes_log.last(100) if @changes_log.size > 100
          end

          broadcast_change(change)
          { success: true, change: change }
        end

        def undo_change(user_id, change_id)
          return { success: false, error: 'User not found' } unless @connected_users[user_id]
          return { success: false, error: 'No write permission' } unless can_write?(user_id)

          change = @changes_log.find { |c| c[:id] == change_id }
          return { success: false, error: 'Change not found' } unless change

          undo_change = {
            id: SecureRandom.uuid,
            user_id: user_id,
            timestamp: Time.current,
            type: 'undo',
            element_id: change[:element_id],
            data: change[:previous_data],
            previous_data: change[:data],
            undoes: change_id
          }

          @changes_log << undo_change
          broadcast_change(undo_change)
          { success: true, change: undo_change }
        end

        # Element locking for conflict prevention
        def lock_element(user_id, element_id)
          return { success: false, error: 'User not found' } unless @connected_users[user_id]
          return { success: false, error: 'Element already locked' } if @locked_elements[element_id]

          @locked_elements[element_id] = {
            user_id: user_id,
            locked_at: Time.current,
            expires_at: Time.current + 5.minutes
          }

          broadcast_element_lock(element_id, user_id)
          { success: true }
        end

        def unlock_element(user_id, element_id)
          return { success: false, error: 'User not found' } unless @connected_users[user_id]
          
          lock = @locked_elements[element_id]
          return { success: false, error: 'Element not locked' } unless lock
          return { success: false, error: 'Not your lock' } unless lock[:user_id] == user_id

          @locked_elements.delete(element_id)
          broadcast_element_unlock(element_id, user_id)
          { success: true }
        end

        def unlock_elements_by_user(user_id)
          elements_to_unlock = @locked_elements.select { |_, lock| lock[:user_id] == user_id }.keys
          elements_to_unlock.each { |element_id| unlock_element(user_id, element_id) }
        end

        def is_element_locked?(element_id, exclude_user_id = nil)
          lock = @locked_elements[element_id]
          return false unless lock
          return false if lock[:user_id] == exclude_user_id
          return false if lock[:expires_at] < Time.current
          
          # Clean up expired lock
          if lock[:expires_at] < Time.current
            @locked_elements.delete(element_id)
            broadcast_element_unlock(element_id, lock[:user_id])
            return false
          end
          
          true
        end

        # Comment system
        def add_comment(user_id, element_id, text, position = {})
          return { success: false, error: 'User not found' } unless @connected_users[user_id]

          comment = {
            id: SecureRandom.uuid,
            user_id: user_id,
            user_name: @connected_users[user_id][:name],
            element_id: element_id,
            text: text,
            position: position,
            created_at: Time.current,
            resolved: false
          }

          broadcast_comment(comment)
          { success: true, comment: comment }
        end

        def resolve_comment(user_id, comment_id)
          return { success: false, error: 'User not found' } unless @connected_users[user_id]
          
          broadcast_comment_resolved(comment_id, user_id)
          { success: true }
        end

        # Presence awareness
        def get_user_list
          @connected_users.values.map do |user|
            user.except(:permissions)
          end
        end

        def get_active_cursors
          @cursor_positions.select { |_, pos| pos[:updated_at] > 10.seconds.ago }
        end

        def get_locked_elements
          @locked_elements.select { |_, lock| lock[:expires_at] > Time.current }
        end

        # Version control
        def create_snapshot(user_id, content, description = nil)
          return { success: false, error: 'User not found' } unless @connected_users[user_id]

          snapshot = {
            id: SecureRandom.uuid,
            user_id: user_id,
            user_name: @connected_users[user_id][:name],
            content: content,
            description: description || "Snapshot at #{Time.current.strftime('%Y-%m-%d %H:%M')}",
            created_at: Time.current,
            changes_count: @changes_log.size
          }

          broadcast_snapshot_created(snapshot)
          { success: true, snapshot: snapshot }
        end

        private

        def can_write?(user_id)
          user = @connected_users[user_id]
          return false unless user
          user[:permissions].include?(:write)
        end

        def generate_user_color
          colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FECA57', '#FF9FF3', '#54A0FF']
          colors.sample
        end

        # Broadcasting methods (to be implemented with ActionCable)
        def broadcast_user_list
          ActionCable.server.broadcast("page_#{@page_id}", {
            type: 'user_list',
            users: get_user_list
          })
        end

        def broadcast_cursor_update(user_id, x, y)
          ActionCable.server.broadcast("page_#{@page_id}", {
            type: 'cursor_update',
            user_id: user_id,
            x: x,
            y: y
          })
        end

        def broadcast_selection_update(user_id, element_id)
          ActionCable.server.broadcast("page_#{@page_id}", {
            type: 'selection_update',
            user_id: user_id,
            element_id: element_id
          })
        end

        def broadcast_change(change)
          ActionCable.server.broadcast("page_#{@page_id}", {
            type: 'content_change',
            change: change
          })
        end

        def broadcast_element_lock(element_id, user_id)
          ActionCable.server.broadcast("page_#{@page_id}", {
            type: 'element_locked',
            element_id: element_id,
            user_id: user_id,
            user_name: @connected_users[user_id][:name]
          })
        end

        def broadcast_element_unlock(element_id, user_id)
          ActionCable.server.broadcast("page_#{@page_id}", {
            type: 'element_unlocked',
            element_id: element_id,
            user_id: user_id
          })
        end

        def broadcast_comment(comment)
          ActionCable.server.broadcast("page_#{@page_id}", {
            type: 'comment_added',
            comment: comment
          })
        end

        def broadcast_comment_resolved(comment_id, user_id)
          ActionCable.server.broadcast("page_#{@page_id}", {
            type: 'comment_resolved',
            comment_id: comment_id,
            user_id: user_id
          })
        end

        def broadcast_snapshot_created(snapshot)
          ActionCable.server.broadcast("page_#{@page_id}", {
            type: 'snapshot_created',
            snapshot: snapshot
          })
        end
      end
    end
  end
end