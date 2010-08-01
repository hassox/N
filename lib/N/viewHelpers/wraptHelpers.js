(function(){
  var __slice = Array.prototype.slice;
  module.exports.javascriptIncludeTag = function() {
    var _c, _d, _e, name, names, out;
    var _a = arguments.length, _b = _a >= 1;
    names = __slice.call(arguments, 0, _a - 0);
    out = '';
    _d = names;
    for (_c = 0, _e = _d.length; _c < _e; _c++) {
      name = _d[_c];
      out += ("<script src='/javascripts/" + (name) + "'></script>\n");
    }
    return out;
  };
  module.exports.cssIncludeTag = function() {
    var _c, _d, _e, name, names, out;
    var _a = arguments.length, _b = _a >= 1;
    names = __slice.call(arguments, 0, _a - 0);
    out = '';
    _d = names;
    for (_c = 0, _e = _d.length; _c < _e; _c++) {
      name = _d[_c];
      out += ("<link href='/stylesheets/" + (name) + "'></link>\n");
    }
    return out;
  };
  module.exports.yield = function(type) {
    return this.content[type || 'main'];
  };
})();
