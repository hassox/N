Connect: require 'connect'
Jade: require 'jade'

Wrapt: (opts) ->
  master: opts || {}
  Wrapt.instances.push(master) #

  # setup the directories to look in for the
  # layout files
  roots: []
  Wrapt.roots.forEach (root) ->
    roots.push(root)

  master.roots        ?=  roots
  master.templateDirs ?=  ['views', 'views/layouts']
  master.cache:           {}
  master.defaultFormat:   'html'

  # Return the function to use in the stack
  (req, resp, next) ->
    layout:         {}
    layout.content: {}




Wrapt.instances: []
Wrapt.roots: ["${process.cwd}"]
