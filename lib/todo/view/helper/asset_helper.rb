module Todo
  module View
    module Helper
      module AssetHelper

        def asset_root
          ASSET_ROOT
        end

        def css_path
          File.join asset_root, 'css'
        end

        def css_file_contents(basename)
          File.read File.join(css_path, basename.to_s << '.css')
        end

        def img_path
          File.join asset_root, 'img'
        end

        def img_file_path(image_name)
          find_imgs_by_basename(image_name).first
        end

        private
        def find_imgs_by_basename(image_name)
          r = Regexp.new '^%s'%image_name
          Dir.glob(img_path + '/*').find_all do |f|
            File.basename(f).match r
          end
        end
      end
    end
  end
end
