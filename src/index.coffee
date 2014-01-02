colors = require 'colors'
irc    = require 'irc'
_      = require 'underscore'
util   = require 'util'

class module.exports extends irc.Client
  constructor: ->
    @middlewares = []
    @modules = {}

    super

    @on 'error', (event) -> @error event.command.toUpperCase()

    @load module for module in @opt.modules if @opt.modules?

  connect: ->
    @info "Connecting to \"#{@opt.server}\"..."

    super

    @once 'registered', -> @info "Connected to \"#{@opt.server}\"."

  log: ->
    for arg in arguments
      util.log '       ' + util.inspect arg, colors: true

  info: ->
    for arg in arguments
      util.log ' Info: '.green + util.inspect arg, colors: true

  warn: ->
    for arg in arguments
      util.log ' Warn: '.yellow + util.inspect arg, colors: true

  error: ->
    for arg in arguments
      util.log 'Error: '.red + util.inspect arg, colors: true

  load: (mod, cb) =>
    # TODO: Proper module loading
    try
      unless @modules.hasOwnProperty mod
        unless @modules[mod] = new (require mod)? @
          throw code: 'MODULE_IN_INCORRECT_FORMAT'

        @info "Loaded module \"#{mod}\"."

        cb? null
      else throw code: 'MODULE_ALREADY_LOADED'

    catch err
      @error msg = switch err.code
        when 'MODULE_ALREADY_LOADED' then "Module \"#{mod}\" already loaded."
        when 'MODULE_NOT_FOUND' then "Module \"#{mod}\" not found."
        when 'MODULE_IN_INCORRECT_FORMAT' then "Module \"#{mod}\" is unable " \
          + 'to load due to incorrect code format.'
        else "Module \"#{mod}\" cannot be loaded."

      cb? msg

  unload: (mod, cb) =>
    # TODO: Proper module unloading
    unless @modules.hasOwnProperty mod
      @error msg = "Module \"#{mod}\" not loaded."

      return cb? msg

    # TODO: Unloading properly
    @modules[mod].destruct?()
    delete require.cache[require.resolve mod]
    delete @modules[mod]

    @info "Stopped module \"#{mod}\"."

    cb? null

  addListener: (event, middlewares..., fn) ->
    super event, @wrap fn, middlewares

  on: -> @addListener arguments...

  once: (event, middlewares..., fn) -> super event, @wrap fn, middlewares

  wrap: (fn, middlewares) -> (args...) =>
    _.reduceRight(@middlewares.concat(middlewares), (memo, item) =>
      next = => memo.apply @, args
      return -> item.apply @, [args..., next]
    , fn).apply @, arguments

  use: -> @middlewares.push arguments...
