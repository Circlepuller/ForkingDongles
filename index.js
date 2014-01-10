var ForkingDongles, colors, irc, util, _,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __slice = [].slice;

colors = require('colors');

irc = require('irc');

_ = require('underscore');

util = require('util');

ForkingDongles = (function(_super) {
  __extends(ForkingDongles, _super);

  function ForkingDongles() {
    this.unload = __bind(this.unload, this);
    this.load = __bind(this.load, this);
    var module, _i, _len, _ref;
    this.middlewares = [];
    this.modules = {};
    ForkingDongles.__super__.constructor.apply(this, arguments);
    this.on('error', function(event) {
      return this.error(event.command.toUpperCase());
    });
    if (this.opt.modules != null) {
      _ref = this.opt.modules;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        module = _ref[_i];
        this.load(module);
      }
    }
  }

  ForkingDongles.prototype.connect = function() {
    this.info("Connecting to " + this.opt.server);
    ForkingDongles.__super__.connect.apply(this, arguments);
    return this.once('registered', function() {
      return this.info("Connected to " + this.opt.server);
    });
  };

  ForkingDongles.prototype.log = function() {
    var arg, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = arguments.length; _i < _len; _i++) {
      arg = arguments[_i];
      _results.push(util.log('       ' + util.inspect(arg, {
        colors: true
      })));
    }
    return _results;
  };

  ForkingDongles.prototype.info = function() {
    var arg, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = arguments.length; _i < _len; _i++) {
      arg = arguments[_i];
      _results.push(util.log(' Info: '.green + util.inspect(arg, {
        colors: true
      })));
    }
    return _results;
  };

  ForkingDongles.prototype.warn = function() {
    var arg, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = arguments.length; _i < _len; _i++) {
      arg = arguments[_i];
      _results.push(util.log(' Warn: '.yellow + util.inspect(arg, {
        colors: true
      })));
    }
    return _results;
  };

  ForkingDongles.prototype.error = function() {
    var arg, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = arguments.length; _i < _len; _i++) {
      arg = arguments[_i];
      _results.push(util.log('Error: '.red + util.inspect(arg, {
        colors: true
      })));
    }
    return _results;
  };

  ForkingDongles.prototype.load = function(mod, cb) {
    var err, msg, _base;
    try {
      if (!this.modules.hasOwnProperty(mod)) {
        if (!(this.modules[mod] = typeof (_base = require(mod)) === "function" ? new _base(this) : void 0)) {
          throw {
            code: 'MODULE_IN_INCORRECT_FORMAT'
          };
        }
        this.info("Loaded module " + mod + ".");
        return typeof cb === "function" ? cb() : void 0;
      } else {
        throw {
          code: 'MODULE_ALREADY_LOADED'
        };
      }
    } catch (_error) {
      err = _error;
      this.error(msg = (function() {
        switch (err.code) {
          case 'MODULE_ALREADY_LOADED':
            return "Module " + mod + " already loaded.";
          case 'MODULE_NOT_FOUND':
            return "Module " + mod + " not found.";
          case 'MODULE_IN_INCORRECT_FORMAT':
            return ("Module " + mod + " is unable ") + 'to load due to incorrect code format.';
          default:
            return "Module " + mod + " cannot be loaded.";
        }
      })());
      return typeof cb === "function" ? cb(msg) : void 0;
    }
  };

  ForkingDongles.prototype.unload = function(mod, cb) {
    var msg, _base;
    if (!this.modules.hasOwnProperty(mod)) {
      this.error(msg = "Module " + mod + " not loaded.");
      return typeof cb === "function" ? cb(msg) : void 0;
    }
    if (typeof (_base = this.modules[mod]).destructor === "function") {
      _base.destructor();
    }
    delete require.cache[require.resolve(mod)];
    delete this.modules[mod];
    this.info("Stopped module " + mod);
    return typeof cb === "function" ? cb() : void 0;
  };

  ForkingDongles.prototype.addListener = function() {
    var event, fn, middlewares, _i;
    event = arguments[0], middlewares = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), fn = arguments[_i++];
    return ForkingDongles.__super__.addListener.call(this, event, this.wrap(fn, middlewares));
  };

  ForkingDongles.prototype.on = function() {
    return this.addListener.apply(this, arguments);
  };

  ForkingDongles.prototype.once = function() {
    var event, fn, middlewares, _i;
    event = arguments[0], middlewares = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), fn = arguments[_i++];
    return ForkingDongles.__super__.once.call(this, event, this.wrap(fn, middlewares));
  };

  ForkingDongles.prototype.wrap = function(fn, middlewares) {
    var _this = this;
    return function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return _.reduceRight(_this.middlewares.concat(middlewares), function(memo, item) {
        var next;
        next = function() {
          return memo.apply(_this, args);
        };
        return function() {
          return item.apply(this, __slice.call(args).concat([next]));
        };
      }, fn).apply(_this, arguments);
    };
  };

  ForkingDongles.prototype.use = function() {
    var _ref;
    return (_ref = this.middlewares).push.apply(_ref, arguments);
  };

  return ForkingDongles;

})(irc.Client);

module.exports.ForkingDongles = ForkingDongles;
