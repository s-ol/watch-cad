lfs = require 'lfs'
moon = require 'moonscript.base'

trace = (msg) -> debug.traceback msg, 2

class Script
  new: (@file) =>
    print "loading script '#{@file}'..."
    @last_modification = 0
    @func = -> print 'idle'

  commit: =>
    export COMMIT
    COMMIT = true

    return unless @func

    ok, msg = xpcall @func, trace, STATE.state
    if not ok
      @error = at: 'commit', :msg
      return

    COMMIT = false

  reload_and_run: =>
    func = @reload!
    @func = func if func

    ok, msg = xpcall @func, trace, STATE.state
    if not ok
      @error = at: 'exec', :msg

    @print_error!

  print_error: =>
    if @error
      switch @error.at
        when 'parse'  do print "--- ERROR PARSING SCRIPT #{@file} ---"
        when 'load'   do print "--- ERROR LOADING SCRIPT: #{@file} ---"
        when 'exec'   do print "--- ERROR EXECUTING SCRIPT: #{@file} ---"
        when 'commit' do print "--- ERROR COMMITTING SCRIPT: #{@file} ---"

      print @error.msg

  reload: =>
    modification = lfs.attributes @file, 'modification'

    if @last_modification < modification
      @last_modification = modification
      module, msg = if @file\match '%.moon$' then moon.loadfile @file else loadfile @file
      if not module
        @error = at: 'parse', :msg
        return

      ok, msg = xpcall module, trace
      if not msg
        @error = at: 'load', :msg
        return

      @error = nil
      msg

class Session
  new: (@script) =>
    @objects = {}

  frame: =>
    for obj in *@objects
      obj\draw!

    if INPUT\key_down 'escape'
      STATE\reset!

    @script\reload_and_run!

    if INPUT\key_down 'space'
      @script\commit!
      STATE\reset!


{
  :Script
  :Session
}
