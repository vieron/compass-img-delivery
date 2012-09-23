require "rubygems"
require "base64"


module Compass::ImgDelivery

    def scss_rule(basename, mime_type, data_uri)
        rule = <<-SCSS
          %#{basename.downcase} {
            background-image: url("data:#{mime_type};base64,#{data_uri}");
            background-repeat: no-repeat;
          }

        SCSS
    end

    def fallback_scss_rule(basename, img_dir)
        rule = <<-SCSS
          %#{basename.downcase} {
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

        begin

        directory_path = Compass.configuration.images_path + images_dir.value
        png_path = directory_path + 'png/'
        svg_scss_content = ""
        png_scss_content = ""
        fallback_scss_content = ""
        oupput_types = ['svg', 'png', 'fallback']
        css_basename = File.basename(css_dir.value) || 'images'
        css_dir = File.dirname(css_dir.value) + '/'


        Dir.mkdir(png_path) unless Dir.exists?(png_path)

        Dir["#{directory_path}svg/*.svg"].each do |file|
            basename = File.basename(file, ".svg")
            outputfile = png_path + basename + '.png'

            # svg data-uri css rule
            svg_data_uri = img2b64(file)
            svg_scss_content << scss_rule(basename, "image/svg+xml", svg_data_uri )

            if !File.exists?(outputfile)
                # make png/ dir if not exists
                mkdir_if_not_exists(outputfile)
                # create png files with svg2png command
                cmd = "svg2png #{file} #{outputfile}"
                puts "Writing #{outputfile}"
                # exec shell command
                shell = %x[ #{cmd} ]
            end

            # png data-uri css rule
            png_data_uri = img2b64(outputfile)
            png_scss_content << scss_rule(basename, "image/png", png_data_uri)

            # png fallback css rule
            fallback_img_path =  "/" + Compass.configuration.images_dir + "#{images_dir.value}png"
            fallback_scss_content << fallback_scss_rule(basename, fallback_img_path)
        end


        src_css_path = Compass.configuration.css_path + css_dir + '.img-delivery/'
        css_path = Compass.configuration.css_path + css_dir

        # CREATE SOURCE PARTIALS

        src_style_basename = "_#{css_basename}"
        src_svg_scss_file = src_css_path + "#{src_style_basename}-svg.scss"
        src_png_scss_file = src_css_path + "#{src_style_basename}-png.scss"
        src_fallback_scss_file = src_css_path + "#{src_style_basename}-fallback.scss"

        # mkdir_if_not_exists(svg_scss_file)
        mkdir_if_not_exists(src_svg_scss_file)

        # copy original file, to import different files for each image-type-stylesheet
        src_file = css_path + "_#{css_basename}.scss"
        FileUtils.cp(src_file, src_svg_scss_file)
        FileUtils.cp(src_file, src_png_scss_file)
        FileUtils.cp(src_file, src_fallback_scss_file)

        # CREATE FINAL SCSS
        svg_scss_content << "@import '#{src_css_path}_#{css_basename}-svg.scss';"
        png_scss_content << "@import '#{src_css_path}_#{css_basename}-png.scss';"
        fallback_scss_content << "@import '#{src_css_path}_#{css_basename}-fallback.scss';"

        # output paths
        svg_scss_file = css_path + "#{css_basename}-svg.css.scss"
        png_scss_file = css_path + "#{css_basename}-png.css.scss"
        fallback_scss_file = css_path + "#{css_basename}-fallback.css.scss"

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

        rescue Exception => e
            puts 'Ups! There was an error:'
            puts e.inspect
        end

        Sass::Script::String.new("")
    end

    def img2b64(file)
        Base64.encode64(File.read(file)).gsub("\n", '')
    end

end
