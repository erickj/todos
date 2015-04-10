require 'erb'
require 'ostruct'

module Todo
  module View

    MODES = { :txt => true, :html => true }

    class MailerView

      def initialize(task_type, task_result, person, locals = {})
        @task_type = task_type
        @locals = locals
        @locals[:task_result] = task_result
        @globals = {}
        @globals[:person] = person
        @globals[:css_sytle] = <<CSS
html { -webkit-text-size-adjust:none; }
body{ margin:0; }
CSS
        @layout_name = 'layout'
      end

      def generate_html
        render_mode :html
      end

      def generate_txt
        render_mode :txt
      end

      private
      def render_mode(mode)
        task_template_str = Todo::View.template_string(@task_type, mode, true)

        layout_render_context = TemplateRenderContext.new mode, @globals, @locals do |*_|
          TemplateRenderContext.new(:html, @globals, @locals).render task_template_str
        end

        layout_render_context.render Todo::View.template_string(@layout_name, mode)
      end
    end

    private

    class TemplateRenderContext

      def initialize(mode, globals={}, locals={}, &yield_block)
        raise 'invalid mode %s' % mode unless MODES[mode]
        @mode = mode
        @locals = OpenStruct.new locals
        @globals = OpenStruct.new globals
        puts @globals
        @yield_block = yield_block
      end

      attr_reader :locals, :globals

      def render_partial(short_name)
        tpl_str = Todo::View.template_string(short_name, @mode, true)
        TemplateRenderContext.new(@mode, @globals, @locals, &@yield_block).render(tpl_str)
      end

      def get_binding
        binding
      end

      def handle_yield(*args)
        @yield_block ? @yield_block.call(*args) : ''
      end

      def render(tpl)
        tpl_str = tpl.respond_to?(:read) ? tpl.read : tpl
        ERB.new(tpl_str).result self.get_binding { |*args| self.handle_yield(args) }
      end
    end

    def self.template_string(short_name, mode, is_partial = false)
      partial_prefix = is_partial ? '_' : ''
      File.read '%s/template/%s%s.%s.erb'%[File.dirname(__FILE__), partial_prefix, short_name, mode]
    end
  end
end
