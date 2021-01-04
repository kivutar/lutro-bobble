require "global"

function love.conf(t)
    t.window.title = "Bobble"
    t.window.width = SCREEN_WIDTH*3
    t.window.height = SCREEN_HEIGHT*3
    t.modules.physics = false
    t.console = true
end