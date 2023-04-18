---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Meevere.
--- DateTime: 16.10.2022 17:40
---

local anim8 = require("libs/anim8")
local tiny = require("libs/tiny")
local dump = require("utility/dump")
local flux = require("libs/flux")


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
world:addSystem(SpriteSystem)
world:addSystem(ShapeDebug)
world:addSystem(HealthSystem)

world:addSystem(TankBehavior)
world:addSystem(BulletBehavior)

world:addSystem(PlayerController)
world:addSystem(AITank)

local player
local p_world = love.physics.newWorld(0,0,true)

local function load_sprites()
    GraphicsLoader:loadSprites("assets/background/", true)
    GraphicsLoader:loadAnimations("assets/player/", true)
    GraphicsLoader:loadAnimations("assets/effects/", true)
    GraphicsLoader:loadMSprites("assets/player/", true)
end

function ForestLevel.load()
    load_sprites()

    PrefabsLoader:loadPrefabs("prefabs/tanks.json", "tanks")

    PrefabsLoader:setPhysicsWorld(p_world)

    local sprites = GraphicsLoader.sprites
    local animations = GraphicsLoader.animations
    local msprites = GraphicsLoader.msprites

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

    player = PrefabsLoader:fabricate("tanks.player_tank")
    player.body:setPosition(300, window_h/2 + sprites.road:size()[2]/2)
    player.player = 1
    player.tank.team = CategoryManager.categories.player
    world:addEntity(player)

    AITank.target = player

    player2 = PrefabsLoader:fabricate("tanks.player_tank")
    player2.body:setPosition(400, window_h/2 + sprites.road:size()[2]/2)
    player2.ai = {}

    player3 = PrefabsLoader:fabricate("tanks.player_tank")
    player3.body:setPosition(450, window_h/2 + sprites.road:size()[2]/4)
    player3.ai = {}

    world:addEntity(player2)
    world:addEntity(player3)
    world:refresh()

    ---
    --- ATM I dont know where to put this code, so i write there
    --- There are two acceptors of contact information - AI and Behaviors.
    --- Thus the standard for fixture userData is:
    --- {
    ---     entity : Entity - contains the link to the parent entity of fixture
    ---     name : nil|string - stands for name of holder of fixture
    ---         (example, name = "shoot_box" , then fixture is in entity.shoot_box.fixture)
    ---     caller : nil|string - contains the name of AI or nil. The contact message is put
    ---     in AI messages stack. And if it's nil, then in Behavior's.
    --- }
    ---
    local function contact(a_fixture, b_fixture, coll, text)
        --if a.action then
        --    a.action(a, b, coll)
        --end
        local a = a_fixture:getUserData()
        local b = b_fixture:getUserData()

        if a.caller then
            if a.entity[a.caller].messages then
                a.entity[a.caller].messages:push({text, {a, b} })
            end
        else
            if a.entity.behavior then
                a.entity[a.entity.behavior].messages:push({text, {a, b} })
            end
        end
    end

    local function beginContact(a, b, coll)
        contact(a, b, coll, "contact")
        contact(b, a, coll, "contact")
    end

    local function endContact(a, b, coll)
        contact(a, b, coll, "endContact")
        contact(b, a, coll, "endContact")
    end

    p_world:setCallbacks(beginContact, endContact)

    camera.from.scale = 0.5
    camera.viscosity = 1
    camera.inertia = 0.5
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