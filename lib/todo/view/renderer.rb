module Todo
  module View
    module Renderer

      class << self
        def included(base)
          base.extend ClassMethods
        end
      end

      def render(partial_name, locals={})
        view = RenderableView.new partial_name, self.class.globals, self.class.layout_name
        view.render locals
      end

      module ClassMethods

        attr_reader :layout_name

        def view_layout(layout_name)
          raise 'invalid layout name' unless layout_name.is_a? Symbol
          @layout_name = layout_name
        end
      end
    end
  end
end
