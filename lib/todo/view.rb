require 'logging'

module Todo
  module View
    ASSET_ROOT = File.dirname(__FILE__) + '/../../public/assets'
  end
end

require 'todo/view/messages'
require 'todo/view/helper/base'
require 'todo/view/renderable_view'
require 'todo/view/renderer'
