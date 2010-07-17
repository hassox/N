(function(){
  var Connect, Jade, Wrapt;
  Connect = require('connect');
  Jade = require('jade');
  Wrapt = function(opts) {
    var _a, _b, master, roots;
    master = opts || {};
    Wrapt.instances.push(master);
    roots = [];
    Wrapt.roots.forEach(function(root) {
      return roots.push(root);
    });
    master.roots = (typeof (_a = master.roots) !== "undefined" && _a !== null) ? master.roots : roots;
    master.templateDirs = (typeof (_b = master.templateDirs) !== "undefined" && _b !== null) ? master.templateDirs : ['views', 'views/layouts'];
    master.cache = {};
    master.defaultFormat = 'html';
    return function(req, resp, next) {
      var layout;
      layout = {};
      layout.content = {};
      return layout.content;
    };
  };
  Wrapt.instances = [];
  Wrapt.roots = [("" + (process.cwd))];
})();
