module Todo
  module View
    module Helper
      module StringHelper
        def truncate_string(str, len, elide_with='...')
          str.size > len ? str[0...len] << elide_with : str
        end
      end
    end
  end
end
