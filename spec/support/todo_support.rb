require 'tmpdir'
require 'fileutils'
require 'todo/view'

module TodoSupport

  module RenderHelper

    def run_with_template_files(layouts, partials, &example)
      orig_root = Todo::View.template_root
      begin

        tpl_dir = Dir.mktmpdir
        Todo::View.template_root tpl_dir

        install_layout_files tpl_dir, layouts
        install_partial_files tpl_dir, partials

        example.call

        FileUtils.remove_entry tpl_dir
      ensure
        Todo::View.template_root orig_root
      end
    end

    def inspect_rendered_template(data, file_extension)

    end

    private

    def install_layout_files(dir, layouts)
      layouts.each do |short_name, mode_map|
        mode_map.each do |mode, content|
          layout_file_name = '%s.%s.erb' % [short_name, mode]
          install_template_file(dir, layout_file_name, content)
        end
      end
    end

    def install_partial_files(dir, partials)
      partials.each do |short_name, mode_map|
        mode_map.each do |mode, content|
          partial_file_name = '_%s.%s.erb' % [short_name, mode]
          install_template_file(dir, partial_file_name, content)
        end
      end
    end

    def install_template_file(dir, name, content)
      tpl_file = File.new File.join(dir, name.to_s), 'w'
      tpl_file.write content
      tpl_file.close
    end
  end
end
