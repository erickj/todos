module Todo
  module View
    module Renderer

      class << self
        def included(base)
          base.extend ClassMethods
        end
      end

      def render(partial_name, mode, locals={}, &render_block)
        view = RenderableView.new partial_name, self.class.globals, self.class.layout_name, &render_block
        view.render mode, locals
      end

      module ClassMethods

        attr_reader :layout_name

        def globals
          {}
        end

        def view_layout(layout_name)
          raise 'invalid layout name' unless layout_name.is_a? Symbol
          @layout_name = layout_name
        end
      end
    end
  end
end
