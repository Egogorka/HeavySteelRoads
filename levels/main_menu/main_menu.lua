---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Meevere.
--- DateTime: 22.11.2022 23:14
---

local anim8 = require("libs/anim8")
local TINY = require("libs/TINY")
local loveframes = require("libs/loveframes")
local dump = require("utility/dump")

local Vector2, Vector3 = unpack(require('utility/vector'))
local window_w, window_h, flags = love.window.getMode()

local Sprite, MSprite, Depth, Placement = unpack(require('src/graphics/Sprite'))

local SpriteSystem = require("src/graphics/SpriteSystem")()

local Scene = require("src/scene/Scene")
local MainMenu = Scene()

local world = TINY.world()
world:addSystem(SpriteSystem)

local sprites = {}
local animations = {}

local function load_sprites()
    do
        local temp = love.graphics.newImage("assets/gui/AncharMenu1.png")
        sprites.background = Sprite(
            temp, true, Vector2(-temp:getWidth()/2, 0), Vector2(temp:getWidth()/2, 0)
        )
    end
    do
        local temp = love.graphics.newImage("assets/gui/Logo3.png")
        sprites.logo = Sprite(
            temp, true, Vector2(-temp:getWidth()/2, -temp:getHeight()/2), Vector2(temp:getWidth()/2, temp:getHeight()/2)
        )
    end

    local button_image = love.graphics.newImage("assets/gui/MenuButtons2.png")
    local button_grid = anim8.newGrid(
            102, 18,
            button_image:getWidth(), button_image:getHeight(),
            0,0, 5)
    animations.button = Sprite({
        animations = {
            to_state1 = {
                anim8.newAnimation(button_grid(1,'12-1'), 0.2, 'pauseAtEnd'), button_image
            },
            to_state2 = {
                anim8.newAnimation(button_grid(1, '1-12'), 0.2, 'pauseAtEnd'), button_image
            },
        },
        current_animation = "to_state1"
    })
end

local logo, background
local buttons = {}

function MainMenu.resize(w, h)
    local k = h / background.sprite:size()[2]
    background.sprite.scale = k
    background.position.pos[1] = w/2

    logo.sprite.scale = k
    logo.position.pos = Vector2(w/2, h/5)

    buttons.play:CenterX()
    buttons.play:SetY(2*h/5, true)

    buttons.exit:CenterX()
    buttons.exit:SetY(3*h/5, true)
end

function MainMenu.load()
    load_sprites()
    logo = {
        sprite = sprites.logo,
        position = {
            pos = Vector2(),
        }
    }

    background = {
        sprite = sprites.background,
        position = {
            pos = Vector2(),
        }
    }

    world:addEntity(background)
    world:addEntity(logo)

    buttons.play = loveframes.Create("button")
    buttons.play:SetText("Start")
    buttons.play.OnClick = function(obj, x, y)
        CHANGE_LEVEL(LEVELS.forest)
    end

    buttons.exit = loveframes.Create("button")
    buttons.exit:SetText("Exit")
    buttons.exit.OnClick = function(obj, x, y)
        CHANGE_LEVEL("exit")
    end

    window_w, window_h, flags = love.window.getMode()
    MainMenu.resize(window_w, window_h)
end

local effect = love.graphics.newShader([[
    extern number time;
    extern vec4 max;
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords){
        vec4 tex_color = Texel(texture, texture_coords);
        return ( tex_color + (max - tex_color)*sin(time)/4.0 ) * color;
    }
]])

local t = 0
function MainMenu.draw(dt)
    t = t + dt
    effect:send("time", t)
    effect:send("max", {1,0,0,1})
    love.graphics.setShader(effect)
    world:update(dt)
    love.graphics.setShader()
    loveframes.draw()
end

function MainMenu.update(dt)
    loveframes.update(dt)
end

function MainMenu.keypressed(key, scancode, is_repeat)
    if key == "up" then
        background.sprite.scale = background.sprite.scale * 1.1
    end
    if key == "down" then
        background.sprite.scale = background.sprite.scale / 1.1
    end
end

function MainMenu.mousepressed(x, y, button, istouch, presses)
    loveframes.mousepressed(x, y, button)
end

function MainMenu.mousereleased(x, y, button, istouch, presses)
    loveframes.mousereleased(x, y, button)
end


return MainMenu

