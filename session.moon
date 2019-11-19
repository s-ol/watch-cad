lfs = require 'lfs'
utf8 = require 'utf8'
moon = require 'moonscript.base'

{ graphics: lg } = love
trace = (msg) -> debug.traceback msg, 2

class Script
  new: (@file) =>
    @last_modification = 0
    @func = ->

  commit: =>
    export COMMIT
    COMMIT = true

    return unless @func

    ok, msg = xpcall @func, trace, STATE.root
    if not ok
      @error = at: 'commit', :msg
      return

    COMMIT = false

  reload_and_run: =>
    func = @reload!
    @func = func if func

    ok, msg = xpcall @func, trace, STATE.root
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
    { :mode, :modification } = (lfs.attributes @file) or {}
    if mode != 'file'
      @error = at: 'parse', msg: "script doesn't exist or is not a file: '#{@file}'"
      return

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

import Object from require 'object'

class Session
  FONTSIZE = 20
  new: (scriptfile) =>
    @objects = {}

    if scriptfile
      @script = Script scriptfile

    @font = lg.newFont 'font/FantasqueSansMono-Regular.ttf', 20
    @ex = false

  exec: (command) =>
    switch command\match '^(%w+)'
      when 'quit'
        love.event.quit!
      when 'run'
        arg = command\match '^run%s+(.+)'
        @script = arg and Script arg

  frame: =>
    lg.setColor 1, 1, 1
    for obj in *@objects
      obj\draw!

    if INPUT\key_down 'escape'
      STATE\reset!

    w,h = lg.getDimensions!
    lg.setFont @font

    if @script
      lg.setColor .5, .5, .5
      depth = lg.getStackDepth!

      @script\reload_and_run!

      if INPUT\key_down 'space'
        @script\commit!
        STATE\reset!

      while lg.getStackDepth! > depth
        lg.pop!
        
      lg.setColor 1, 1, 1
      lg.print "script: #{@script.file}", 10, 10

    if (INPUT\key_down ':') or (INPUT\key_down ';') and INPUT\key_held 'lshift'
      INPUT\text_capture!
      @ex = true

    if @ex
      lg.setColor 1, 1, 1
      lg.print ":#{INPUT.text}", 10, h - 10 - FONTSIZE
      
      apply = INPUT\key_down 'return'
      input = if apply or INPUT\key_down 'escape'
        @ex = nil
        apply and @exec INPUT\text_release!

      @exec input if input

{
  :Script
  :Session
}
