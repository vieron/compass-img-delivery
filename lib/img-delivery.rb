require 'compass'
require 'img-delivery/functions'

Compass::Frameworks.register("img-delivery",
  :stylesheets_directory  => File.join(File.dirname(__FILE__), "stylesheets"),
  :templates_directory    => File.join(File.dirname(__FILE__), "templates")
)
