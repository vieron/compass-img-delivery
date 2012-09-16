require "rubygems"
require "base64"


module Compass::ImgDelivery

    def scss_rule(basename, mime_type, data_uri)
        rule = <<-SCSS
          .#{basename.downcase} {
            background-image: url("data:#{mime_type};base64,#{data_uri}");
            background-repeat: no-repeat;
          }

        SCSS
    end

    def fallback_scss_rule(basename, img_dir)
        rule = <<-SCSS
          .#{basename.downcase} {
            background-image: url("#{img_dir}/#{basename}.png");
            background-repeat: no-repeat;
          }

        SCSS
    end

    def mkdir_if_not_exists(file)
        if !File.exists?(file)
            d = File.dirname(file)
            Dir.mkdir(d) unless Dir.exists?(d)
        end
    end

    def write_file(file, content)
        File.open(file, 'w') do |f|
            puts "Writing #{file}"
            f.write(content)
        end
    end

end


module Sass::Script::Functions

    include Compass::ImgDelivery

    def img_delivery(images_dir = '', css_dir = '', js_dir = '')
        directory_path = Compass.configuration.images_path + "#{images_dir.value}"
        svg_scss_content = ""
        png_scss_content = ""
        fallback_scss_content = ""

        Dir["#{directory_path}svg/*.svg"].each do |file|
            basename = File.basename(file, ".svg")
            outputfile = directory_path + 'png/' + basename + '.png'

            # svg data-uri css rule
            svg_data_uri = img2b64(file)
            svg_scss_content << scss_rule(basename, "image/svg+xml", svg_data_uri )

            # make png/ dir if not exists
            mkdir_if_not_exists(outputfile)

            # create png files with svg2png command
            cmd = "svg2png #{file} #{outputfile}"
            puts "Writing #{outputfile}"
            # exec shell command
            shell = %x[ #{cmd} ]

            # png data-uri css rule
            png_data_uri = img2b64(outputfile)
            png_scss_content << scss_rule(basename, "image/png", png_data_uri)

            # png fallback css rule
            fallback_img_path =  "/" + Compass.configuration.images_dir + "#{images_dir.value}png"
            fallback_scss_content << fallback_scss_rule(basename, fallback_img_path)
        end

        # create svg.scss file
        css_path = Compass.configuration.css_path + "#{css_dir.value}"
        svg_scss_file = css_path + '-svg.css.scss'
        png_scss_file = css_path + '-png.css.scss'
        fallback_scss_file = css_path + '-fallback.css.scss'

        mkdir_if_not_exists(svg_scss_file)

        # create svg.scss file
        write_file(svg_scss_file, svg_scss_content)

        # create png.scss file
        write_file(png_scss_file, png_scss_content)

        # create fallback.scss file
        write_file(fallback_scss_file, fallback_scss_content)

        # create js file
        js_content = File.open(File.join(File.dirname(__FILE__), "../javascripts/img-delivery.js"), "rb")
        js_content = js_content.read
        js_path = Compass.configuration.javascripts_path + "#{js_dir.value}"
        js_file = js_path + '.js'

        mkdir_if_not_exists(js_file)
        write_file(js_file, js_content)
    end

    def img2b64(file)
        Base64.encode64(File.read(file)).gsub("\n", '')
    end

end
