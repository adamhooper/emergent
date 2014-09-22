module.exports = function(grunt) {
  grunt.initConfig({
    browserify: {
      options: {
        transform: [ require('grunt-react').browserify ]
      },
      client: {
        src: ['public/js/app.js.jsx'],
        dest: 'public/scripts/app.js'
      }
    },
    sass: {
      dist: {
        options: {
          bundleExec: true,
          compass: true,
          require: [
            'breakpoint',
            'susy',
            'normalize-scss'
          ]
        },
        files: {
          'public/styles/main.css': 'public/css/main.scss'
        }
      }
    },
    watch: {
      scripts: {
        files: ['public/js/**/*'],
        tasks: ['browserify', 'uglify']
      },
      sass: {
        files: ['public/css/**/*'],
        tasks: ['sass']
      }
    },
    uglify: {
      dist: {
        files: {
          'public/scripts/app.min.js' : [ 'public/scripts/app.js' ]
        }
      }
    }
  });
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-sass');
  grunt.loadNpmTasks('grunt-browserify');
  grunt.loadNpmTasks('grunt-contrib-uglify');

  grunt.registerTask('default', ['browserify', 'uglify', 'watch']);
};
