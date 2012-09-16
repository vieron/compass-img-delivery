require "rubygems"
require "base64"

# Functions are modified from Benjamin Doherty's first implementations: http://gist.github.com/377912
# Modified to use the ChunkyPNG library rather than RMagick, and added flexibility to amend the path
# to which generated PNGs are saved.

module Compass::ImgDelivery

    def log(msg)
        unless msg return

        puts "img-delivery => #{msg}"
    end

end


module Sass::Script::Functions

    def hello
        Sass::Script::String.new('red')
    end

    def img_delivery(images_dir = '', css_dir = '', js_dir = '')
        directory_path = Compass.configuration.images_path + "#{images_dir.value}/"
        svg_scss_content = ""
        png_scss_content = ""
        fallback_scss_content = ""

        Dir["#{directory_path}svg/*.svg"].each do |file|
            basename = File.basename(file, ".svg")
            outputfile = directory_path + 'png/' + basename + '.png'
            svg_data_uri = svg_base64(file)
            png_data_uri = png_base64(outputfile)

            svg_scss_content << <<-SCSS
              .#{basename.downcase} {
                background-image: #{svg_data_uri};
                background-repeat: no-repeat;
              }

            SCSS

            png_scss_content << <<-SCSS
              .#{basename.downcase} {
                background-image: #{png_data_uri};
                background-repeat: no-repeat;
              }

            SCSS

            fallback_img_path =  "/" + Compass.configuration.images_dir + "#{images_dir.value}png"
            fallback_scss_content << <<-SCSS
              .#{basename.downcase} {
                background-image: url("#{fallback_img_path}/#{basename}.png");
                background-repeat: no-repeat;
              }

            SCSS

            # svg2png command
            cmd = "svg2png #{file} #{outputfile}"
            Compass::ImgDelivery.log "Writing #{outputfile}"

            # exec shell command
            shell = %x[ #{cmd} ]

            if !File.exists?(outputfile)
                d = directory_path + 'png'
                Dir.mkdir(d) unless Dir.exists?(d)
            end

        end

        # create svg.scss file
        css_path = Compass.configuration.css_path + "#{css_dir.value}"
        svg_scss_file = css_path + '-svg.css.scss'
        png_scss_file = css_path + '-png.css.scss'
        fallback_scss_file = css_path + '-fallback.css.scss'

        if !File.exists?(svg_scss_file)
            d = File.dirname(svg_scss_file)
            Dir.mkdir(d) unless Dir.exists?(d)
        end

        File.open(svg_scss_file, 'w') do |f|
            Compass::ImgDelivery.log "Writing #{svg_scss_file}"
            f.write(svg_scss_content)
        end

        # create png.scss file
        File.open(png_scss_file, 'w') do |f|
            Compass::ImgDelivery.log "Writing #{png_scss_file}"
            f.write(png_scss_content)
        end

        # create fallback.scss file
        File.open(fallback_scss_file, 'w') do |f|
            Compass::ImgDelivery.log "Writing #{fallback_scss_file}"
            f.write(fallback_scss_content)
        end

        # create js file
        js_content = File.open(File.join(File.dirname(__FILE__), "../javascripts/img-delivery.js"), "rb")
        js_content = js_content.read
        js_path = Compass.configuration.javascripts_path + "#{js_dir.value}"

        js_file = js_path + '.js'
        if !File.exists?(js_file)
            d = File.dirname(js_file)
            Dir.mkdir(d) unless Dir.exists?(d)
        end

        File.open(js_file, 'w') do |f|
            Compass::ImgDelivery.log "Writing #{js_file}"
            f.write(js_content)
        end
    end

  def svg_base64(file)
    data = Base64.encode64(File.read(file)).gsub("\n", '')
    uri  = "data:image/svg+xml;base64,#{data}"

    "url('#{uri}')"
  end

  def png_base64(file)
    data = Base64.encode64(File.read(file)).gsub("\n", '')
    uri  = "data:image/png;base64,#{data}"

    "url('#{uri}')"
  end
end
