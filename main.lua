---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Meevere.
--- DateTime: 16.10.2022 12:20
---

local Camera = require("libs/Camera")
local anim8 = require("libs/anim8")
local tiny = require("libs/tiny")

local Graphics, Depth = unpack(require('src/Graphics'))
local GraphicsSystem = require("src/GraphicsSystem")

local PlayerControlSystem = require("src/PlayerSystem")

local world = tiny.world()
world:addSystem(PlayerControlSystem)
world:addSystem(GraphicsSystem)

local window_w, window_h, flags = love.window.getMode()


local image = love.graphics.newImage("assets/player/TankBody.png")
local grid = anim8.newGrid(47, 20, image:getWidth(), image:getHeight(), -4, -4, 4)
local entity_graphics = Graphics({
    animations = {
        idle = {
            anim8.newAnimation(grid(1,1), 1), image
        },
        move = {
            anim8.newAnimation(grid(1,'1-4'), 0.2), image
        }
    },
    current_animation = "idle"
})

function love.load()
    camera = Camera()
    camera:setDeadzone(camera.w/2 - 80, 0, 80, camera.h)
    camera.scale = 1.5

    -- Initialize physics world
    love.physics.setMeter(64)
    p_world = love.physics.newWorld(0,0,true)

    local road = {
        graphics = Graphics(love.graphics.newImage("assets/background/Road1.png")),
        body = love.physics.newBody(p_world, 0, window_h/2)
    }
    world:addEntity(road)

    local forest_back2 = {
        graphics = Graphics(love.graphics.newImage("assets/background/Forest4.png")),
        body = love.physics.newBody(p_world, -10, window_h/2 - 86 - 20 - 20),
        depth = Depth(1.4, false)
    }
    world:addEntity(forest_back2)

    local forest_back1 = {
        graphics = Graphics(love.graphics.newImage("assets/background/Forest4.png")),
        body = love.physics.newBody(p_world, 0, window_h/2 - 86 - 20),
        depth = Depth(1.2, false)
    }
    world:addEntity(forest_back1)

    local forest_front = {
        graphics = Graphics(love.graphics.newImage("assets/background/Forest.png")),
        body = love.physics.newBody(p_world, 0, window_h/2 - 166)
    }
    world:addEntity(forest_front)

    --local roadTopBlock = {
    --    body = love.physics.newBody(p_world, window_w/2, window_h/2 - 10/2),
    --    shape = love.physics.newRectangleShape(window_w, 10)
    --}
    --roadTopBlock.fixture = love.physics.newFixture(roadTopBlock.body, roadTopBlock.shape)
    --world:addEntity(roadTopBlock)

    player = {
        graphics = entity_graphics,
        player = 1,
        depth = Depth(1)
    }

    player.body = love.physics.newBody(p_world, 100, 100, "dynamic")
    player.shape = love.physics.newRectangleShape(50,50)
    player.fixture = love.physics.newFixture(player.body, player.shape)

    world:addEntity(player)
    GraphicsSystem.focus_entity = player
end

function love.update(dt)
    p_world:update(dt)

    camera:update(dt)
    camera:follow(player.body:getX(), player.body:getY())
end

function love.draw()
    local dt = love.timer.getDelta()
    camera:attach()
    world:update(dt)
    camera:detach()
end

