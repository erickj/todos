require 'todo/view/helper/address_helper'
require 'todo/view/helper/asset_helper'
require 'todo/view/helper/html_helper'
require 'todo/view/helper/messages_helper'
require 'todo/view/helper/string_helper'

module Todo
  module View
    module Helper
      module Base
        include Todo::View::Helper::AddressHelper
        include Todo::View::Helper::AssetHelper
        include Todo::View::Helper::HtmlHelper
        include Todo::View::Helper::MessagesHelper
        include Todo::View::Helper::StringHelper
      end
    end
  end
end
