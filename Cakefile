{spawn} = require 'child_process'
{readdir} = require 'fs'
{log} = require 'util'

docs = (options) ->
  docco = spawn 'docco', ['-o', 'docs/']

  docco.stdout.on 'data', log
  docco.stderr.on 'data', log

watch = (options) ->
  coffee = spawn 'coffee', ['-o', '-cw', 'lib/', 'src/']

  coffee.stdout.on 'data', (data) ->
    log "coffee: #{data}"

    docs options

task 'docs', 'compile documentation', docs
task 'watch', 'watch for changes and compile them', watch

