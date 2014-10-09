module.exports = (config) ->
  config.set
    browsers: [ 'PhantomJS' ]
    frameworks: [ 'browserify', 'mocha' ]
    reporters: [ 'mocha' ]
    files: [
      'test-js/test_helper.coffee'
      'test-js/**/*Spec.coffee'
    ]
    preprocessors: {
      '**/*.coffee': [ 'browserify' ]
    }

    browserify:
      extensions: [ '.js', '.coffee' ]
      transform: [ 'coffeeify' ]
      debug: true

    logLevel: config.LOG_INFO
