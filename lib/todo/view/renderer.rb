module Todo
  module View
    module Renderer

      include Helper::Base

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

        include Helper::Base

        LOGGER = Logging.logc self

        attr_reader :layout_name

        def globals
          unless @globals
            @globals = {}
            set_globals_css
          end
          @globals
        end

        def view_layout(layout_name)
          raise 'invalid layout name' unless layout_name.is_a? Symbol
          @layout_name = layout_name
        end

        private
        def set_globals_css
          @globals[:css] = {}
          @globals[:css][:global] = css_file_contents :global

          begin
            @globals[:css][layout_name] = css_file_contents layout_name
          rescue Errno::ENOENT
            LOGGER.warn '%s.css requested but does not exist' % layout_name
          end
        end
      end
    end
  end
end
