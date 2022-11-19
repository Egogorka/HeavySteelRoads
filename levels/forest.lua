---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Meevere.
--- DateTime: 16.10.2022 17:40
---

local Scene = require("src/SceneManager")

local ForestLevel = Scene()

local anim8 = require("libs/anim8")
local tiny = require("libs/tiny")

local Vector2, Vector3 = unpack(require('utility/vector'))
local window_w, window_h, flags = love.window.getMode()

local Sprite, MSprite, Depth, Placement = unpack(require('src/Sprite'))
local SpriteSystem = require("src/SpriteSystem")
local PlayerControlSystem = require("src/PlayerSystem")
local ShapeSystem = require("src/ShapeDebug")

local world = tiny.world()
world:addSystem(PlayerControlSystem)
world:addSystem(SpriteSystem)
world:addSystem(ShapeSystem)


local player
local p_world = love.physics.newWorld(0,0,true)


local sprites = {}
local animations = {}
local load_sprites = function()

    sprites.sky = Sprite(love.graphics.newImage("assets/background/Sky.png"), 1, false)
    sprites.sun = Sprite(love.graphics.newImage("assets/background/Sun.png"), 1, false)
    sprites.road = Sprite(love.graphics.newImage("assets/background/Road1.png"))
    sprites.forest_front = Sprite(love.graphics.newImage("assets/background/Forest.png"))
    sprites.forest_back = Sprite(love.graphics.newImage("assets/background/Forest4.png"))

    local body_image = love.graphics.newImage("assets/player/TankBody.png")
    local body_grid = anim8.newGrid(47, 20, body_image:getWidth(), body_image:getHeight(), -4, -4, 4)
    animations.body = Sprite({
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
    animations.tower = Sprite({
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

end

ForestLevel.load = function()
    load_sprites()

    local sky = {
        sprite = sprites.sky,
        body = love.physics.newBody(p_world, 0, 0),
        depth = Depth(1, false)
    }
    world:addEntity(sky)

    local sun = {
        sprite = sprites.sun,
        body = love.physics.newBody(p_world, 0, 0),
        depth = Depth(1, false)
    }
    world:addEntity(sun)

    local road = {
        sprite = sprites.road,
        body = love.physics.newBody(p_world, 0, window_h/2)
    }
    world:addEntity(road)
    local roadTopBlock = {
        body = love.physics.newBody(p_world, window_w/2, window_h/2 - 10/2),
        shape = love.physics.newRectangleShape(window_w, 10)
    }
    roadTopBlock.fixture = love.physics.newFixture(roadTopBlock.body, roadTopBlock.shape)
    world:addEntity(roadTopBlock)



    local forest_back2 = {
        sprite = sprites.forest_back,
        body = love.physics.newBody(p_world, -10, window_h/2 - 86 - 20 - 20),
        depth = Depth(1.4, false)
    }
    world:addEntity(forest_back2)

    local forest_back1 = {
        sprite = sprites.forest_back,
        body = love.physics.newBody(p_world, 0, window_h/2 - 86 - 20),
        depth = Depth(1.2, false)
    }
    world:addEntity(forest_back1)

    local forest_front = {
        sprite = sprites.forest_front,
        body = love.physics.newBody(p_world, 0, window_h/2 - 166)
    }
    world:addEntity(forest_front)

    player = {
        msprite = MSprite({
            body = {
                sprite = animations.body,
                placement = Placement(Vector2(), 1)
            },
            tower = {
                sprite = animations.tower,
                placement = Placement(Vector2(-5,-15), 2)
            },
        }),
        player = 1,
        depth = Depth(1)
    }

    player.body = love.physics.newBody(p_world, 100, 100, "dynamic")
    player.body:setFixedRotation(true)
    player.shape = love.physics.newPolygonShape(0,0, 50,0, 50,20, 0,20 )
    player.fixture = love.physics.newFixture(player.body, player.shape)

    world:addEntity(player)
    --SpriteSystem.focus_entity = player
end

ForestLevel.update = function(dt)
    p_world:update(dt)

    camera:update(dt)
    SpriteSystem.focus_pos = Vector2(camera.x,camera.y)
    camera:follow(player.body:getX(), player.body:getY())
end

ForestLevel.draw = function(dt)
    camera:attach()
    world:update(dt)
    camera:detach()
end

return ForestLevel