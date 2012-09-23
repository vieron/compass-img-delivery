Gem::Specification.new do |s|

  # Gem Details
  s.name        = "compass-img-delivery"
  s.version     = "0.0.4"
  s.authors     = ["Javier Sánchez-Marín"]
  s.date        = "2012-09-16"
  s.summary     = %q{Compass plugin for managing and delivering sharp vector images to all devices and browsers.}
  s.description = %q{Compass plugin for managing and delivering sharp vector images to all devices and browsers. I'm not reinventing the wheel, this an idea of Filament Group. Take a look at Unicon http://filamentgroup.com/lab/unicon/ }
  s.email       = "javiersanchezmarin@gmail.com"
  s.homepage    = "http://github.com/vieron/compass-img-delivery"

  # Gem Files
  # s.files  = %w(LICENSE README.md)
  s.files += Dir.glob("lib/**/*.*")

  # Gem Bookkeeping
  s.has_rdoc          = false
  s.require_paths     = ["lib"]
  s.rubygems_version  = %q{1.3.6}

  s.add_dependency "compass",     ">= 0.10.0"
end
