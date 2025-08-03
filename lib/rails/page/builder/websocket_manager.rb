# frozen_string_literal: true

module Rails
  module Page
    module Builder
      class WebsocketManager
        include Singleton

        attr_reader :page_sessions

        def initialize
          @page_sessions = {}
          @connection_pool = {}
        end

        # Page session management
        def get_or_create_session(page_id)
          @page_sessions[page_id] ||= Collaboration.new(page_id)
        end

        def remove_session(page_id)
          @page_sessions.delete(page_id)
        end

        # Connection management
        def add_connection(connection, page_id, user_data = {})
          session = get_or_create_session(page_id)
          user_id = user_data[:id] || connection.connection_identifier
          
          @connection_pool[connection.connection_identifier] = {
            connection: connection,
            page_id: page_id,
            user_id: user_id,
            connected_at: Time.current
          }

          session.add_user(user_id, user_data)
          
          # Send initial state to new user
          send_initial_state(connection, session)
        end

        def remove_connection(connection)
          pool_data = @connection_pool[connection.connection_identifier]
          return unless pool_data

          session = @page_sessions[pool_data[:page_id]]
          if session
            session.remove_user(pool_data[:user_id])
            
            # Remove session if no users left
            if session.connected_users.empty?
              remove_session(pool_data[:page_id])
            end
          end

          @connection_pool.delete(connection.connection_identifier)
        end

        # Message handling
        def handle_message(connection, message)
          pool_data = @connection_pool[connection.connection_identifier]
          return unless pool_data

          session = @page_sessions[pool_data[:page_id]]
          return unless session

          case message['type']
          when 'cursor_move'
            session.update_user_cursor(pool_data[:user_id], message['x'], message['y'])
          when 'element_select'
            session.update_user_selection(pool_data[:user_id], message['element_id'])
          when 'content_change'
            result = session.apply_change(pool_data[:user_id], message['change'])
            send_change_result(connection, result)
          when 'undo_change'
            result = session.undo_change(pool_data[:user_id], message['change_id'])
            send_change_result(connection, result)
          when 'lock_element'
            result = session.lock_element(pool_data[:user_id], message['element_id'])
            send_lock_result(connection, result)
          when 'unlock_element'
            result = session.unlock_element(pool_data[:user_id], message['element_id'])
            send_lock_result(connection, result)
          when 'add_comment'
            result = session.add_comment(
              pool_data[:user_id], 
              message['element_id'], 
              message['text'], 
              message['position']
            )
            send_comment_result(connection, result)
          when 'resolve_comment'
            result = session.resolve_comment(pool_data[:user_id], message['comment_id'])
            send_comment_result(connection, result)
          when 'create_snapshot'
            result = session.create_snapshot(
              pool_data[:user_id], 
              message['content'], 
              message['description']
            )
            send_snapshot_result(connection, result)
          when 'ping'
            send_pong(connection)
          end
        end

        # Statistics and monitoring
        def get_statistics
          {
            active_sessions: @page_sessions.size,
            total_connections: @connection_pool.size,
            sessions: @page_sessions.map do |page_id, session|
              {
                page_id: page_id,
                users_count: session.connected_users.size,
                changes_count: session.changes_log.size,
                locked_elements: session.get_locked_elements.size
              }
            end
          }
        end

        def cleanup_expired_sessions
          @page_sessions.each do |page_id, session|
            # Remove sessions with no users for more than 1 hour
            if session.connected_users.empty?
              last_activity = session.changes_log.last&.dig(:timestamp) || session.instance_variable_get(:@created_at)
              if last_activity && last_activity < 1.hour.ago
                remove_session(page_id)
              end
            end
          end
        end

        private

        def send_initial_state(connection, session)
          connection.transmit({
            type: 'initial_state',
            users: session.get_user_list,
            locked_elements: session.get_locked_elements,
            recent_changes: session.changes_log.last(10)
          })
        end

        def send_change_result(connection, result)
          connection.transmit({
            type: 'change_result',
            success: result[:success],
            error: result[:error],
            change: result[:change]
          })
        end

        def send_lock_result(connection, result)
          connection.transmit({
            type: 'lock_result',
            success: result[:success],
            error: result[:error]
          })
        end

        def send_comment_result(connection, result)
          connection.transmit({
            type: 'comment_result',
            success: result[:success],
            error: result[:error],
            comment: result[:comment]
          })
        end

        def send_snapshot_result(connection, result)
          connection.transmit({
            type: 'snapshot_result',
            success: result[:success],
            error: result[:error],
            snapshot: result[:snapshot]
          })
        end

        def send_pong(connection)
          connection.transmit({
            type: 'pong',
            timestamp: Time.current.to_i
          })
        end
      end

      # ActionCable Channel for real-time collaboration
      class CollaborationChannel < ActionCable::Channel::Base
        def subscribed
          user_data = {
            id: current_user&.id || params[:guest_id],
            name: current_user&.name || params[:guest_name] || "Guest #{SecureRandom.hex(3)}",
            avatar: current_user&.avatar&.url || params[:avatar],
            color: params[:color],
            permissions: get_user_permissions
          }

          WebsocketManager.instance.add_connection(connection, params[:page_id], user_data)
          stream_from "page_#{params[:page_id]}"
        end

        def unsubscribed
          WebsocketManager.instance.remove_connection(connection)
        end

        def receive(data)
          WebsocketManager.instance.handle_message(connection, data)
        end

        private

        def get_user_permissions
          return [:read] unless current_user
          
          # Check user permissions for this page
          page = Rails::Page::Builder::Page.find_by(id: params[:page_id])
          return [:read] unless page
          
          if page.user_id == current_user.id
            [:read, :write, :admin]
          elsif page.collaborators.exists?(user_id: current_user.id)
            collaborator = page.collaborators.find_by(user_id: current_user.id)
            collaborator.permissions.map(&:to_sym)
          else
            [:read]
          end
        end
      end
    end
  end
end