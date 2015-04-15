require 'tmpdir'
require 'fileutils'
require 'todo/view'

module TodoSupport

  module RenderHelper

    class << self
      def on_complete
        if @render_data_dir
          puts "\n\nRender data files:"
          Dir.glob(File.join @render_data_dir, '**', '*').each do |file_name|
            next unless File.file? file_name
            puts 'file://' << file_name
          end
        end
      end

      def install_layout_files(dir, layouts)
        layouts.each do |short_name, mode_map|
          mode_map.each do |mode, content|
            layout_file_name = '%s.%s.erb' % [short_name, mode]
            write_file(dir, layout_file_name, content)
          end
        end
      end

      def install_partial_files(dir, partials)
        partials.each do |short_name, mode_map|
          mode_map.each do |mode, content|
            partial_file_name = '_%s.%s.erb' % [short_name, mode]
            write_file(dir, partial_file_name, content)
          end
        end
      end

      def write_file(dir, name, content)
        tpl_file = File.new File.join(dir, name.to_s), 'w'
        tpl_file.write content
        tpl_file.close
      end

      def write_render_data(group, name, data)
        render_dir = File.join render_data_dir, group
        unless Dir.exists? render_dir
          Dir.mkdir render_dir
        end
        write_file render_dir, name, data
      end

      def render_data_dir
        unless @render_data_dir
          @render_data_dir = Dir.mktmpdir
        end
        @render_data_dir
      end
    end

    def run_with_template_files(layouts, partials, &example)
      orig_root = Todo::View.template_root
      begin

        tpl_dir = Dir.mktmpdir
        Todo::View.template_root tpl_dir

        TodoSupport::RenderHelper.install_layout_files tpl_dir, layouts
        TodoSupport::RenderHelper.install_partial_files tpl_dir, partials

        example.call

        FileUtils.remove_entry tpl_dir
      ensure
        Todo::View.template_root orig_root
      end
    end

    def save_rendered_data(group, name, data)
      TodoSupport::RenderHelper.write_render_data group, name, data
    end
  end
end
