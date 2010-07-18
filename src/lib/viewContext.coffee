class ViewContext
  # Each time you extend the view context,
  # You need to copy over this method
  @mixin: (helpers...) ->
    for helper in helpers
      for prop, val of helper
        this.prototype[prop]: val

  constructor: (req, opts)
    @request: req
    @options: opts || {}
    @format:  opts.format || 'html'

module.exports = ViewContext
