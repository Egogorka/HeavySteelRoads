---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Meevere.
--- DateTime: 16.10.2022 12:20
---

local Camera = require("libs/Camera")
local anim8 = require("libs/anim8")
local tiny = require("libs/tiny")

local Vector2, Vector3 = unpack(require('utility/vector'))


local Sprite, MSprite, Depth, Placement = unpack(require('src/Sprite'))
local SpriteSystem = require("src/SpriteSystem")

local PlayerControlSystem = require("src/PlayerSystem")

local world = tiny.world()
world:addSystem(PlayerControlSystem)
world:addSystem(SpriteSystem)

local window_w, window_h, flags = love.window.getMode()

local body_image = love.graphics.newImage("assets/player/TankBody.png")
local body_grid = anim8.newGrid(47, 20, body_image:getWidth(), body_image:getHeight(), -4, -4, 4)
local body_sprite = Sprite({
    animations = {
        idle = {
            anim8.newAnimation(body_grid(1, 1), 1), body_image
        },
        move = {
            anim8.newAnimation(body_grid(1, '1-4'), 0.2), body_image
        }
    },
    current_animation = "idle"
})

local tower_image = love.graphics.newImage("assets/player/TankTower.png")
local tower_grid  = anim8.newGrid(51, 29, tower_image:getWidth(), tower_image:getHeight())
local tower_sprite = Sprite({
    animations = {
        right = {
            anim8.newAnimation(tower_grid(1,1), 1), tower_image
        },
        right_up = {
            anim8.newAnimation(tower_grid(1,2), 1), tower_image
        },
        up = {
            anim8.newAnimation(tower_grid(1,3), 1), tower_image
        },
        left_up = {
            anim8.newAnimation(tower_grid(1,4), 1), tower_image
        },
        left = {
            anim8.newAnimation(tower_grid(1,5), 1), tower_image
        },
        left_down = {
            anim8.newAnimation(tower_grid(1,6), 1), tower_image
        },
        down = {
            anim8.newAnimation(tower_grid(1,7), 1), tower_image
        },
        right_down = {
            anim8.newAnimation(tower_grid(1,8), 1), tower_image
        }
    },
    current_animation = "right"
})

function love.load()
    camera = Camera()
    camera:setDeadzone(camera.w/2 - 80, 0, 80, camera.h)
    camera.scale = 1.5

    -- Initialize physics world
    love.physics.setMeter(64)
    p_world = love.physics.newWorld(0,0,true)

    local sky = {
        sprite = Sprite(love.graphics.newImage("assets/background/Sky.png"), 1, false),
        body = love.physics.newBody(p_world, 0, 0),
        depth = Depth(1, false)
    }
    world:addEntity(sky)

    local sun = {
        sprite = Sprite(love.graphics.newImage("assets/background/Sun.png"), 1, false),
        body = love.physics.newBody(p_world, 0, 0),
        depth = Depth(1, false)
    }
    world:addEntity(sun)

    local road = {
        sprite = Sprite(love.graphics.newImage("assets/background/Road1.png")),
        body = love.physics.newBody(p_world, 0, window_h/2)
    }
    world:addEntity(road)

    local forest_back2 = {
        sprite = Sprite(love.graphics.newImage("assets/background/Forest4.png")),
        body = love.physics.newBody(p_world, -10, window_h/2 - 86 - 20 - 20),
        depth = Depth(1.4, false)
    }
    world:addEntity(forest_back2)

    local forest_back1 = {
        sprite = Sprite(love.graphics.newImage("assets/background/Forest4.png")),
        body = love.physics.newBody(p_world, 0, window_h/2 - 86 - 20),
        depth = Depth(1.2, false)
    }
    world:addEntity(forest_back1)

    local forest_front = {
        sprite = Sprite(love.graphics.newImage("assets/background/Forest.png")),
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
        msprite = MSprite({
            body = {
                sprite = body_sprite,
                placement = Placement(Vector2(), 1)
            },
            tower = {
                sprite = tower_sprite,
                placement = Placement(Vector2(-5,-15), 2)
            },
        }),
        player = 1,
        depth = Depth(1)
    }

    player.body = love.physics.newBody(p_world, 100, 100, "dynamic")
    player.shape = love.physics.newRectangleShape(50,50)
    player.fixture = love.physics.newFixture(player.body, player.shape)

    world:addEntity(player)
    --SpriteSystem.focus_entity = player
end

function love.update(dt)
    p_world:update(dt)

    camera:update(dt)
    SpriteSystem.focus_pos = Vector2(camera.x,camera.y)
    camera:follow(player.body:getX(), player.body:getY())
end

function love.draw()
    local dt = love.timer.getDelta()
    camera:attach()
    world:update(dt)
    camera:detach()
end

