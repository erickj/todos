require 'logging'

module Todo
  module View
    ASSET_ROOT = File.dirname(__FILE__) + '/../../public/assets'
  end
end

require 'todo/view/helper/asset_helper'
require 'todo/view/renderable_view'
require 'todo/view/renderer'
