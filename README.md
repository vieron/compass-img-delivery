# Compass Image Delivery

Compass plugin for managing and delivering sharp vector images to all devices and browsers.
I'm not reinventing the wheel, this is an idea of Filament Group. Take a look at [Unicon](http://filamentgroup.com/lab/unicon/).

**The usage differs a bit from Unicon**

You should create a scss partial named ```_images.scss``` in the specified stylesheet directory. And here you can write all the css rules you want @extending the placeholder selectors who have the background declarations. For example:

```
/* _images.scss */

.foo, .var:after {
	@extend %arrow;
}

.logo {
	@extend %logo;
}
```
This assumes there are two images in the specified image directory, *arrow.svg* and *logo.svg*. 

**The output after processing would be 3 different files like:**


```
/* images-svg.css */

.foo, .var:after {
	background-image: url("data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmN42NjkiLz4KPC9zdmc+Cg==");
	background-repeat: no-repeat;
}
          
.logo {
	background-image: url("data:image/svg+xml;base64,PDjVuBliasbhUnlsnIhNjVsDNFnBH4wIiBlbm+Cg==");
	background-repeat: no-repeat;
}

```

```
/* images-png.css */

.foo, .var:after {
	background-image: url("data:image/png;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmN42NjkiLz4KPC9zdmc+Cg==");
	background-repeat: no-repeat;
}
          
.logo {
	background-image: url("data:image/png;base64,PDjVuBliasbhUnlsnIhNjVsDNFnBH4wIiBlbm+Cg==");
	background-repeat: no-repeat;
}

```

```
/* images-fallback.css */

.foo, .var:after {
	background-image: url("/css_path/arrow.png");
	background-repeat: no-repeat;
}
          
.logo {
	background-image: url("/css_path/logo.png");
	background-repeat: no-repeat;
}

```



## Installation

Installation is simple via Ruby Gems.

```gem install compass-img-delivery```

Cairo and svg2png are required, I recommend install them with Homebrew.

```brew install svg2png```


## Usage

To use img-delivery with your project, require the plugin from your Compass configuration:

```require "img-delivery"```


- Call ```img_delivery``` sass function anywhere in your scss files to start using the extension.

	```$images: img_delivery("/path/to/images/", "/path/to/stylesheets/file-basename", "/path/to/javascripts/file-basename");```

- Create the ```_file-basename.scss``` (see stylesheets path above) partial in ```/path/to/stylesheets/``` and start coding your SCSS rules.

	When running compass some files should automatically be created in ```/path/to/stylesheets/```:
	
	```
	/* This files contains all the placeholder selectors 
	 * mapping images in /path/to/images/svg/ and each one
	 *  @import a different copy of _images.scss file. */	 	 
	/path/to/stylesheets/file-basename-svg.css.scss
	/path/to/stylesheets/file-basename-png.css.scss
	/path/to/stylesheets/file-basename-fallback.css.scss	
	
	/* copies of original _images.scss partial */	
	/path/to/stylesheets/.img-delivery/_file-basename-svg.scss  
	/path/to/stylesheets/.img-delivery/_file-basename-png.scss
	/path/to/stylesheets/.img-delivery/_file-basename-fallback.scss
	```
	
	What file @imports what:

	```
	/path/to/stylesheets/file-basename-svg.css.scss
		@import /path/to/stylesheets/.img-delivery/_file-basename-svg.scss
	
	/path/to/stylesheets/file-basename-png.css.scss
		@import /path/to/stylesheets/.img-delivery/_file-basename-png.scss
	
	/path/to/stylesheets/file-basename-fallback.css.scss
		@import /path/to/stylesheets/.img-delivery/_file-basename-fallback.scss
	```

## TODO

- Improve code. DRY.
- More Sass functions, return data-uris, png paths ...

## Credit

- The original idea and the js code are work of Filament Group guys. See [Unicon](https://github.com/filamentgroup/unicon).

