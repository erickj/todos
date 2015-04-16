module Todo
  module View
    module Helper
      module AddressHelper

        def reply_to_slug(slug)
          'todo+%s@dotildone.com' % slug
        end

      end
    end
  end
end
