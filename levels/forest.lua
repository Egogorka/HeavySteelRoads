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
--local PlayerControlSystem = require("src/PlayerSystem")
local ShapeSystem = require("src/ShapeDebug")

local TankBehavior = require("src/behavior/TankBehavior")
local PlayerController = require("src/controllers/PlayerController")

local world = tiny.world()
--world:addSystem(PlayerControlSystem)
world:addSystem(SpriteSystem)
world:addSystem(ShapeSystem)
world:addSystem(TankBehavior)
world:addSystem(PlayerController)

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

    -- Back-Background --
    local sky1 = {
        sprite = sprites.sky,
        body = love.physics.newBody(p_world, 0, 0),
        depth = Depth(1, false)
    }
    world:addEntity(sky1)
    local sky2 = {
        sprite = sprites.sky,
        body = love.physics.newBody(p_world, sprites.sky:size()[1], 0),
        depth = Depth(1, false)
    }
    world:addEntity(sky2)


    local sun = {
        sprite = sprites.sun,
        body = love.physics.newBody(p_world, 0, 0),
        depth = Depth(1, false)
    }
    world:addEntity(sun)

    -- Background --
    for i=0,10 do

        local road = { sprite = sprites.road }
        road.body = love.physics.newBody(p_world, i * road.sprite:size()[1], window_h/2)

        world:addEntity(road)
        local roadTopBlock = {
            body = love.physics.newBody(p_world, window_w/2 + i * road.sprite:size()[1], window_h/2 - 10/2),
            shape = love.physics.newRectangleShape(window_w, 10)
        }
        roadTopBlock.fixture = love.physics.newFixture(roadTopBlock.body, roadTopBlock.shape)
        world:addEntity(roadTopBlock)
        local roadBottomBlock = {
            body = love.physics.newBody(p_world, window_w/2 + i * road.sprite:size()[1], window_h/2 + road.sprite:size()[2] + 10/2),
            shape = love.physics.newRectangleShape(window_w, 10)
        }
        roadBottomBlock.fixture = love.physics.newFixture(roadBottomBlock.body, roadBottomBlock.shape)
        world:addEntity(roadBottomBlock)


        local forest_back2 = { sprite = sprites.forest_back, depth = Depth(1.4, false) }
        forest_back2.body = love.physics.newBody(p_world, -10 + i * sprites.forest_back:size()[1]*1.4, window_h/2 - 86 - 20 - 20),
        world:addEntity(forest_back2)

        local forest_back1 = { sprite = sprites.forest_back, depth = Depth(1.2, false) }
        forest_back1.body = love.physics.newBody(p_world, 0 + i * sprites.forest_back:size()[1]*1.2, window_h/2 - 86 - 20)
        world:addEntity(forest_back1)

        local forest_front = { sprite = sprites.forest_front, }
        forest_front.body = love.physics.newBody(p_world, 0 + i * sprites.forest_front:size()[1], window_h/2 - 166)
        world:addEntity(forest_front)
    end

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
        tank = {
            aim = nil
        },
        player = 1,
        depth = Depth(1)
    }

    player.body = love.physics.newBody(p_world, 300, window_h/2 + sprites.road:size()[2]/2, "dynamic")
    player.body:setFixedRotation(true)
    player.shape = love.physics.newRectangleShape(50/2,20/2, 50,20)
    player.fixture = love.physics.newFixture(player.body, player.shape)
    world:addEntity(player)

    local player2 = {
        msprite = MSprite({
            body = {
                sprite = animations.body:clone(),
                placement = Placement(Vector2(), 1)
            },
            tower = {
                sprite = animations.tower:clone(),
                placement = Placement(Vector2(-5,-15), 2)
            },
        }),
        tank = {
            aim = nil
        },
        depth = Depth(1)
    }

    player2.body = love.physics.newBody(p_world, 400, window_h/2 + sprites.road:size()[2]/2, "dynamic")
    player2.body:setFixedRotation(true)
    player2.shape = love.physics.newRectangleShape(50/2,20/2, 50,20)
    player2.fixture = love.physics.newFixture(player.body, player.shape)
    world:addEntity(player2)

    --SpriteSystem.focus_entity = player
end

ForestLevel.update = function(dt)
    p_world:update(dt)

    camera:update(dt)
    SpriteSystem.focus_pos = Vector2(camera.x,camera.y)
    camera:follow(player.body:getX(), 40)
end

ForestLevel.draw = function(dt)
    camera:attach()
    world:update(dt)
    camera:detach()
end

ForestLevel.mousepressed = function(x, y, button, istouch, presses)
    --- Just need to tell my brain that I need to make it at least somehow, not perfect at the start


end

function ForestLevel.keypressed(key, scancode, is_repeat)
    PlayerController:keypressed(key, scancode, is_repeat)
end

function ForestLevel.keyreleased(key, scancode)
    PlayerController:keyreleased(key, scancode)
end

return ForestLevel