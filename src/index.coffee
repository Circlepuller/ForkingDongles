# Import needed libraries/modules. This includes node-irc, the framework's
# "skeleton", and various utilities.
colors = require 'colors'
irc    = require 'irc'
_      = require 'underscore'
util   = require 'util'

# Declare the "anonymous" class that is known only as ForkingDongles. Inherit
# the class attributes of node-irc's `Client` class, as we will need them.
class module.exports extends irc.Client

  # The majestic class contructor. Takes the same arguments that the parent
  # class does. (Inheritance much?)
  constructor: ->

    # Setup some variables now so we don't get unnecessary errors later.
    @middlewares = []
    @modules = {}

    # This is where the parent contructor is called, in case you didn't know.
    super

    # Setup an error handler, because without one, you're in the dark about
    # knowing what's not working with your bot.
    @on 'error', (event) -> @error event.command.toUpperCase()

    # Load any modules specified in the options, if any are given.
    @load module for module in @opt.modules if @opt.modules?

  # This does that same thing as node-irc's `Client.prototype.connect`, but is
  # slightly more verbose.
  connect: ->
    # Indicate the bot is connecting to the given server.
    @info "Connecting to \"#{@opt.server}\"..."

    super

    # Once the connection to the server is complete, indicate that we did.
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

  # **Todo:** Proper module loading, because the current implementation has
  # serious flaws.
  load: (mod, cb) =>
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

  # **Todo:** Proper module unloading, because it has the same issue as loading
  # them.
  unload: (mod, cb) =>
    unless @modules.hasOwnProperty mod
      @error msg = "Module \"#{mod}\" not loaded."

      return cb? msg

    # This is still really bad.
    @modules[mod].destructor?()
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
