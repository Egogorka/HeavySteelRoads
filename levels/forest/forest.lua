---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Meevere.
--- DateTime: 16.10.2022 17:40
---

local anim8 = require("libs/anim8")
local tiny = require("libs/tiny")
local dump = require("utility/dump")
local flux = require("libs/flux")

local GraphicsLoader = require("loaders/GraphicsLoader")()

local Vector2, Vector3 = unpack(require('utility/vector'))
local window_w, window_h, flags = love.window.getMode()

local Sprite, MSprite, Depth, Placement = unpack(require('src/graphics/Sprite'))
local CategoryManager = require("src/CategoryManager")

local SpriteSystem = require("src/graphics/SpriteSystem")()
local ShapeDebug = require("src/ShapeDebug")
local HealthSystem = require("src/HealthSystem")

local TankBehavior = require("src/behavior/TankBehavior")
local BulletBehavior = require("src/behavior/BulletBehavior")

local PlayerController = require("src/controllers/PlayerController")
local AITank = require("src/controllers/AITankController")()

local Scene = require("src/SceneManager")
local ForestLevel = Scene()


local world = tiny.world()
--world:addSystem(PlayerControlSystem)
world:addSystem(SpriteSystem)
world:addSystem(ShapeDebug)
world:addSystem(HealthSystem)

world:addSystem(TankBehavior)
world:addSystem(BulletBehavior)

world:addSystem(PlayerController)
world:addSystem(AITank)

local player
local p_world = love.physics.newWorld(0,0,true)

local sprites = {}
local animations = {}
local function load_sprites()
    sprites = GraphicsLoader:loadSprites("assets/background/")
    animations = GraphicsLoader:loadAnimations("assets/player/")
end

function ForestLevel.load()
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

        -- Road Entities

        local road = { sprite = sprites.road }
        road.body = love.physics.newBody(p_world, i * road.sprite:size()[1], window_h/2)
        world:addEntity(road)

        local roadTopBlock = {
            body = love.physics.newBody(p_world, window_w/2 + i * road.sprite:size()[1], window_h/2 - 10/2),
            shape = love.physics.newRectangleShape(window_w, 10)
        }
        roadTopBlock.fixture = love.physics.newFixture(roadTopBlock.body, roadTopBlock.shape)
        roadTopBlock.fixture:setUserData({
            entity = roadTopBlock
        })
        world:addEntity(roadTopBlock)

        local roadBottomBlock = {
            body = love.physics.newBody(p_world, window_w/2 + i * road.sprite:size()[1], window_h/2 + road.sprite:size()[2] + 10/2),
            shape = love.physics.newRectangleShape(window_w, 10)
        }
        roadBottomBlock.fixture = love.physics.newFixture(roadBottomBlock.body, roadBottomBlock.shape)
        roadBottomBlock.fixture:setUserData({
            entity = roadBottomBlock
        })
        world:addEntity(roadBottomBlock)


        CategoryManager.setBulletproof(roadTopBlock.fixture)
        CategoryManager.setBulletproof(roadBottomBlock.fixture)

        -- Trees

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
        behavior = "tank",
        tank = {
            aim = nil,
            team = CategoryManager.categories.player
        },
        health = {
            count = 20,
            change = 0
        },
        player = 1,
        depth = Depth(1)
    }

    player.body = love.physics.newBody(p_world, 300, window_h/2 + sprites.road:size()[2]/2, "dynamic")
    player.body:setFixedRotation(true)
    player.shape = love.physics.newRectangleShape(50/2,20/2, 50,20)
    player.fixture = love.physics.newFixture(player.body, player.shape)
    player.fixture:setUserData({
        entity = player
    })
    world:addEntity(player)

    CategoryManager.setObject(player.fixture, CategoryManager.categories.player)

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
        behavior = "tank",
        tank = {
            aim = nil
        },
        health = {
            count = 100,
            change = 0
        },
        depth = Depth(1),

        ai = {}
    }

    player2.body = love.physics.newBody(p_world, 400, window_h/2 + sprites.road:size()[2]/2, "dynamic")
    player2.body:setFixedRotation(true)
    player2.shape = love.physics.newRectangleShape(50/2,20/2, 50,20)
    player2.fixture = love.physics.newFixture(player2.body, player2.shape)
    player2.fixture:setUserData({
        entity = player2
    })

    CategoryManager.setObject(player2.fixture, CategoryManager.categories.enemy)
    do
        local shoot_box = {}

        shoot_box.shape = love.physics.newRectangleShape(50/2, 20/2, 100, 100)
        shoot_box.fixture = love.physics.newFixture(player2.body, shoot_box.shape)
        shoot_box.fixture:setSensor(true)
        shoot_box.fixture:setUserData({
            entity = player2,
            caller = "ai",
            name = "shoot_box"
        })

        CategoryManager.setObject(shoot_box.fixture, CategoryManager.categories.enemy)
        player2.ai.shoot_box = shoot_box
    end

    AITank.target = player

    world:addEntity(player2)
    world:refresh()

    CategoryManager.setObject(player2.fixture, CategoryManager.categories.enemy)

    local function contact(a, b, coll, text)
        --if a.action then
        --    a.action(a, b, coll)
        --end

        if a.caller then
            if a.entity[a.caller].messages then
                a.entity[a.caller].messages:push({text,
                    { entity = b.entity, fixture = a.name }
                })
            end
            --if a.method then
            --    a.caller.method(a, b, coll)
            --end
        else
            if a.entity.behavior then
                a.entity[a.entity.behavior].messages:push({text, b.entity})
            end
        end
    end

    local function beginContact(_a, _b, _coll)
        local a_data = _a:getUserData()
        local b_data = _b:getUserData()

        contact(a_data, b_data, _coll, "contact")
        contact(b_data, a_data, _coll, "contact")
    end

    local function endContact(_a, _b, _coll)
        local a_data = _a:getUserData()
        local b_data = _b:getUserData()

        contact(a_data, b_data, _coll, "endContact")
        contact(b_data, a_data, _coll, "endContact")
    end

    p_world:setCallbacks(beginContact, endContact)

    camera.viscosity = 0.1
