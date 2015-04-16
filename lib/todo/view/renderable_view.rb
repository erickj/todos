module Todo
  module View

    DEFAULT_TEMPLATE_ROOT = File.dirname(__FILE__) + '/template'

    def self.template_root(tpl_root_dir=nil)
      if tpl_root_dir
        raise 'invalid template root dir: %s' % tpl_root_dir unless Dir.exists? tpl_root_dir
        @tpl_root_dir = tpl_root_dir
      end
      @tpl_root_dir || DEFAULT_TEMPLATE_ROOT
    end

    def self.template_string(tpl_name, mode, is_partial = false)
      partial_prefix = is_partial ? '_' : ''
      file_name = '%s%s.%s.erb' % [partial_prefix, tpl_name, mode]
      file_path = File.join(template_root, file_name)

      raise 'invalid template file: %s' % file_path unless File.exists? file_path
      File.read file_path
    end

    class RenderableView

      def initialize(partial_name, globals = {}, layout_name = 'layout', &tpl_string_proc)
        @globals = globals
        @partial_name = partial_name
        @layout_name = layout_name
        @tpl_string_proc = block_given? ? tpl_string_proc : lambda do |tpl_name, mode, is_partial|
          Todo::View.template_string tpl_name, mode, is_partial
        end
      end

      def render(mode, locals={})
        layout_render_context = RenderContext.new mode, @globals, @tpl_string_proc do |ctx, *_|
          ctx.render_partial @partial_name, locals
        end

        layout_render_context.render @layout_name
      end

      private

      class RenderContext

        include Todo::View::Helper::Base

        def initialize(mode, globals={}, tpl_string_proc, &yield_block)
          @mode = mode
          @locals = nil
          @globals = OpenStruct.new globals
          @tpl_string_proc = tpl_string_proc
          @yield_block = yield_block
        end

        attr_reader :locals, :globals

        def render_partial(partial_name, locals={})
          tmp = @locals
          @locals = OpenStruct.new locals
          result = render(partial_name, true)
          @locals = tmp
          result
        end

        def get_binding
          binding
        end

        def handle_yield(*args)
          args.unshift self
          @yield_block ? @yield_block.call(*args) : ''
        end

        def render(tpl_name, is_partial=false)
          tpl_str = @tpl_string_proc.call tpl_name, @mode, is_partial
          ERB.new(tpl_str).result get_binding { |*args| handle_yield(args) }
        end
      end
    end
  end
end
