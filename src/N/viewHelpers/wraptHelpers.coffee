# Add javascripts into the page
#
# = javascriptIncludeTags "someScript", "anotherScript"
# #=> <script src='/javascripts/someScript'></script>
# #=> <script src='/javascripts/anotherScript'></script>
module.exports.javascriptIncludeTag: (names...) ->
  out: ''
  for name in names
    out += "<script src='/javascripts/${name}'></script>\n"
  out

# Add css into the page
#
# = cssIncludeTags "someCss", "anotherCss"
# #=> <link href='/stylesheets/someCss'></link>
# #=> <link src='/stylesheets/anotherCss'></link>
module.exports.cssIncludeTag: (names...) ->
  out: ''
  for name in names
    out += "<link href='/stylesheets/${name}'></link>\n"
  out

# Yields the template out to some content previously set

# != yield('main')
#
# #=> = content.main
module.exports.yield: (type) ->
  @content[type || 'main']

