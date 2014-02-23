Look at Lexington, KY
===========

Lexington, Kentucky budget visualization

![](http://github.com/openlexington/look-at-lex/raw/master/screenshot.png)

## To Install

1. `bundle` to get necessary Ruby gems.
1. `npm install -g gulp` to globally install Gulp.
1. `npm install` to install Gulp plugins and other necessary packages.

## To Run

`foreman start -f Procfile.local` starts both the Rack server that serves up static HTML, CSS, and JavaScript files and Gulp, which watches for changes in your Haml, CoffeeScript, and LESS files and will recompile them.
