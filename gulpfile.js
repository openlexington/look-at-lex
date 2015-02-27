// Require Gulp plugins and other libraries
var path = require('path');
var gulp = require('gulp');
var gutil = require('gulp-util');
var watch = require('gulp-watch');
var coffee = require('gulp-coffee');
var less = require('gulp-less');
var concat = require('gulp-concat');
var uglify = require('gulp-uglify');
var rename = require('gulp-rename');
var haml = require('gulp-ruby-haml');
var minifyCSS = require('gulp-minify-css');
var clean = require('gulp-clean');
var sourcemaps = require('gulp-sourcemaps');



/////////////////////////
// Shared variables /////
/////////////////////////

var coffee_path = './coffee';
var less_path = './less';
var vendor_css_path = './lib/css';
var vendor_js_path = './lib/js';
var tmp_js_path = './tmp/js';
var tmp_css_path = './tmp/css';
var haml_path = './haml';
var on_error = function (err) { console.error(err.message); };


/////////////////////////
// Tasks ////////////////
/////////////////////////

// Compile LESS into CSS
gulp.task('less', function() {
  return gulp.src(less_path + '/index.less').
              pipe(less().on('error', on_error)).
              pipe(gulp.dest(tmp_css_path));
});

// Combine CSS files and minify them
gulp.task('minify-css', ['less'], function() {
  return gulp.src([vendor_css_path + '/*.css', tmp_css_path + '/*.css']).
              pipe(concat('all.min.css').on('error', on_error)).
              pipe(minifyCSS().on('error', on_error)).
              pipe(gulp.dest('./public/css'));
});

// Remove intermediate CSS files
gulp.task('clean-css', ['minify-css'], function () {
  return gulp.src(tmp_css_path + '/index.css', {read: false}).
              pipe(clean().on('error', on_error));
});

// Compile CoffeeScript into JavaScript
gulp.task('coffee', function() {
  return gulp.src(coffee_path + '/**/*.coffee').
              pipe(coffee({bare: true}).on('error', on_error)).
              pipe(gulp.dest(tmp_js_path));
});

// Combine JS files
gulp.task('minify-js', ['coffee'], function() {
  return gulp.src([vendor_js_path + '/jquery-1.10.2.min.js',
                   vendor_js_path + '/angular.min.js',
                   vendor_js_path + '/angular-*.min.js',
                   vendor_js_path + '/d3.min.js',
                   vendor_js_path + '/loading-bar.min.js',
                   vendor_js_path + '/bootstrap.min.js',
                   vendor_js_path + '/ui-bootstrap-*.min.js',
                   vendor_js_path + '/numeral.min.js',
                   tmp_js_path + '/app.js',
                   tmp_js_path + '/routes.js',
                   tmp_js_path + '/models/*.js',
                   tmp_js_path + '/services/*.js',
                   tmp_js_path + '/controllers/*.js',
                   tmp_js_path + '/filters.js',
                   tmp_js_path + '/directives.js']).
              pipe(sourcemaps.write()).
              pipe(concat('all.js').on('error', on_error)).
              pipe(gulp.dest('./public/js'));
});

// Remove intermediate JavaScript files
gulp.task('clean-js', ['minify-js'], function () {
  return gulp.src([tmp_js_path + '/**/*.js'], {read: false}).
              pipe(clean().on('error', on_error));
});

// Compile Haml into HTML
gulp.task('haml', function() {
  return gulp.src(haml_path + '/**/*.haml', {read: false}).
              pipe(haml().on('error', on_error)).
              pipe(gulp.dest('./public'));
});

// Watch for changes in Haml files
gulp.task('haml-watch', function() {
  return gulp.src(haml_path + '/**/*.haml', {read: false}).
              pipe(watch()).
              pipe(haml().on('error', on_error)).
              pipe(gulp.dest('./public'));
});

// Watch files for changes
gulp.task('watch', function() {
  gulp.watch([less_path + '/*.less', vendor_css_path + '/*.css'],
             ['clean-css']);
  gulp.watch([coffee_path + '/**/*.coffee', vendor_js_path + '/*.js'],
             ['clean-js']);
});

// Default task
gulp.task('default', ['watch', 'haml-watch']);

// Compile all files once
gulp.task('run-all', ['haml', 'clean-js', 'clean-css']);
