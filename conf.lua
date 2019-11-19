function love.conf(t)
    t.version = "11.0"                  -- The LÖVE version this game was made for (string)
    t.console = true                    -- Attach a console (boolean, Windows only)
 
    t.identity = "watch-cad"            -- The name of the save directory (string)
    t.window.title = "watch-cad"        -- The window title (string)
    t.window.width = 800                -- The window width (number)
    t.window.height = 600               -- The window height (number)
    t.window.resizable = true           -- Let the window be user-resizable (boolean)
    t.window.minwidth = 100             -- Minimum window width if the window is resizable (number)
    t.window.minheight = 100            -- Minimum window height if the window is resizable (number)
    t.window.vsync = 0                  -- Vertical sync mode (number)
    t.window.msaa = 0                   -- The number of samples to use with multi-sampled antialiasing (number)
    t.window.highdpi = false            -- Enable high-dpi mode for the window on a Retina display (boolean)
 
    t.modules.data = false              -- Enable the data module (boolean)
    t.modules.joystick = false          -- Enable the joystick module (boolean)
    t.modules.video = false             -- Enable the video module (boolean)
    t.modules.physics = false           -- Enable the physics module (boolean)
end
