require 'erb'

module Todo
  module View
    module Helper
      module HtmlHelper

        def html_escape(str)
          ERB::Util.html_escape str
        end
        alias :h :html_escape

        def a_tag(href, attr_hash={}, &content_block)
          html_tag :a, { :href => href }.merge(attr_hash), &content_block
        end

        def html_tag(tag, attr_hash={}, &content_block)
          attr_string = attr_hash.map { |k, v| '%s="%s"' % [k.to_s, v]}.join ' '
          html_str = '<%s %s>' % [tag.to_s, attr_string]
          html_str << content_block.call
          html_str << '</%s>' % tag
          html_str
        end
      end
    end
  end
end
