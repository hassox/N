fs:     require 'fs'
paths:  require 'path'
sys:    require 'sys'

task 'build', 'build N ready to ship', ->

  console.log "Installing into ${path}"
  console.log "Removing all .js files"

  # remove all javascript files
  for files in ["*.js", "**/*.js"]
    try
      fs.unlinkSync( paths.join( __dirname, 'lib', files ) )
    catch e
      'noop'

  # Compile the code
  spawn: require("child_process").spawn

  compiler: spawn "coffee", ["-c", "${paths.join(__dirname, 'src')}", "-o", "${paths.join(__dirname, 'lib')}"]

  compiler.stdout.addListener "data", (data) ->
    console.log data

  compiler.addListener 'exit', () ->
    console.log "Compile complete."
    process.exit 0

  compiler.stderr.addListener "data", (data) ->
    console.log "ERROR: ${data}"
