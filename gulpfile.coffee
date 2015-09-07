gulp        = require 'gulp'
browserify  = require 'browserify'
prefix      = require 'gulp-autoprefixer'
spawn       = (require 'child_process').spawn
rename      = require 'gulp-rename'
imagemin    = require 'gulp-imagemin'
util        = require 'gulp-util'
coffee      = require 'gulp-coffee'
less        = require 'gulp-less'
watch       = require 'gulp-watch'
plumber     = require 'gulp-plumber'
uglify      = require 'gulp-uglify'
minify      = require 'gulp-minify-css'
concat      = require 'gulp-concat'
runsequence = require 'run-sequence'
del         = require 'del'

bngann      = require 'browserify-ngannotate'

debowerify  = require 'debowerify'
coffeeify   = require 'coffeeify'
uglifyify   = require 'uglifyify'
source      = require 'vinyl-source-stream'

streamify   = require 'gulp-streamify'

### IMAGES ###

gulp.task 'images', ->
  gulp.src ['./static/images/**/*']
  .pipe plumber()
  .pipe imagemin({
    optimizationLevel: 5
    interlaced: true
    multipass: true
    progressive: true
  })
  .pipe gulp.dest './static/dist/images'

gulp.task 'images:watch', ->
  gulp.src ['./static/images/**/*']
  .pipe plumber()
  .pipe watch('./static/images/**/*')
  .pipe imagemin({
    optimizationLevel: 5
    interlaced: true
    multipass: true
    progressive: true
  })
  .pipe gulp.dest './static/dist/images'


### LESS ###

gulp.task 'less', ->
  gulp.src ['./static/less/app.less']
  .pipe plumber()
  .pipe less()
  .pipe prefix({
    browsers: ['last 2 versions']
    cascade: true
  })
  .pipe gulp.dest './static/dist/css'
  .pipe minify()
  #.pipe concat('app.min.css')
  .pipe rename((path) ->
    path.basename = 'app.min'
  )
  .pipe gulp.dest './static/dist/css'

gulp.task 'less:watch', ->
  gulp.src ['./static/less/app.less']
  .pipe plumber()
  .pipe watch('./static/less/**/*.less')
  .pipe less()
  .pipe prefix({
    browsers: ['last 2 versions']
    cascade: true
  })
  .pipe gulp.dest './static/dist/css'
  .pipe minify()
  #.pipe concat('app.min.css')
  .pipe rename((path) ->
    path.basename = 'app.min'
  )
  .pipe gulp.dest './static/dist/css'

### COFFEE ###

gulp.task 'coffee', ->
  b = browserify({
    entries: './static/coffeescript/app/app.coffee'
  #debug: true
    transform: [ coffeeify, bngann, debowerify  ]
    extensions: ['.coffee']
  })
  return b.bundle()
  .pipe source 'app.js'
  .pipe gulp.dest './static/dist/javascript/'
###.pipe uglify()
.pipe gulp.dest './static/dist/javascript'###


gulp.task 'copy', ->
  gulp.src ['./static/copy/**/*']
  .pipe gulp.dest './static/dist/'

### CLEAN ###
gulp.task 'clean', (callback) ->
  del ['./static/dist/**/*'], callback

### BUILD ####
gulp.task 'rebuild', (callback) ->
  util.log 'Starting full application rebuild'
  runsequence 'clean', ['copy', 'less', 'images', 'coffee'], callback

gulp.task 'build', (callback) ->
  util.log 'Starting application build'
  runsequence ['copy', 'less', 'images', 'coffee'], callback

gulp.task 'default', ['build']