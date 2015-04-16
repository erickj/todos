module Todo
  module View
    module Helper
      module StringHelper
        def truncate_string(str, len, overflow='...')
          str.size > len ? str[0..len] << overflow : str
        end
      end
    end
  end
end
