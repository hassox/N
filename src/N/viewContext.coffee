sys: require('sys')
# A mixin helper.  This must be manually copied from one constructor function to another
#
# @example coffee-script
#   class Foo extend ViewContext
#     @mixin: ViewContext.mixin
#
# A mixin is useful for adding helpers to a constructor
#
# Foo.mixin(TagHelpers, FormHelpers)
mixin: (helpers...) ->
  for helper in helpers
    for prop, val of helper
      sys.puts "Adding: ${prop}"
      this.prototype[prop]: val

class ViewContext
  # Each time you extend the view context,
  # You need to copy over this method
  @mixin: mixin

  constructor: (req, opts) ->
    @request: req
    @options: opts || {}
    @format:  opts.format || 'html'

module.exports = ViewContext
