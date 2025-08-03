# frozen_string_literal: true

require 'json'
require 'securerandom'

module Rails
  module Page
    module Builder
      class AdvancedEditor
        class EditorError < StandardError; end

        class << self
          attr_accessor :editor_tools, :keyboard_shortcuts, :editor_themes, :editor_plugins

          def initialize_system
            @editor_tools = {}
            @keyboard_shortcuts = {}
            @editor_themes = {}
            @editor_plugins = {}
            @undo_stack = {}
            @redo_stack = {}
            @editor_state = {}
            setup_default_tools
            setup_default_shortcuts
            setup_default_themes
          end

          # Editor Tools Management
          def register_tool(tool_name, tool_config)
            @editor_tools[tool_name.to_sym] = {
              name: tool_name,
              type: tool_config[:type] || 'action',
              icon: tool_config[:icon] || '🔧',
              shortcut: tool_config[:shortcut],
              action: tool_config[:action],
              toolbar_group: tool_config[:toolbar_group] || 'general',
              enabled: tool_config[:enabled].nil? ? true : tool_config[:enabled],
              tooltip: tool_config[:tooltip] || tool_name.to_s.humanize
            }
          end

          def get_toolbar_tools(group = nil)
            tools = @editor_tools.values
            tools = tools.select { |tool| tool[:toolbar_group] == group } if group
            tools.select { |tool| tool[:enabled] }
          end

          def execute_tool_action(tool_name, editor_id, context = {})
            tool = @editor_tools[tool_name.to_sym]
            raise EditorError, "Tool '#{tool_name}' not found" unless tool
            raise EditorError, "Tool '#{tool_name}' is disabled" unless tool[:enabled]

            save_state_for_undo(editor_id, context[:current_content])
            
            case tool[:type]
            when 'action'
              execute_action_tool(tool, editor_id, context)
            when 'modal'
              open_tool_modal(tool, editor_id, context)
            when 'inspector'
              open_inspector_panel(tool, editor_id, context)
            else
              raise EditorError, "Unknown tool type: #{tool[:type]}"
            end
          end

          # Undo/Redo System
          def undo(editor_id)
            return nil unless @undo_stack[editor_id]&.any?

            current_state = @editor_state[editor_id]
            previous_state = @undo_stack[editor_id].pop

            # Save current state to redo stack
            @redo_stack[editor_id] ||= []
            @redo_stack[editor_id].push(current_state) if current_state

            # Restore previous state
            @editor_state[editor_id] = previous_state
            previous_state
          end

          def redo(editor_id)
            return nil unless @redo_stack[editor_id]&.any?

            current_state = @editor_state[editor_id]
            next_state = @redo_stack[editor_id].pop

            # Save current state to undo stack
            @undo_stack[editor_id] ||= []
            @undo_stack[editor_id].push(current_state) if current_state

            # Restore next state
            @editor_state[editor_id] = next_state
            next_state
          end

          def clear_history(editor_id)
            @undo_stack[editor_id] = []
            @redo_stack[editor_id] = []
          end

          def can_undo?(editor_id)
            @undo_stack[editor_id]&.any? || false
          end

          def can_redo?(editor_id)
            @redo_stack[editor_id]&.any? || false
          end

          # Keyboard Shortcuts
          def register_shortcut(key_combination, action, description = nil)
            @keyboard_shortcuts[key_combination] = {
              action: action,
              description: description || key_combination,
              enabled: true
            }
          end

          def get_shortcuts_map
            @keyboard_shortcuts.select { |_, shortcut| shortcut[:enabled] }
          end

          def execute_shortcut(key_combination, editor_id, context = {})
            shortcut = @keyboard_shortcuts[key_combination]
            return false unless shortcut && shortcut[:enabled]

            case shortcut[:action]
            when String
              execute_tool_action(shortcut[:action], editor_id, context)
            when Proc
              shortcut[:action].call(editor_id, context)
            else
              false
            end
            true
          end

          # Visual Editor Features
          def get_visual_editing_tools
            {
              grid_system: generate_grid_system_tool,
              spacing_controls: generate_spacing_controls,
              typography_controls: generate_typography_controls,
              color_palette: generate_color_palette_tool,
              background_controls: generate_background_controls,
              border_controls: generate_border_controls,
              shadow_controls: generate_shadow_controls,
              animation_controls: generate_animation_controls
            }
          end

          # Code Editor Features
          def get_code_editing_tools
            {
              syntax_highlighting: generate_syntax_highlighter,
              code_folding: generate_code_folding_tool,
              auto_completion: generate_autocomplete_tool,
              code_formatting: generate_code_formatter,
              error_detection: generate_error_detector,
              code_snippets: generate_code_snippets_tool
            }
          end

          # Responsive Design Tools
          def get_responsive_tools
            {
              device_preview: generate_device_preview_tool,
              breakpoint_manager: generate_breakpoint_manager,
              responsive_inspector: generate_responsive_inspector,
              viewport_controls: generate_viewport_controls
            }
          end

          # Collaboration Tools
          def get_collaboration_tools
            {
              real_time_editing: generate_realtime_editing_tool,
              comments_system: generate_comments_system,
              version_control: generate_version_control_tool,
              sharing_controls: generate_sharing_controls
            }
          end

          # SEO and Accessibility Tools
          def get_seo_accessibility_tools
            {
              seo_analyzer: generate_seo_analyzer,
              accessibility_checker: generate_accessibility_checker,
              meta_tags_editor: generate_meta_tags_editor,
              structured_data_editor: generate_structured_data_editor
            }
          end

          # Performance Tools
          def get_performance_tools
            {
              performance_analyzer: generate_performance_analyzer,
              image_optimizer: generate_image_optimizer,
              code_minifier: generate_code_minifier,
              loading_speed_tester: generate_loading_speed_tester
            }
          end

          # Theme and Customization
          def register_theme(theme_name, theme_config)
            @editor_themes[theme_name.to_sym] = {
              name: theme_name,
              colors: theme_config[:colors] || {},
              fonts: theme_config[:fonts] || {},
              spacing: theme_config[:spacing] || {},
              borders: theme_config[:borders] || {},
              shadows: theme_config[:shadows] || {},
              css_variables: theme_config[:css_variables] || {}
            }
          end

          def get_theme(theme_name)
            @editor_themes[theme_name.to_sym]
          end

          def generate_theme_css(theme_name)
            theme = get_theme(theme_name)
            return '' unless theme

            css_vars = theme[:css_variables].map { |var, value| "  --#{var}: #{value};" }.join("\n")
            
            <<~CSS
              .editor-theme-#{theme_name} {
              #{css_vars}
              }
              
              .editor-theme-#{theme_name} .editor-toolbar {
                background: var(--toolbar-bg, #{theme[:colors][:toolbar_bg] || '#f8f9fa'});
                border-bottom: var(--toolbar-border, #{theme[:colors][:toolbar_border] || '#dee2e6'});
              }
              
              .editor-theme-#{theme_name} .editor-content {
                background: var(--content-bg, #{theme[:colors][:content_bg] || '#ffffff'});
                color: var(--content-text, #{theme[:colors][:content_text] || '#333333'});
                font-family: var(--content-font, #{theme[:fonts][:content] || 'Arial, sans-serif'});
              }
            CSS
          end

          # Editor State Management
          def save_editor_state(editor_id, state)
            @editor_state[editor_id] = state.dup
          end

          def get_editor_state(editor_id)
            @editor_state[editor_id]
          end

          def export_editor_config(editor_id)
            {
              tools: @editor_tools,
              shortcuts: @keyboard_shortcuts,
              themes: @editor_themes,
              state: @editor_state[editor_id],
              undo_available: can_undo?(editor_id),
              redo_available: can_redo?(editor_id)
            }
          end

          private

          def save_state_for_undo(editor_id, content)
            @undo_stack[editor_id] ||= []
            @undo_stack[editor_id].push(content.dup) if content
            
            # Limit undo stack size
            max_undo_steps = 50
            @undo_stack[editor_id] = @undo_stack[editor_id].last(max_undo_steps)
            
            # Clear redo stack when new action is performed
            @redo_stack[editor_id] = []
          end

          def execute_action_tool(tool, editor_id, context)
            case tool[:name]
            when 'bold'
              apply_text_formatting(editor_id, 'font-weight', 'bold')
            when 'italic'
              apply_text_formatting(editor_id, 'font-style', 'italic')
            when 'underline'
              apply_text_formatting(editor_id, 'text-decoration', 'underline')
            when 'align-left'
              apply_text_formatting(editor_id, 'text-align', 'left')
            when 'align-center'
              apply_text_formatting(editor_id, 'text-align', 'center')
            when 'align-right'
              apply_text_formatting(editor_id, 'text-align', 'right')
            when 'duplicate'
              duplicate_selected_element(editor_id)
            when 'delete'
              delete_selected_element(editor_id)
            else
              tool[:action]&.call(editor_id, context)
            end
          end

          def apply_text_formatting(editor_id, property, value)
            {
              action: 'apply_style',
              property: property,
              value: value,
              target: 'selected_element'
            }
          end

          def duplicate_selected_element(editor_id)
            {
              action: 'duplicate_element',
              target: 'selected_element'
            }
          end

          def delete_selected_element(editor_id)
            {
              action: 'delete_element',
              target: 'selected_element'
            }
          end

          def open_tool_modal(tool, editor_id, context)
            {
              action: 'open_modal',
              modal_type: tool[:name],
              context: context
            }
          end

          def open_inspector_panel(tool, editor_id, context)
            {
              action: 'open_inspector',
              inspector_type: tool[:name],
              context: context
            }
          end

          # Default Tools Setup
          def setup_default_tools
            # Text formatting tools
            register_tool('bold', {
              type: 'action',
              icon: '𝐁',
              shortcut: 'Ctrl+B',
              toolbar_group: 'text_formatting',
              tooltip: 'Bold'
            })

            register_tool('italic', {
              type: 'action',
              icon: '𝐼',
              shortcut: 'Ctrl+I',
              toolbar_group: 'text_formatting',
              tooltip: 'Italic'
            })

            register_tool('underline', {
              type: 'action',
              icon: 'U̲',
              shortcut: 'Ctrl+U',
              toolbar_group: 'text_formatting',
              tooltip: 'Underline'
            })

            # Alignment tools
            register_tool('align-left', {
              type: 'action',
              icon: '⬅️',
              toolbar_group: 'alignment',
              tooltip: 'Align Left'
            })

            register_tool('align-center', {
              type: 'action',
              icon: '↔️',
              toolbar_group: 'alignment',
              tooltip: 'Align Center'
            })

            register_tool('align-right', {
              type: 'action',
              icon: '➡️',
              toolbar_group: 'alignment',
              tooltip: 'Align Right'
            })

            # Element tools
            register_tool('duplicate', {
              type: 'action',
              icon: '📋',
              shortcut: 'Ctrl+D',
              toolbar_group: 'elements',
              tooltip: 'Duplicate Element'
            })

            register_tool('delete', {
              type: 'action',
              icon: '🗑️',
              shortcut: 'Delete',
              toolbar_group: 'elements',
              tooltip: 'Delete Element'
            })

            # Modal tools
            register_tool('settings', {
              type: 'modal',
              icon: '⚙️',
              toolbar_group: 'tools',
              tooltip: 'Element Settings'
            })

            register_tool('styles', {
              type: 'inspector',
              icon: '🎨',
              toolbar_group: 'tools',
              tooltip: 'Style Inspector'
            })
          end

          def setup_default_shortcuts
            # Basic editing
            register_shortcut('Ctrl+Z', 'undo', 'Undo')
            register_shortcut('Ctrl+Y', 'redo', 'Redo')
            register_shortcut('Ctrl+S', 'save', 'Save')
            register_shortcut('Ctrl+C', 'copy', 'Copy')
            register_shortcut('Ctrl+V', 'paste', 'Paste')
            register_shortcut('Ctrl+X', 'cut', 'Cut')

            # Text formatting
            register_shortcut('Ctrl+B', 'bold', 'Bold')
            register_shortcut('Ctrl+I', 'italic', 'Italic')
            register_shortcut('Ctrl+U', 'underline', 'Underline')

            # Element manipulation
            register_shortcut('Ctrl+D', 'duplicate', 'Duplicate')
            register_shortcut('Delete', 'delete', 'Delete')
            register_shortcut('Escape', 'deselect', 'Deselect')

            # View controls
            register_shortcut('Ctrl+Plus', 'zoom_in', 'Zoom In')
            register_shortcut('Ctrl+Minus', 'zoom_out', 'Zoom Out')
            register_shortcut('Ctrl+0', 'zoom_reset', 'Reset Zoom')
          end

          def setup_default_themes
            register_theme('light', {
              colors: {
                toolbar_bg: '#ffffff',
                toolbar_border: '#e1e5e9',
                content_bg: '#ffffff',
                content_text: '#333333',
                primary: '#007bff',
                secondary: '#6c757d'
              },
              fonts: {
                content: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
                code: 'Monaco, Consolas, "Liberation Mono", "Courier New", monospace'
              },
              css_variables: {
                'border-radius': '0.375rem',
                'box-shadow': '0 0.125rem 0.25rem rgba(0, 0, 0, 0.075)',
                'transition': 'all 0.15s ease-in-out'
              }
            })

            register_theme('dark', {
              colors: {
                toolbar_bg: '#2d3748',
                toolbar_border: '#4a5568',
                content_bg: '#1a202c',
                content_text: '#e2e8f0',
                primary: '#4299e1',
                secondary: '#a0aec0'
              },
              fonts: {
                content: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
                code: 'Monaco, Consolas, "Liberation Mono", "Courier New", monospace'
              },
              css_variables: {
                'border-radius': '0.375rem',
                'box-shadow': '0 0.125rem 0.25rem rgba(0, 0, 0, 0.3)',
                'transition': 'all 0.15s ease-in-out'
              }
            })
          end

          # Tool Generators
          def generate_grid_system_tool
            {
              type: 'inspector',
              controls: {
                columns: { type: 'number', min: 1, max: 12, default: 12 },
                gap: { type: 'slider', min: 0, max: 100, default: 20, unit: 'px' },
                alignment: { type: 'select', options: ['start', 'center', 'end', 'stretch'] }
              }
            }
          end

          def generate_spacing_controls
            {
              type: 'inspector',
              controls: {
                margin: { type: 'spacing', sides: ['top', 'right', 'bottom', 'left'] },
                padding: { type: 'spacing', sides: ['top', 'right', 'bottom', 'left'] }
              }
            }
          end

          def generate_typography_controls
            {
              type: 'inspector',
              controls: {
                font_family: { type: 'font_picker', web_fonts: true },
                font_size: { type: 'slider', min: 8, max: 72, unit: 'px' },
                font_weight: { type: 'select', options: [100, 200, 300, 400, 500, 600, 700, 800, 900] },
                line_height: { type: 'slider', min: 0.8, max: 3, step: 0.1 },
                letter_spacing: { type: 'slider', min: -2, max: 10, unit: 'px' }
              }
            }
          end

          def generate_color_palette_tool
            {
              type: 'inspector',
              controls: {
                text_color: { type: 'color_picker', alpha: true },
                background_color: { type: 'color_picker', alpha: true },
                border_color: { type: 'color_picker', alpha: true }
              },
              presets: [
                '#ffffff', '#000000', '#007bff', '#28a745', '#dc3545',
                '#ffc107', '#17a2b8', '#6f42c1', '#e83e8c', '#fd7e14'
              ]
            }
          end

          def generate_background_controls
            {
              type: 'inspector',
              controls: {
                background_type: { type: 'tabs', options: ['color', 'gradient', 'image'] },
                background_color: { type: 'color_picker', alpha: true },
                gradient_type: { type: 'select', options: ['linear', 'radial'] },
                gradient_direction: { type: 'angle_picker' },
                background_image: { type: 'image_picker' },
                background_size: { type: 'select', options: ['cover', 'contain', 'auto'] },
                background_position: { type: 'position_picker' }
              }
            }
          end

          def generate_border_controls
            {
              type: 'inspector',
              controls: {
                border_width: { type: 'spacing', sides: ['top', 'right', 'bottom', 'left'] },
                border_style: { type: 'select', options: ['solid', 'dashed', 'dotted', 'double'] },
                border_color: { type: 'color_picker', alpha: true },
                border_radius: { type: 'spacing', corners: ['top-left', 'top-right', 'bottom-right', 'bottom-left'] }
              }
            }
          end

          def generate_shadow_controls
            {
              type: 'inspector',
              controls: {
                box_shadow: { type: 'shadow_picker', multiple: true },
                text_shadow: { type: 'shadow_picker', text: true }
              }
            }
          end

          def generate_animation_controls
            {
              type: 'inspector',
              controls: {
                animation_type: { type: 'select', options: ['none', 'fade', 'slide', 'bounce', 'custom'] },
                duration: { type: 'slider', min: 0.1, max: 5, step: 0.1, unit: 's' },
                delay: { type: 'slider', min: 0, max: 2, step: 0.1, unit: 's' },
                easing: { type: 'select', options: ['ease', 'ease-in', 'ease-out', 'ease-in-out', 'linear'] }
              }
            }
          end

          def generate_syntax_highlighter
            {
              languages: ['html', 'css', 'javascript', 'json', 'markdown'],
              themes: ['github', 'monokai', 'solarized-light', 'solarized-dark'],
              features: ['line_numbers', 'code_folding', 'search_replace']
            }
          end

          def generate_code_folding_tool
            {
              enabled: true,
              auto_fold: ['import_statements', 'comments'],
              fold_levels: [1, 2, 3, 'all']
            }
          end

          def generate_autocomplete_tool
            {
              html_tags: true,
              css_properties: true,
              javascript_keywords: true,
              custom_snippets: true,
              trigger_characters: ['.', '#', '@']
            }
          end

          def generate_code_formatter
            {
              html: { indent_size: 2, wrap_line_length: 120 },
              css: { indent_size: 2, sort_properties: true },
              javascript: { indent_size: 2, semicolons: true, quotes: 'single' }
            }
          end

          def generate_error_detector
            {
              html_validation: true,
              css_validation: true,
              javascript_linting: true,
              accessibility_checks: true
            }
          end

          def generate_code_snippets_tool
            {
              html_snippets: ['div', 'section', 'article', 'header', 'footer'],
              css_snippets: ['flexbox', 'grid', 'animation', 'media-query'],
              javascript_snippets: ['function', 'class', 'async-await', 'event-listener']
            }
          end

          def generate_device_preview_tool
            {
              devices: [
                { name: 'Desktop', width: 1920, height: 1080 },
                { name: 'Laptop', width: 1366, height: 768 },
                { name: 'Tablet', width: 768, height: 1024 },
                { name: 'Mobile', width: 375, height: 667 }
              ],
              custom_viewport: true,
              orientation_toggle: true
            }
          end

          def generate_breakpoint_manager
            {
              default_breakpoints: {
                xs: 0,
                sm: 576,
                md: 768,
                lg: 992,
                xl: 1200,
                xxl: 1400
              },
              custom_breakpoints: true,
              visual_indicators: true
            }
          end

          def generate_responsive_inspector
            {
              show_breakpoints: true,
              highlight_responsive_elements: true,
              responsive_preview: true,
              responsive_testing: true
            }
          end

          def generate_viewport_controls
            {
              zoom_levels: [25, 50, 75, 100, 125, 150, 200],
              fit_to_screen: true,
              ruler_guides: true,
              grid_overlay: true
            }
          end

          def generate_realtime_editing_tool
            {
              enabled: false, # Requires backend implementation
              websocket_support: true,
              conflict_resolution: 'last_writer_wins',
              cursor_tracking: true
            }
          end

          def generate_comments_system
            {
              inline_comments: true,
              comment_threads: true,
              comment_notifications: true,
              comment_resolution: true
            }
          end

          def generate_version_control_tool
            {
              auto_save: true,
              manual_checkpoints: true,
              version_comparison: true,
              branch_support: false
            }
          end

          def generate_sharing_controls
            {
              public_sharing: true,
              password_protection: true,
              expiration_dates: true,
              download_options: ['html', 'pdf', 'image']
            }
          end

          def generate_seo_analyzer
            {
              title_optimization: true,
              meta_description: true,
              heading_structure: true,
              image_alt_text: true,
              internal_linking: true
            }
          end

          def generate_accessibility_checker
            {
              color_contrast: true,
              keyboard_navigation: true,
              screen_reader_support: true,
              aria_labels: true,
              semantic_html: true
            }
          end

          def generate_meta_tags_editor
            {
              basic_meta: ['title', 'description', 'keywords'],
              social_meta: ['og:title', 'og:description', 'og:image', 'twitter:card'],
              technical_meta: ['viewport', 'charset', 'robots']
            }
          end

          def generate_structured_data_editor
            {
              schema_types: ['Organization', 'Product', 'Article', 'Event'],
              json_ld_support: true,
              validation: true,
              preview: true
            }
          end

          def generate_performance_analyzer
            {
              load_time_analysis: true,
              bundle_size_analysis: true,
              image_optimization_suggestions: true,
              code_splitting_recommendations: true
            }
          end

          def generate_image_optimizer
            {
              format_conversion: ['webp', 'avif', 'jpeg', 'png'],
              compression_levels: [10, 25, 50, 75, 90],
              responsive_images: true,
              lazy_loading: true
            }
          end

          def generate_code_minifier
            {
              html_minification: true,
              css_minification: true,
              javascript_minification: true,
              remove_comments: true,
              remove_whitespace: true
            }
          end

          def generate_loading_speed_tester
            {
              simulated_connections: ['3G', '4G', 'WiFi'],
              performance_metrics: ['FCP', 'LCP', 'CLS', 'TTI'],
              suggestions: true,
              before_after_comparison: true
            }
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

# Initialize the advanced editor system
Rails::Page::Builder::AdvancedEditor.initialize_system