# Grunt is so last month. We use Gulp because it's easier to get everything
# (especially RequireJS) working properly.
#
# We need to keep the Gruntfile because Sails depends on it; but we'll just
# forward everything to Gulp.
module.exports = (grunt) ->
  gulp = "node node_modules/gulp/bin/gulp.js --require coffee-script/register"

  grunt.initConfig
    shell:
      default:
        command: "#{gulp} default"

      prod:
        command: "#{gulp} prod"

      build:
        command: "#{gulp} build"

      buildProd:
        command: "#{gulp} buildProd"

  grunt.loadNpmTasks('grunt-shell')

  # sails lift --> default
  grunt.registerTask('default', [ 'shell:default' ])

  # sails lift --prod --> prod
  grunt.registerTask('prod', [ 'shell:prod' ])

  # sails www --> build
  grunt.registerTask('build', [ 'shell:build' ])

  # sails www --prod
  grunt.registerTask('buildProd', [ 'shell:buildProd' ])
