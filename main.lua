---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Meevere.
--- DateTime: 16.10.2022 12:20
---

Vector2, Vector3 = unpack(require("utility/vector"))
Stack = require("utility/stack")
dump = require("utility/dump")
fill_table = require("utility/settingslike")

function pdump(o, n, i)
    print(dump(o, n or 3, i or 2))
end

tiny = require("libs/tiny")
require("libs/strong")

local Camera = require("libs/MyCamera")
local window_w, window_h, flags = love.window.getMode()

GraphicsLoader = require("loaders/GraphicsLoader")()

LEVELS = {
    forest = require("levels/forest/forest"),
    mainMenu = require("levels/main_menu/main_menu")
}

GAME_CANVAS = love.graphics.newCanvas(400, 300)

function DRAW_GAME_CANVAS()
    love.graphics.setCanvas()
    love.graphics.draw(GAME_CANVAS, 0, 0, 0, 1.5)
    love.graphics.setCanvas(GAME_CANVAS)
end

function CHANGE_LEVEL(level)
    CURRENT_LEVEL = level
    if level == "exit" then
        love.event.quit()
        return
    end
    CURRENT_LEVEL.load()
end

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle("HeavySteelRoads")
    love.window.setMode( 800, 600, {
        resizable = true,
        minwidth = 800,
        minheight = 600
    } )

    camera = Camera();
    camera:setFromSizes({0,0}, {window_w, window_h}, {0,0}, {window_w, window_h} )
    camera:setDeadzone({camera.from.size[1]/2 - 40, camera.from.size[2]/2}, {80, camera.from.size[2]})

    love.physics.setMeter(64)

    CURRENT_LEVEL = LEVELS.mainMenu;
    CURRENT_LEVEL.load()
end

function love.update(dt)
    CURRENT_LEVEL.update(dt)
end

function love.draw()
    local dt = love.timer.getDelta()
    CURRENT_LEVEL.draw(dt)
end

function love.keypressed(key, scancode, is_repeat)
    if CURRENT_LEVEL.keypressed then
        CURRENT_LEVEL.keypressed(key, scancode, is_repeat)
    end
end

function love.keyreleased(key, scancode)
    if CURRENT_LEVEL.keyreleased then
        CURRENT_LEVEL.keyreleased(key, scancode)
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    if CURRENT_LEVEL.mousemoved then
        CURRENT_LEVEL.mousemoved(x, y, dx, dy, istouch)
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if CURRENT_LEVEL.mousepressed then
        CURRENT_LEVEL.mousepressed(x, y, button, istouch, presses)
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    if CURRENT_LEVEL.mousereleased then
        CURRENT_LEVEL.mousereleased(x, y, button, istouch, presses)
    end
end

function love.resize(w, h)
    --camera.w = w
    --camera.h = h
    camera:setFromSizes({0,0}, {w,h})
    if CURRENT_LEVEL.resize then
        CURRENT_LEVEL.resize(w, h)
    end
end