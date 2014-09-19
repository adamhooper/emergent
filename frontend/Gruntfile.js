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
      options: {
        livereload: true
      },
      scripts: {
        files: ['public/js/**/*'],
        tasks: ['browserify']
      },
      sass: {
        files: ['public/css/**/*'],
        tasks: ['sass']
      }
    }
  });
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-sass');
  grunt.loadNpmTasks('grunt-browserify');

  grunt.registerTask('default', ['browserify', 'watch']);
};
