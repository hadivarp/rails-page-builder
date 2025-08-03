# frozen_string_literal: true

module Rails
  module Page
    module Builder
      class Analytics
        include Singleton

        attr_reader :events, :page_views, :user_interactions

        def initialize
          @events = []
          @page_views = {}
          @user_interactions = {}
          @session_data = {}
          @conversion_funnels = {}
        end

        # Event tracking
        def track_event(event_type, data = {})
          event = {
            id: SecureRandom.uuid,
            type: event_type.to_s,
            timestamp: Time.current,
            data: data.merge(default_event_data),
            session_id: data[:session_id] || generate_session_id,
            user_id: data[:user_id],
            page_id: data[:page_id]
          }

          @events << event
          process_real_time_event(event)
          store_event_async(event) if persistent_storage_enabled?
          
          # Cleanup old events (keep last 10,000)
          @events = @events.last(10_000) if @events.size > 10_000
          
          event
        end

        # Page analytics
        def track_page_view(page_id, user_id = nil, session_id = nil, metadata = {})
          page_view = {
            page_id: page_id,
            user_id: user_id,
            session_id: session_id || generate_session_id,
            timestamp: Time.current,
            ip_address: metadata[:ip_address],
            user_agent: metadata[:user_agent],
            referrer: metadata[:referrer],
            utm_source: metadata[:utm_source],
            utm_medium: metadata[:utm_medium],
            utm_campaign: metadata[:utm_campaign],
            device_type: detect_device_type(metadata[:user_agent]),
            viewport_size: metadata[:viewport_size],
            language: metadata[:language] || 'en'
          }

          @page_views[page_id] ||= []
          @page_views[page_id] << page_view

          # Update session data
          update_session_data(page_view[:session_id], page_view)
          
          track_event('page_view', page_view)
        end

        def track_page_edit(page_id, user_id, edit_data = {})
          track_event('page_edit', {
            page_id: page_id,
            user_id: user_id,
            edit_type: edit_data[:type],
            element_id: edit_data[:element_id],
            changes: edit_data[:changes],
            duration: edit_data[:duration]
          })
        end

        def track_block_usage(block_id, page_id, user_id, action = 'added')
          track_event('block_usage', {
            block_id: block_id,
            page_id: page_id,
            user_id: user_id,
            action: action,
            block_category: get_block_category(block_id)
          })
        end

        def track_template_usage(template_id, page_id, user_id, action = 'applied')
          track_event('template_usage', {
            template_id: template_id,
            page_id: page_id,
            user_id: user_id,
            action: action,
            template_category: get_template_category(template_id)
          })
        end

        # User interaction tracking
        def track_user_interaction(user_id, interaction_type, data = {})
          interaction = {
            user_id: user_id,
            type: interaction_type.to_s,
            timestamp: Time.current,
            data: data
          }

          @user_interactions[user_id] ||= []
          @user_interactions[user_id] << interaction

          track_event('user_interaction', interaction)
        end

        def track_collaboration_event(page_id, user_id, event_type, data = {})
          track_event('collaboration', {
            page_id: page_id,
            user_id: user_id,
            collaboration_event: event_type,
            participants: data[:participants],
            duration: data[:duration]
          })
        end

        # Performance tracking
        def track_performance_metric(metric_name, value, context = {})
          track_event('performance', {
            metric: metric_name.to_s,
            value: value,
            context: context,
            server_time: Time.current.to_f
          })
        end

        def track_load_time(page_id, load_time_ms, breakdown = {})
          track_event('page_load', {
            page_id: page_id,
            load_time: load_time_ms,
            server_time: breakdown[:server],
            client_time: breakdown[:client],
            network_time: breakdown[:network],
            render_time: breakdown[:render]
          })
        end

        # Error tracking
        def track_error(error_type, error_data = {})
          track_event('error', {
            error_type: error_type.to_s,
            message: error_data[:message],
            stack_trace: error_data[:stack_trace],
            page_id: error_data[:page_id],
            user_id: error_data[:user_id],
            severity: error_data[:severity] || 'error',
            context: error_data[:context]
          })
        end

        # Conversion tracking
        def track_conversion(funnel_name, step, user_id, data = {})
          @conversion_funnels[funnel_name] ||= {}
          @conversion_funnels[funnel_name][user_id] ||= []
          
          conversion_event = {
            step: step.to_s,
            timestamp: Time.current,
            data: data,
            funnel: funnel_name.to_s
          }
          
          @conversion_funnels[funnel_name][user_id] << conversion_event
          
          track_event('conversion', conversion_event.merge(user_id: user_id))
        end

        def track_goal_completion(goal_name, user_id, value = nil, data = {})
          track_event('goal_completion', {
            goal: goal_name.to_s,
            user_id: user_id,
            value: value,
            data: data
          })
        end

        # Reports and insights
        def get_page_analytics(page_id, date_range = 7.days.ago..Time.current)
          page_events = @events.select do |event|
            event[:page_id] == page_id && 
            date_range.cover?(event[:timestamp])
          end

          views = page_events.count { |e| e[:type] == 'page_view' }
          unique_visitors = page_events.map { |e| e[:user_id] }.compact.uniq.count
          edits = page_events.count { |e| e[:type] == 'page_edit' }
          
          {
            page_id: page_id,
            date_range: date_range,
            total_views: views,
            unique_visitors: unique_visitors,
            total_edits: edits,
            avg_session_duration: calculate_avg_session_duration(page_id, date_range),
            bounce_rate: calculate_bounce_rate(page_id, date_range),
            popular_blocks: get_popular_blocks(page_id, date_range),
            device_breakdown: get_device_breakdown(page_id, date_range),
            referrer_analysis: get_referrer_analysis(page_id, date_range),
            performance_metrics: get_performance_summary(page_id, date_range)
          }
        end

        def get_user_analytics(user_id, date_range = 30.days.ago..Time.current)
          user_events = @events.select do |event|
            event[:user_id] == user_id && 
            date_range.cover?(event[:timestamp])
          end

          {
            user_id: user_id,
            date_range: date_range,
            total_sessions: count_user_sessions(user_id, date_range),
            pages_created: count_pages_created(user_id, date_range),
            pages_edited: count_pages_edited(user_id, date_range),
            blocks_used: count_blocks_used(user_id, date_range),
            templates_used: count_templates_used(user_id, date_range),
            collaboration_events: count_collaboration_events(user_id, date_range),
            time_spent: calculate_total_time_spent(user_id, date_range),
            feature_adoption: calculate_feature_adoption(user_id, date_range)
          }
        end

        def get_system_analytics(date_range = 24.hours.ago..Time.current)
          system_events = @events.select { |e| date_range.cover?(e[:timestamp]) }

          {
            date_range: date_range,
            total_events: system_events.count,
            active_users: system_events.map { |e| e[:user_id] }.compact.uniq.count,
            active_pages: system_events.map { |e| e[:page_id] }.compact.uniq.count,
            error_rate: calculate_error_rate(date_range),
            performance_summary: get_system_performance_summary(date_range),
            feature_usage: get_feature_usage_summary(date_range),
            growth_metrics: calculate_growth_metrics(date_range)
          }
        end

        def get_conversion_funnel_analysis(funnel_name, date_range = 30.days.ago..Time.current)
          funnel_data = @conversion_funnels[funnel_name] || {}
          
          users_in_range = funnel_data.select do |user_id, events|
            events.any? { |e| date_range.cover?(e[:timestamp]) }
          end

          steps = extract_funnel_steps(users_in_range)
          
          {
            funnel_name: funnel_name,
            date_range: date_range,
            total_users: users_in_range.count,
            steps: steps,
            conversion_rates: calculate_conversion_rates(steps),
            drop_off_points: identify_drop_off_points(steps),
            avg_time_between_steps: calculate_avg_step_times(users_in_range)
          }
        end

        # Real-time analytics
        def get_real_time_stats
          recent_events = @events.select { |e| e[:timestamp] >= 5.minutes.ago }
          
          {
            active_users: recent_events.map { |e| e[:user_id] }.compact.uniq.count,
            active_sessions: recent_events.map { |e| e[:session_id] }.uniq.count,
            pages_being_edited: get_currently_edited_pages,
            recent_errors: recent_events.select { |e| e[:type] == 'error' }.count,
            system_load: get_system_load_metrics,
            cache_hit_rate: get_cache_hit_rate
          }
        end

        def get_live_user_activity(page_id)
          recent_events = @events.select do |event|
            event[:page_id] == page_id && 
            event[:timestamp] >= 1.minute.ago
          end

          {
            page_id: page_id,
            active_users: recent_events.map { |e| e[:user_id] }.compact.uniq,
            recent_actions: recent_events.last(10),
            concurrent_editors: count_concurrent_editors(page_id)
          }
        end

        # Export and reporting
        def export_analytics_data(format = :json, filters = {})
          filtered_events = filter_events(filters)
          
          case format
          when :json
            filtered_events.to_json
          when :csv
            generate_csv_export(filtered_events)
          when :excel
            generate_excel_export(filtered_events)
          else
            filtered_events
          end
        end

        def generate_dashboard_data(user_id = nil, date_range = 7.days.ago..Time.current)
          if user_id
            user_specific_dashboard(user_id, date_range)
          else
            system_dashboard(date_range)
          end
        end

        # Data retention and cleanup
        def cleanup_old_events(older_than = 90.days.ago)
          initial_count = @events.count
          @events.reject! { |event| event[:timestamp] < older_than }
          
          cleanup_count = initial_count - @events.count
          track_event('analytics_cleanup', { 
            events_removed: cleanup_count,
            retention_period: older_than 
          })
        end

        def archive_old_data(archive_date = 30.days.ago)
          if persistent_storage_enabled?
            archive_events_to_storage(@events.select { |e| e[:timestamp] < archive_date })
            @events.reject! { |e| e[:timestamp] < archive_date }
          end
        end

        private

        def default_event_data
          {
            server_timestamp: Time.current,
            app_version: Rails::Page::Builder::VERSION,
            user_agent: nil,
            ip_address: nil
          }
        end

        def generate_session_id
          SecureRandom.hex(16)
        end

        def detect_device_type(user_agent)
          return 'unknown' unless user_agent
          
          case user_agent.downcase
          when /mobile|android|iphone/
            'mobile'
          when /tablet|ipad/
            'tablet'
          else
            'desktop'
          end
        end

        def process_real_time_event(event)
          # Trigger real-time notifications for important events
          case event[:type]
          when 'error'
            notify_error_occurred(event)
          when 'page_edit'
            update_live_editing_status(event)
          when 'collaboration'
            broadcast_collaboration_update(event)
          end
        end

        def update_session_data(session_id, page_view)
          @session_data[session_id] ||= {
            start_time: page_view[:timestamp],
            pages_visited: [],
            user_id: page_view[:user_id]
          }
          
          @session_data[session_id][:pages_visited] << page_view[:page_id]
          @session_data[session_id][:last_activity] = page_view[:timestamp]
        end

        def calculate_avg_session_duration(page_id, date_range)
          page_sessions = get_sessions_for_page(page_id, date_range)
          return 0 if page_sessions.empty?
          
          total_duration = page_sessions.sum do |session|
            (session[:last_activity] - session[:start_time]).to_i
          end
          
          total_duration / page_sessions.count
        end

        def calculate_bounce_rate(page_id, date_range)
          page_sessions = get_sessions_for_page(page_id, date_range)
          return 0 if page_sessions.empty?
          
          single_page_sessions = page_sessions.count { |s| s[:pages_visited].uniq.count == 1 }
          (single_page_sessions.to_f / page_sessions.count * 100).round(2)
        end

        def get_popular_blocks(page_id, date_range)
          block_events = @events.select do |event|
            event[:type] == 'block_usage' &&
            event[:page_id] == page_id &&
            date_range.cover?(event[:timestamp])
          end
          
          block_usage = Hash.new(0)
          block_events.each { |event| block_usage[event[:data][:block_id]] += 1 }
          
          block_usage.sort_by { |_, count| -count }.first(10)
        end

        def get_device_breakdown(page_id, date_range)
          page_views = @page_views[page_id] || []
          relevant_views = page_views.select { |view| date_range.cover?(view[:timestamp]) }
          
          device_counts = Hash.new(0)
          relevant_views.each { |view| device_counts[view[:device_type]] += 1 }
          
          device_counts
        end

        def get_referrer_analysis(page_id, date_range)
          page_views = @page_views[page_id] || []
          relevant_views = page_views.select { |view| date_range.cover?(view[:timestamp]) }
          
          referrer_counts = Hash.new(0)
          relevant_views.each do |view|
            referrer = view[:referrer] || 'direct'
            referrer_counts[referrer] += 1
          end
          
          referrer_counts.sort_by { |_, count| -count }.first(10)
        end

        def persistent_storage_enabled?
          Rails::Page::Builder.configuration.analytics_storage_enabled || false
        end

        def store_event_async(event)
          # This would typically use a background job
          AnalyticsStorageJob.perform_later(event) if defined?(AnalyticsStorageJob)
        end

        # Additional helper methods would continue here...
        def get_sessions_for_page(page_id, date_range)
          @session_data.values.select do |session|
            session[:pages_visited].include?(page_id) &&
            date_range.cover?(session[:start_time])
          end
        end

        def notify_error_occurred(event)
          # Implement error notification logic
        end

        def update_live_editing_status(event)
          # Update live editing indicators
        end

        def broadcast_collaboration_update(event)
          # Broadcast collaboration events via WebSocket
        end

        def get_currently_edited_pages
          # Return pages currently being edited
          recent_edits = @events.select do |event|
            event[:type] == 'page_edit' && 
            event[:timestamp] >= 5.minutes.ago
          end
          
          recent_edits.map { |e| e[:page_id] }.uniq
        end

        def count_concurrent_editors(page_id)
          recent_edits = @events.select do |event|
            event[:type] == 'page_edit' && 
            event[:page_id] == page_id &&
            event[:timestamp] >= 5.minutes.ago
          end
          
          recent_edits.map { |e| e[:user_id] }.compact.uniq.count
        end

        def filter_events(filters)
          filtered = @events
          
          filtered = filtered.select { |e| e[:type] == filters[:event_type] } if filters[:event_type]
          filtered = filtered.select { |e| e[:user_id] == filters[:user_id] } if filters[:user_id]
          filtered = filtered.select { |e| e[:page_id] == filters[:page_id] } if filters[:page_id]
          
          if filters[:date_range]
            filtered = filtered.select { |e| filters[:date_range].cover?(e[:timestamp]) }
          end
          
          filtered
        end

        def generate_csv_export(events)
          # Generate CSV format export
          require 'csv'
          
          CSV.generate do |csv|
            csv << ['Timestamp', 'Event Type', 'User ID', 'Page ID', 'Data']
            events.each do |event|
              csv << [
                event[:timestamp].iso8601,
                event[:type],
                event[:user_id],
                event[:page_id],
                event[:data].to_json
              ]
            end
          end
        end

        def get_block_category(block_id)
          # This would look up block category from block library
          'uncategorized'
        end

        def get_template_category(template_id)
          # This would look up template category
          'uncategorized'
        end

        def calculate_error_rate(date_range)
          total_events = @events.count { |e| date_range.cover?(e[:timestamp]) }
          error_events = @events.count { |e| e[:type] == 'error' && date_range.cover?(e[:timestamp]) }
          
          return 0 if total_events.zero?
          (error_events.to_f / total_events * 100).round(2)
        end

        def get_system_performance_summary(date_range)
          performance_events = @events.select do |event|
            event[:type] == 'performance' && date_range.cover?(event[:timestamp])
          end
          
          return {} if performance_events.empty?
          
          {
            avg_load_time: performance_events.map { |e| e[:data][:value] }.sum / performance_events.count,
            total_measurements: performance_events.count
          }
        end

        def get_feature_usage_summary(date_range)
          feature_events = @events.select { |e| date_range.cover?(e[:timestamp]) }
          
          usage_by_type = Hash.new(0)
          feature_events.each { |event| usage_by_type[event[:type]] += 1 }
          
          usage_by_type
        end

        def calculate_growth_metrics(date_range)
          # Calculate growth metrics compared to previous period
          previous_range = (date_range.begin - (date_range.end - date_range.begin))..(date_range.begin)
          
          current_users = @events.select { |e| date_range.cover?(e[:timestamp]) }
                                 .map { |e| e[:user_id] }.compact.uniq.count
          previous_users = @events.select { |e| previous_range.cover?(e[:timestamp]) }
                                  .map { |e| e[:user_id] }.compact.uniq.count
          
          growth_rate = previous_users.zero? ? 0 : ((current_users - previous_users).to_f / previous_users * 100).round(2)
          
          {
            current_period_users: current_users,
            previous_period_users: previous_users,
            growth_rate: growth_rate
          }
        end

        def get_system_load_metrics
          # This would integrate with system monitoring
          {
            cpu_usage: 0,
            memory_usage: 0,
            active_connections: 0
          }
        end

        def get_cache_hit_rate
          # This would get cache statistics from Performance class
          Performance.instance.get_cache_statistics
        end
      end
    end
  end
end