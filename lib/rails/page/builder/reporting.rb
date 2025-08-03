# frozen_string_literal: true

module Rails
  module Page
    module Builder
      class Reporting
        include Singleton

        attr_reader :analytics

        def initialize
          @analytics = Analytics.instance
        end

        # Dashboard reports
        def generate_overview_dashboard(user_id = nil, date_range = 7.days.ago..Time.current)
          if user_id
            generate_user_dashboard(user_id, date_range)
          else
            generate_system_dashboard(date_range)
          end
        end

        def generate_system_dashboard(date_range = 7.days.ago..Time.current)
          {
            summary: {
              total_pages: count_total_pages(date_range),
              active_users: count_active_users(date_range),
              page_views: count_page_views(date_range),
              editing_sessions: count_editing_sessions(date_range)
            },
            charts: {
              daily_activity: generate_daily_activity_chart(date_range),
              popular_blocks: generate_popular_blocks_chart(date_range),
              user_engagement: generate_user_engagement_chart(date_range),
              device_breakdown: generate_device_breakdown_chart(date_range)
            },
            performance: {
              avg_load_time: calculate_avg_load_time(date_range),
              error_rate: @analytics.send(:calculate_error_rate, date_range),
              cache_hit_rate: get_cache_performance(date_range),
              uptime: calculate_uptime_percentage(date_range)
            },
            growth: calculate_growth_metrics(date_range)
          }
        end

        def generate_user_dashboard(user_id, date_range = 30.days.ago..Time.current)
          user_analytics = @analytics.get_user_analytics(user_id, date_range)
          
          {
            summary: {
              pages_created: user_analytics[:pages_created],
              pages_edited: user_analytics[:pages_edited],
              total_sessions: user_analytics[:total_sessions],
              time_spent: format_duration(user_analytics[:time_spent])
            },
            activity: {
              daily_activity: generate_user_daily_activity(user_id, date_range),
              feature_usage: user_analytics[:feature_adoption],
              collaboration_stats: user_analytics[:collaboration_events]
            },
            preferences: {
              favorite_blocks: get_user_favorite_blocks(user_id, date_range),
              preferred_templates: get_user_preferred_templates(user_id, date_range),
              working_hours: analyze_user_working_hours(user_id, date_range)
            }
          }
        end

        # Detailed reports
        def generate_page_performance_report(page_id, date_range = 30.days.ago..Time.current)
          page_analytics = @analytics.get_page_analytics(page_id, date_range)
          
          {
            basic_metrics: {
              total_views: page_analytics[:total_views],
              unique_visitors: page_analytics[:unique_visitors],
              avg_session_duration: format_duration(page_analytics[:avg_session_duration]),
              bounce_rate: "#{page_analytics[:bounce_rate]}%"
            },
            traffic_analysis: {
              daily_views: generate_daily_views_chart(page_id, date_range),
              referrer_breakdown: page_analytics[:referrer_analysis],
              device_stats: page_analytics[:device_breakdown],
              geographic_data: get_geographic_data(page_id, date_range)
            },
            engagement_metrics: {
              edit_frequency: calculate_edit_frequency(page_id, date_range),
              collaboration_score: calculate_collaboration_score(page_id, date_range),
              content_changes: analyze_content_changes(page_id, date_range),
              user_retention: calculate_user_retention(page_id, date_range)
            },
            performance_data: {
              load_times: page_analytics[:performance_metrics],
              error_rate: calculate_page_error_rate(page_id, date_range),
              optimization_suggestions: generate_optimization_suggestions(page_id)
            }
          }
        end

        def generate_user_engagement_report(date_range = 30.days.ago..Time.current)
          {
            overall_engagement: {
              active_users_daily: calculate_daily_active_users(date_range),
              user_retention_rate: calculate_retention_rate(date_range),
              avg_session_duration: calculate_avg_session_duration_all(date_range),
              feature_adoption: calculate_feature_adoption_rates(date_range)
            },
            user_segments: {
              new_users: analyze_new_users(date_range),
              returning_users: analyze_returning_users(date_range),
              power_users: identify_power_users(date_range),
              churned_users: identify_churned_users(date_range)
            },
            behavioral_patterns: {
              peak_usage_hours: identify_peak_usage_hours(date_range),
              common_workflows: identify_common_workflows(date_range),
              drop_off_points: identify_user_drop_off_points(date_range)
            }
          }
        end

        def generate_content_analysis_report(date_range = 30.days.ago..Time.current)
          {
            block_usage: {
              most_popular_blocks: get_most_popular_blocks(date_range),
              least_used_blocks: get_least_used_blocks(date_range),
              block_combinations: analyze_block_combinations(date_range),
              category_preferences: analyze_block_category_preferences(date_range)
            },
            template_analysis: {
              popular_templates: get_popular_templates(date_range),
              template_success_rate: calculate_template_success_rate(date_range),
              customization_patterns: analyze_template_customizations(date_range)
            },
            content_trends: {
              content_length_trends: analyze_content_length_trends(date_range),
              language_usage: analyze_language_usage(date_range),
              media_usage: analyze_media_usage_patterns(date_range)
            }
          }
        end

        # Export functionality
        def export_analytics_report(report_type, format = :pdf, options = {})
          date_range = options[:date_range] || 30.days.ago..Time.current
          
          report_data = case report_type.to_sym
                       when :overview
                         generate_overview_dashboard(options[:user_id], date_range)
                       when :page_performance
                         generate_page_performance_report(options[:page_id], date_range)
                       when :user_engagement
                         generate_user_engagement_report(date_range)
                       when :content_analysis
                         generate_content_analysis_report(date_range)
                       else
                         raise ArgumentError, "Unknown report type: #{report_type}"
                       end

          case format.to_sym
          when :pdf
            generate_pdf_report(report_data, report_type, options)
          when :excel
            generate_excel_report(report_data, report_type, options)
          when :csv
            generate_csv_report(report_data, report_type, options)
          when :json
            report_data.to_json
          else
            raise ArgumentError, "Unsupported format: #{format}"
          end
        end

        # Automated insights
        def generate_insights(date_range = 7.days.ago..Time.current)
          insights = []

          # Performance insights
          insights += analyze_performance_trends(date_range)
          
          # Usage insights
          insights += analyze_usage_patterns(date_range)
          
          # Growth insights
          insights += analyze_growth_trends(date_range)
          
          # Security insights
          insights += analyze_security_events(date_range)

          {
            generated_at: Time.current,
            date_range: date_range,
            insights: insights.sort_by { |insight| -insight[:priority] }
          }
        end

        def generate_recommendations(context = {})
          recommendations = []

          if context[:user_id]
            recommendations += generate_user_recommendations(context[:user_id])
          end

          if context[:page_id]
            recommendations += generate_page_recommendations(context[:page_id])
          end

          # System-wide recommendations
          recommendations += generate_system_recommendations

          {
            generated_at: Time.current,
            context: context,
            recommendations: recommendations.sort_by { |rec| -rec[:impact_score] }
          }
        end

        # Real-time reporting
        def get_live_metrics
          {
            current_active_users: @analytics.get_real_time_stats[:active_users],
            pages_being_edited: @analytics.get_real_time_stats[:pages_being_edited].count,
            recent_errors: @analytics.get_real_time_stats[:recent_errors],
            system_health: assess_system_health,
            cache_performance: get_current_cache_performance,
            last_updated: Time.current
          }
        end

        def get_alert_conditions
          alerts = []

          # Performance alerts
          if current_error_rate > 5.0
            alerts << create_alert('high_error_rate', 'critical', "Error rate is #{current_error_rate}%")
          end

          # Usage alerts
          if concurrent_users_count > user_threshold
            alerts << create_alert('high_concurrent_users', 'warning', "#{concurrent_users_count} concurrent users")
          end

          # System alerts
          if low_cache_hit_rate?
            alerts << create_alert('low_cache_performance', 'warning', 'Cache hit rate below 80%')
          end

          alerts
        end

        private

        # Chart generation helpers
        def generate_daily_activity_chart(date_range)
          daily_data = {}
          
          date_range.each do |date|
            day_start = date.beginning_of_day
            day_end = date.end_of_day
            day_range = day_start..day_end
            
            daily_data[date.strftime('%Y-%m-%d')] = {
              page_views: count_page_views(day_range),
              editing_sessions: count_editing_sessions(day_range),
              active_users: count_active_users(day_range)
            }
          end
          
          daily_data
        end

        def generate_popular_blocks_chart(date_range)
          block_events = @analytics.events.select do |event|
            event[:type] == 'block_usage' && date_range.cover?(event[:timestamp])
          end
          
          block_usage = Hash.new(0)
          block_events.each { |event| block_usage[event[:data][:block_id]] += 1 }
          
          block_usage.sort_by { |_, count| -count }.first(10).to_h
        end

        def generate_user_engagement_chart(date_range)
          engagement_data = {}
          
          date_range.each do |date|
            day_range = date.beginning_of_day..date.end_of_day
            day_events = @analytics.events.select { |e| day_range.cover?(e[:timestamp]) }
            
            engagement_data[date.strftime('%Y-%m-%d')] = {
              interactions: day_events.count,
              unique_users: day_events.map { |e| e[:user_id] }.compact.uniq.count
            }
          end
          
          engagement_data
        end

        def generate_device_breakdown_chart(date_range)
          device_data = Hash.new(0)
          
          @analytics.page_views.each do |page_id, views|
            relevant_views = views.select { |view| date_range.cover?(view[:timestamp]) }
            relevant_views.each { |view| device_data[view[:device_type]] += 1 }
          end
          
          device_data
        end

        # Calculation helpers
        def count_total_pages(date_range)
          page_creation_events = @analytics.events.select do |event|
            event[:type] == 'page_created' && date_range.cover?(event[:timestamp])
          end
          page_creation_events.count
        end

        def count_active_users(date_range)
          @analytics.events.select { |e| date_range.cover?(e[:timestamp]) }
                          .map { |e| e[:user_id] }.compact.uniq.count
        end

        def count_page_views(date_range)
          @analytics.events.count do |event|
            event[:type] == 'page_view' && date_range.cover?(event[:timestamp])
          end
        end

        def count_editing_sessions(date_range)
          @analytics.events.count do |event|
            event[:type] == 'page_edit' && date_range.cover?(event[:timestamp])
          end
        end

        def calculate_avg_load_time(date_range)
          load_events = @analytics.events.select do |event|
            event[:type] == 'page_load' && date_range.cover?(event[:timestamp])
          end
          
          return 0 if load_events.empty?
          
          total_time = load_events.sum { |event| event[:data][:load_time] }
          (total_time / load_events.count).round(2)
        end

        def format_duration(seconds)
          return '0s' unless seconds && seconds > 0
          
          hours = seconds / 3600
          minutes = (seconds % 3600) / 60
          secs = seconds % 60
          
          if hours > 0
            "#{hours}h #{minutes}m"
          elsif minutes > 0
            "#{minutes}m #{secs}s"
          else
            "#{secs}s"
          end
        end

        def get_cache_performance(date_range)
          # This would integrate with Performance class
          performance = Performance.instance
          cache_stats = performance.get_cache_statistics
          
          # Calculate hit rate
          total_ops = cache_stats.values.sum { |stats| stats[:total_operations] }
          return 0 if total_ops.zero?
          
          # Simplified calculation - would need more detailed cache metrics
          85.0 # Placeholder percentage
        end

        def calculate_uptime_percentage(date_range)
          # This would integrate with system monitoring
          99.9 # Placeholder percentage
        end

        def calculate_growth_metrics(date_range)
          current_period = date_range
          previous_period = (date_range.begin - (date_range.end - date_range.begin))..(date_range.begin)
          
          current_users = count_active_users(current_period)
          previous_users = count_active_users(previous_period)
          
          growth_rate = previous_users.zero? ? 0 : ((current_users - previous_users).to_f / previous_users * 100).round(2)
          
          {
            current_period_users: current_users,
            previous_period_users: previous_users,
            growth_rate: growth_rate,
            trend: growth_rate > 0 ? 'up' : (growth_rate < 0 ? 'down' : 'stable')
          }
        end

        # Report generation
        def generate_pdf_report(data, report_type, options = {})
          # This would integrate with a PDF generation library like Prawn
          "PDF report generated for #{report_type} (placeholder)"
        end

        def generate_excel_report(data, report_type, options = {})
          # This would integrate with an Excel generation library
          "Excel report generated for #{report_type} (placeholder)"
        end

        def generate_csv_report(data, report_type, options = {})
          require 'csv'
          
          CSV.generate do |csv|
            csv << ["#{report_type.to_s.humanize} Report"]
            csv << ["Generated at: #{Time.current}"]
            csv << []
            
            # Add data rows based on report type
            case report_type
            when :overview
              csv << ['Metric', 'Value']
              data[:summary].each { |key, value| csv << [key.to_s.humanize, value] }
            when :page_performance
              csv << ['Page ID', 'Views', 'Unique Visitors', 'Bounce Rate']
              # Add page data
            end
          end
        end

        # Insight generation
        def analyze_performance_trends(date_range)
          insights = []
          
          avg_load_time = calculate_avg_load_time(date_range)
          if avg_load_time > 3000 # 3 seconds
            insights << {
              type: 'performance',
              priority: 8,
              title: 'Slow page load times detected',
              description: "Average load time is #{avg_load_time}ms, which may impact user experience",
              action: 'Consider optimizing images and enabling caching'
            }
          end
          
          insights
        end

        def analyze_usage_patterns(date_range)
          insights = []
          
          # Analyze block usage patterns
          popular_blocks = generate_popular_blocks_chart(date_range)
          if popular_blocks.values.max > 100
            most_popular = popular_blocks.max_by { |_, count| count }
            insights << {
              type: 'usage',
              priority: 6,
              title: "Block '#{most_popular[0]}' is very popular",
              description: "Used #{most_popular[1]} times in the selected period",
              action: 'Consider promoting similar blocks or creating variations'
            }
          end
          
          insights
        end

        def analyze_growth_trends(date_range)
          insights = []
          
          growth = calculate_growth_metrics(date_range)
          if growth[:growth_rate] > 20
            insights << {
              type: 'growth',
              priority: 7,
              title: 'Strong user growth detected',
              description: "User base grew by #{growth[:growth_rate]}% in the selected period",
              action: 'Monitor server capacity and consider scaling resources'
            }
          elsif growth[:growth_rate] < -10
            insights << {
              type: 'growth',
              priority: 9,
              title: 'User decline detected',
              description: "User base decreased by #{growth[:growth_rate].abs}% in the selected period",
              action: 'Investigate potential issues and gather user feedback'
            }
          end
          
          insights
        end

        def analyze_security_events(date_range)
          insights = []
          
          error_events = @analytics.events.select do |event|
            event[:type] == 'error' && date_range.cover?(event[:timestamp])
          end
          
          if error_events.count > 50
            insights << {
              type: 'security',
              priority: 9,
              title: 'High error rate detected',
              description: "#{error_events.count} errors recorded in the selected period",
              action: 'Review error logs and investigate potential security issues'
            }
          end
          
          insights
        end

        # System health assessment
        def assess_system_health
          metrics = @analytics.get_real_time_stats
          
          health_score = 100
          issues = []
          
          if metrics[:recent_errors] > 10
            health_score -= 20
            issues << 'High error rate'
          end
          
          if metrics[:active_users] > 1000
            health_score -= 10
            issues << 'High load'
          end
          
          {
            score: health_score,
            status: health_score > 80 ? 'healthy' : (health_score > 60 ? 'warning' : 'critical'),
            issues: issues
          }
        end

        def get_current_cache_performance
          Performance.instance.get_cache_statistics
        end

        def current_error_rate
          recent_events = @analytics.events.select { |e| e[:timestamp] >= 1.hour.ago }
          return 0 if recent_events.empty?
          
          error_count = recent_events.count { |e| e[:type] == 'error' }
          (error_count.to_f / recent_events.count * 100).round(2)
        end

        def concurrent_users_count
          @analytics.get_real_time_stats[:active_users]
        end

        def user_threshold
          500 # Configurable threshold
        end

        def low_cache_hit_rate?
          get_current_cache_performance.values.any? { |stats| stats[:hit_rate] && stats[:hit_rate] < 80 }
        end

        def create_alert(type, severity, message)
          {
            id: SecureRandom.uuid,
            type: type,
            severity: severity,
            message: message,
            timestamp: Time.current,
            acknowledged: false
          }
        end
      end
    end
  end
end