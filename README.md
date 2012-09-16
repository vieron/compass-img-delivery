# Compass Image Delivery

Compass plugin for managing and delivering sharp vector images to all devices and browsers.
I'm not reinventing the wheel, this an idea of Filament Group. Take a look at [Unicon](http://filamentgroup.com/lab/unicon/).

**What Unicon and Image Delivery do**

Basically they output 3 different CSS files:

 - All of the icons inline in the CSS as vector SVG data URLs,
 - All of the icons inline in the CSS as PNG data URLs,
 - All of the icons referenced externally as PNG images, which are automatically generated from the source SVG and placed in a directory alongside the CSS files.

## Installation

Installation is simple via Ruby Gems.

```gem install compass-img-delivery```

Cairo and svg2png are required, I recommend install them with Homebrew.

```brew install svg2png```


## Usage

To use img-delivery with your project, require the plugin from your Compass configuration:

```require "img-delivery"```


## Functions

There are some Sass::Script functions which can be used in your SASS:

### img_delivery

```$images: img_delivery("/path/to/images/", "/path/to/stylesheets/and/file-basename", "/path/to/javascripts/and/file-basename");```


## TODO

- Don't regenerate images if they didn't change
- Improve code. DRY.
- More Sass functions, return data-uris, png paths ...

## Credit

- The original idea and the js code are work of Filament Group guys. See [Unicon](https://github.com/filamentgroup/unicon).

