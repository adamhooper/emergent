module.exports = (config) ->
  config.set
    basePath: ''
    frameworks: ['mocha', 'requirejs' ]
    files: [
      'test-js/test-main.coffee',
      {pattern: 'assets/js/**/*.js', included: false}
      {pattern: 'assets/js/**/*.coffee', included: false}
      {pattern: 'test-js/**/*Spec.js', included: false}
      {pattern: 'test-js/**/*Spec.coffee', included: false}
    ]
    exclude: [
      'assets/js/main.js'
      'assets/js/bower_components/**/*spec.js'
      'assets/js/bower_components/**/*test.js'
    ]
    preprocessors: {
      '**/*.coffee': ['coffee']
    }
    reporters: ['dots']
    port: 9876
    colors: true
    logLevel: config.LOG_INFO
    autoWatch: true
    browsers: ['PhantomJS']
    singleRun: false