end

local targeting = true

function ForestLevel.update(dt)
    world:refresh()
    p_world:update(dt)

    camera:update(dt)
    SpriteSystem.focus_pos = camera.from.pos + camera.from.origin
    if targeting and not player.body:isDestroyed() then
        camera:follow({player.body:getX(), player.body:getY()})
    else
        camera:follow(nil)
    end
end

function ForestLevel.draw(dt)
    flux.update(dt)

    camera:attach()
    world:update(dt)
    camera:detach()

    camera:draw()
end

function ForestLevel.mousepressed(x, y, button, istouch, presses)
    --- Just need to tell my brain that I need to make it at least somehow, not perfect at the start
end

function ForestLevel.keypressed(key, scancode, is_repeat)
    PlayerController:keypressed(key, scancode, is_repeat)
    if key == "z" then
        camera.from.scale = camera.from.scale * 1.1
    end
    if key == "c" then
        camera.from.scale = camera.from.scale / 1.1
    end
    if key == "g" then
        print(dump(camera, 3, 2))
    end
    if key == "t" then
        targeting = not targeting
    end
    if not targeting then
        local dir = Vector2()
        if key == "w" then
            dir = dir + {0, -10}
        end
        if key == "s" then
            dir = dir + {0, 10}
        end
        if key == "a" then
            dir = dir + {-10, 0}
        end
        if key == "d" then
            dir = dir + {10, 0}
        end
        camera.from.pos = camera.from.pos + dir
    else
        if key == "l" then
            camera.lead = camera.lead + 1
        end
        if key == "k" then
            camera.lead = camera.lead - 1
        end
    end
end

function ForestLevel.keyreleased(key, scancode)
    PlayerController:keyreleased(key, scancode)
end

return ForestLevel