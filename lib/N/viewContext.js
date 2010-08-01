(function(){
  var ViewContext, mixin, sys;
  var __slice = Array.prototype.slice, __hasProp = Object.prototype.hasOwnProperty;
  sys = require('sys');
  mixin = function() {
    var _c, _d, _e, _f, _g, _h, helper, helpers, prop, val;
    var _a = arguments.length, _b = _a >= 1;
    helpers = __slice.call(arguments, 0, _a - 0);
    _c = []; _e = helpers;
    for (_d = 0, _f = _e.length; _d < _f; _d++) {
      helper = _e[_d];
      _c.push((function() {
        _g = []; _h = helper;
        for (prop in _h) { if (__hasProp.call(_h, prop)) {
          val = _h[prop];
          _g.push((function() {
            sys.puts(("Adding: " + (prop)));
            this.prototype[prop] = val;
            return this.prototype[prop];
          }).call(this));
        }}
        return _g;
      }).call(this));
    }
    return _c;
  };
  ViewContext = function(req, opts) {
    this.request = req;
    this.options = opts || {};
    this.format = opts.format || 'html';
    return this;
  };
  ViewContext.mixin = mixin;

  module.exports = ViewContext;
})();
