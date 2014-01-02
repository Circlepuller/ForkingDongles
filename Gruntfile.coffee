module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      compile:
        expand: true
        cwd: './src'
        src: ['**/*.coffee']
        dest: './'
        ext: '.js'
        options:
          bare: true
    
    docco:
      compile:
        src: ['./src/**/*.coffee']
        options:
          output: './docs/'

    watch:
      compile:
        files: './src/**/*.coffee'
        tasks: ['coffee', 'docco']

  grunt.loadNpmTasks 'grunt-docco'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'default', ['coffee']