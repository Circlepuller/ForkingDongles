module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      compile:
        expand: true
        cwd: './src'
        src: ['**/*.litcoffee']
        dest: './lib'
        ext: '.js'
        options:
          bare: true
    
    docco:
      compile:
        src: ['./src/**/*.litcoffee']
        options:
          output: './docs/'

    watch:
      compile:
        files: './src/**/*.litcoffee'
        tasks: ['coffee', 'docco']

  grunt.loadNpmTasks 'grunt-docco'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'default', ['coffee']