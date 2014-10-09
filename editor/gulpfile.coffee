browserify = require('browserify')
gulp = require('gulp')
gutil = require('gulp-util')
less = require('gulp-less')
rimraf = require('rimraf')
source = require('vinyl-source-stream')
watch = require('gulp-watch')
watchify = require('watchify')

buildBrowserify = ->
  browserify({
    cache: {}
    packageCache: {}
    fullPaths: true
    entries: [
      './assets/js/main.coffee'
    ]
    extensions: [ '.js', '.coffee' ]
    debug: true
  })
    .transform('coffeeify')

gulp.task 'browserify', ->
  buildBrowserify()
    .plugin('minifyify', map: 'main.js', output: './dist/public/js/main.js.map')
    .bundle()
    .on('error', console.warn)
    .pipe(source('main.js'))
    .pipe(gulp.dest('./dist/public/js/'))

gulp.task 'browserify-dev', ->
  bundler = watchify(buildBrowserify(), watchify.args)

  rebundle = ->
    bundler.bundle()
      .on('error', console.warn)
      .pipe(source('main.js'))
      .pipe(gulp.dest('./dist/public/js/'))

  bundler.on('update', rebundle)
  rebundle()

gulp.task 'fonts', ->
  gulp.src('assets/fonts/**/*')
    .pipe(gulp.dest('dist/public/fonts'))

gulp.task 'less', ->
  gulp.src('assets/styles/main.less')
    .pipe(less().on('error', gutil.log))
    .pipe(gulp.dest('dist/public/styles'))

gulp.task 'clean', (done) ->
  rimraf('dist', done)

gulp.task 'realDefault', [ 'browserify-dev', 'fonts', 'less' ], ->
  gulp.watch('assets/styles/**/*.less', [ 'less' ])
  gulp.watch('assets/fonts/**/*', [ 'fonts' ])

gulp.task 'realProd', [ 'browserify', 'fonts', 'less' ], ->

gulp.task 'default', [ 'clean' ], ->
  gulp.start('realDefault')
  require('./index')

gulp.task 'prod', [ 'clean' ], ->
  gulp.start('realProd')
