gulp = require('gulp')
clean = require('gulp-clean')
coffee = require('gulp-coffee')
fs = require('fs')
gutil = require('gulp-util')
less = require('gulp-less')
minifyCss = require('gulp-minify-css')
requirejs = require('requirejs')
watch = require('gulp-watch')

paths =
  # Coffee puts stuff in .tmp/dev
  #
  # In dev mode, we'll copy that to .tmp/public; in prod, we'll bundle with JS.
  coffee:
    src: 'assets/js/**/*.coffee'
    dest: '.tmp/dev/js'

  # Put stuff in .tmp/dev, alongside the CoffeeScript, ready for bundling.
  js:
    src: 'assets/js/**/*.js'
    dest: '.tmp/dev/js'

  # We compile just the one file.
  #
  # We put it in .tmp/dev; in production, we'll minify it.
  less:
    src: 'assets/styles/main.less'
    dest: '.tmp/dev/styles'

  # Fonts go straight to public/, in any environment.
  fonts:
    src: 'assets/fonts/**/*'
    dest: '.tmp/public/fonts'

  # For watching, we need to watch every .less file
  allLess:
    src: 'assets/styles/**/*.less'

  # All stuff in ./tmp/dev/ should be in .tmp/public/ during dev
  dev:
    src: '.tmp/dev/**/*'
    dest: '.tmp/public'

  devCss:
    src: '.tmp/dev/styles/**/*.css'
    dest: '.tmp/public/styles'

compileCoffee = ->
  gulp.src(paths.coffee.src)
    .pipe(coffee().on('error', gutil.log))
    .pipe(gulp.dest(paths.coffee.dest))

copyJs = ->
  gulp.src(paths.js.src)
    .pipe(gulp.dest(paths.js.dest))

compileLess = ->
  gulp.src(paths.less.src)
    .pipe(less().on('error', gutil.log))
    .pipe(gulp.dest(paths.less.dest))

copyDir = (src, dest) ->
  gulp.src(src)
    .pipe(gulp.dest(dest))

gulp.task 'clean', ->
  gulp.src('.tmp/public/', read: false)
    .pipe(clean(force: true))

gulp.task('coffee', compileCoffee)
gulp.task('less', compileLess)
gulp.task('js', -> copyDir(paths.js.src, paths.js.dest))
gulp.task('fonts', -> copyDir(paths.fonts.src, paths.fonts.dest))
gulp.task('dev-to-public', -> copyDir(paths.dev.src, paths.dev.dest))

gulp.task('compileAssets', [ 'coffee', 'js', 'less', 'fonts' ])

gulp.task 'linkAssets', [ 'compileAssets' ], ->
  copyDir(paths.dev.src, paths.dev.dest)

gulp.task 'deployJs', [ 'coffee', 'js' ], (cb) ->
  requirejs.optimize({
    appDir: '.tmp/dev'
    baseUrl: 'js'
    dir: '.tmp/rjs'
    modules: [
      { name: 'main' }
    ]
  }, (s) ->
    gulp.src('.tmp/rjs/js/main.js')
      .pipe(gulp.dest('.tmp/public/js'))
      .on('end', cb)
  , cb)

gulp.task 'deployRjsLoader', [ 'js' ], ->
  gulp.src('.tmp/dev/js/bower_components/requirejs/require.js')
    .pipe(gulp.dest('.tmp/public/js/bower_components/requirejs'))

gulp.task 'deployCss', [ 'less' ], ->
  gulp.src(paths.devCss.src)
    .pipe(minifyCss())
    .pipe(gulp.dest(paths.devCss.dest))

gulp.task 'realDefault', [ 'compileAssets', 'linkAssets' ], ->
  gulp.watch(paths.coffee.src, [ 'coffee' ])
  gulp.watch(paths.js.src, [ 'js' ])
  gulp.watch(paths.allLess.src, [ 'less' ])
  gulp.watch(paths.fonts.src, [ 'fonts' ])
  gulp.watch(paths.dev.src, [ 'dev-to-public' ])

gulp.task('realProd', [ 'deployJs', 'deployRjsLoader', 'deployCss', 'fonts' ])

gulp.task 'default', [ 'clean' ], ->
  gulp.start('realDefault')

gulp.task 'prod', [ 'clean' ], ->
  gulp.start('realProd')
