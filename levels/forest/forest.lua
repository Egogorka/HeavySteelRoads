---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Meevere.
--- DateTime: 16.10.2022 17:40
---

local anim8 = require("libs/anim8")
local tiny = require("libs/tiny")
local dump = require("utility/dump")
local flux = require("libs/flux")
local UserData = require("src/physics/UserData")


local Vector2, Vector3 = unpack(require('utility/vector'))
local Timer = require("utility/timer")

local window_w, window_h, flags = love.window.getMode()

local Sprite, MSprite, Depth, Placement = unpack(require('src/graphics/Sprite'))
local CategoryManager = require("src/physics/CategoryManager")
local PhysicsManager = require("src/physics/PhysicsManager")

local SpriteSystem = require("src/graphics/SpriteSystem")()
local ShapeDebug = require("src/ShapeDebug")
local HealthSystem = require("src/HealthSystem")

local TankBehavior = require("src/behavior/TankBehavior")
local BulletBehavior = require("src/behavior/BulletBehavior")
local TruckBehavior = require("src/behavior/TruckBehavior")
local PickupBehavior = require("src/behavior/PickupBehavior")

local PlayerController = require("src/controllers/PlayerController")
local AITank = require("src/controllers/AITankController")()
local AITruck = require("src/controllers/AITruckController")()

local Scene = require("src/scene/Scene")
local ForestLevel = Scene()

local HPBar = require("src/gui/HP_Bar")

local world = tiny.world()
world:addSystem(SpriteSystem)
world:addSystem(ShapeDebug)
world:addSystem(HealthSystem)

world:addSystem(TankBehavior)
world:addSystem(BulletBehavior)
world:addSystem(TruckBehavior)
world:addSystem(PickupBehavior)

world:addSystem(PlayerController)
world:addSystem(AITank)
world:addSystem(AITruck)

local player
local p_world = love.physics.newWorld(0, 0, true)

local gui = {}

local function load_sprites()
    GraphicsLoader:loadSprites("assets/background/", true)
    GraphicsLoader:loadSprites("assets/objects/", true)

    GraphicsLoader:loadAnimations("assets/player/", true)
    GraphicsLoader:loadMSprites("assets/player/", true)

    GraphicsLoader:loadAnimations("assets/entities/enemies/", true)
    GraphicsLoader:loadAnimations("assets/effects/", true)

    gui.stats_tab = love.graphics.newImage("assets/gui/PanelInterfaceNew2.png")

    HPBar.load()
    gui.hp_bar = HPBar(40, 100)
end

local background = {}
local road_height = 0

local sprites = GraphicsLoader.sprites
local animations = GraphicsLoader.animations
local msprites = GraphicsLoader.msprites

local cameraTarget
local cameraLeftBlock
local cameraRightBlock

local roadTopBlock
local roadBottomBlock

local function load_level()
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
    -- Trees
    for i = 0, 10 do
        local forest_back3 = { sprite = sprites.forest_back2, depth = Depth(1.3, false) }
        local x = -20 + i * sprites.forest_front:size()[1] * 1.3
        local y = -sprites.forest_front:size()[2] - 80
        forest_back3.body = love.physics.newBody(p_world, x, y, "kinematic")
        world:addEntity(forest_back3)
        table.insert(background, forest_back3)
    end

    -- for i=0,10 do
    --    local forest_back2 = { sprite = sprites.forest_front, depth = Depth(1.4, false) }
    --    local x = -10 + i * sprites.forest_front:size()[1]*1.4
    --    local y = - sprites.forest_front:size()[2] - 40*2
    --    forest_back2.body = love.physics.newBody(p_world, x, y, "kinematic")
    --    world:addEntity(forest_back2)
    --    table.insert(background, forest_back2)
    -- end
    
    for i = 0, 10 do
        local forest_back1 = { sprite = sprites.forest_front, depth = Depth(1.2, false) }
        local x = 0 + i * sprites.forest_front:size()[1] * 1.2
        local y = -sprites.forest_front:size()[2] - 40
        forest_back1.body = love.physics.newBody(p_world, x, y, "kinematic")
        world:addEntity(forest_back1)
        table.insert(background, forest_back1)
    end

    for i = 0, 10 do
        local forest_front = { sprite = sprites.forest_back }
        local x = 0 + i * sprites.forest_back:size()[1]
        local y = -sprites.forest_back:size()[2]
        forest_front.body = love.physics.newBody(p_world, x, y, "kinematic")
        world:addEntity(forest_front)
        table.insert(background, forest_front)
    end

    -- Road Entities
    for i = 0, 10 do
        local road = { sprite = sprites.road }
        road.body = love.physics.newBody(p_world, i * road.sprite:size()[1], 0, "kinematic")
        world:addEntity(road)
        table.insert(background, road)
    end

    roadTopBlock = {
        body = love.physics.newBody(p_world, window_w / 2, -10 / 2),
        shape = love.physics.newRectangleShape(window_w, 10)
    }
    roadTopBlock.fixture = love.physics.newFixture(roadTopBlock.body, roadTopBlock.shape)
    roadTopBlock.fixture:setUserData(UserData(roadTopBlock))
    CategoryManager.setWall(roadTopBlock.fixture, "neutral")
    world:addEntity(roadTopBlock)

    roadBottomBlock = {
        body = love.physics.newBody(p_world, window_w / 2, sprites.road:size()[2] + 10 / 2),
        shape = love.physics.newRectangleShape(window_w, 10)
    }
    roadBottomBlock.fixture = love.physics.newFixture(roadBottomBlock.body, roadBottomBlock.shape)
    roadBottomBlock.fixture:setUserData(UserData(roadBottomBlock))
    CategoryManager.setWall(roadBottomBlock.fixture, "neutral")
    world:addEntity(roadBottomBlock)

    player = PrefabsLoader:fabricate("tanks.player_tank")
    player.body:setPosition(100, sprites.road:size()[2] / 2)
    player.player = 1
    player.tank.team = "player"
    world:addEntity(player)

    cameraTarget = {
        body = love.physics.newBody(p_world, window_w / 2, 0, "kinematic")
    }

    cameraLeftBlock = {
        body = love.physics.newBody(p_world, 0, 0, "kinematic"),
        shape = love.physics.newRectangleShape(20, window_h)
    }
    -- cameraLeftBlock.body:setFixedRotation(true)
    cameraLeftBlock.fixture = love.physics.newFixture(cameraLeftBlock.body, cameraLeftBlock.shape)
    cameraLeftBlock.fixture:setUserData(UserData(cameraLeftBlock))
    CategoryManager.setWall(cameraLeftBlock.fixture, "enemy")
    world:addEntity(cameraLeftBlock)

    cameraRightBlock = {
        body = love.physics.newBody(p_world, window_w / 2, 0, "kinematic"),
        shape = love.physics.newRectangleShape(20, window_h)
    }
    -- cameraRightBlock.body:setFixedRotation(true)
    cameraRightBlock.fixture = love.physics.newFixture(cameraRightBlock.body, cameraRightBlock.shape)
    cameraRightBlock.fixture:setUserData(UserData(cameraRightBlock))
    CategoryManager.setWall(cameraRightBlock.fixture, "enemy")
    world:addEntity(cameraRightBlock)
    
    AITank.target = player
    AITruck.target = player
end

local enemies = {}

local function enemy_spawn()
    local type = math.random(0, 1)
    local enemy;
    if type == 0 then
        enemy = PrefabsLoader:fabricate("tanks.player_tank")
    else
        enemy = PrefabsLoader:fabricate("tanks.truck")
        enemy.sprite:flipH()
        local contents_amount = math.random(1, 2)
        for i = 1, contents_amount do
            table.insert(enemy.truck.contents, PrefabsLoader:fabricate("pickups.hp_up"))
        end
    end

    local x, y = enemy.body:getPosition()
    local top_left_x, top_left_y, bottom_right_x, bottom_right_y = enemy.shape:computeAABB(0, 0, 0)

    local top_dist = top_left_y - y
    local bottom_dist = bottom_right_y - y

    local posY = (0 - top_dist) + (road_height - bottom_dist - 0 + top_dist) * math.random()

    enemy.body:setPosition(camera.from.pos[1] + camera.from.size[1], posY)
    enemy.ai = {}
    table.insert(enemies, enemy)
    world:addEntity(enemy)
    return enemy
end

local enemy_timer = Timer(10, function(timer)
    for k, enemy in pairs(enemies) do
        if enemy.body:isDestroyed() then
            enemies[k] = nil
            goto continue
        end
        do
            local x, y = enemy.body:getPosition()
            if x < -50 then
                tiny.removeEntity(world, enemy)
                enemies[k] = nil
            end
        end
        ::continue::
    end

    if #enemies < 5 then
        enemy_spawn()

        local probability = math.random(1, 100)
        if probability > 10 then
            enemy_spawn()
        end
    end
end, true)

function ForestLevel.load()
    load_sprites()
    road_height = sprites.road:size()[2]

    PrefabsLoader:loadPrefabs("prefabs/tanks.json", "tanks")
    PrefabsLoader:loadPrefabs("prefabs/pickups.json", "pickups")

    PrefabsLoader:setPhysicsWorld(p_world)
    PhysicsManager.setCallbacks(p_world)

    load_level()
    enemy_timer:start()

    world:refresh()
    PlayerController:keypressed("right") -- Simulate keypress to wake up tank
    PlayerController:keyreleased("right")

    camera.from.scale = 1
    camera.from.pos = Vector2(0, -camera.from.size[2] / 2 - 100)
    -- camera.viscosity = 1
    camera.inertia = 0.5
end

local targeting = true
local pause = false

function ForestLevel.update(dt)
    if pause then
        return
    end

    enemy_timer:update(dt)
    world:refresh()

    -- for k, v in pairs(background) do
    --     v.body:setLinearVelocity(-50, 0)
    -- end

    -- TODO: inject some kind dependancy of 0.5 to PlayerController.lua:66 (17.08.2023) velocity
    cameraTarget.body:setLinearVelocity(player.tank.max_speed * 0.5, 0)
    cameraLeftBlock.body:setLinearVelocity(player.tank.max_speed * 0.5, 0)
    cameraLeftBlock.body:setPosition(camera.from.pos[1] - 20, camera.from.pos[2])

    cameraRightBlock.body:setLinearVelocity(player.tank.max_speed * 0.5, 0)
    cameraRightBlock.body:setPosition(camera.from.pos[1] + camera.from.size[1] +20, camera.from.pos[2])

    for i,v in ipairs({roadBottomBlock, roadTopBlock}) do
        local x, y = v.body:getPosition()
        v.body:setPosition(camera.from.pos[1] + camera.from.size[1]/2, y)
    end

    p_world:update(dt)

    camera:update(dt)
    SpriteSystem.focus_pos = camera.from.pos + camera.from.origin
    if targeting and not player.body:isDestroyed() then
        camera:follow({ cameraTarget.body:getX(), cameraTarget.body:getY() })
    else
        camera:follow(nil)
    end
end

local function Gui_draw()
    love.graphics.draw(gui.stats_tab, 0, 0, 0, 2, 2)
    --love.graphics.draw(gui.hp_texture, gui.hp, 10, 10, 0, 2, 2)
    gui.hp_bar:setHP(player.health.count)
    gui.hp_bar:draw(10, 10)
end

function ForestLevel.draw(dt)
    flux.update(dt)

    camera:attach()
    world:update(dt)
    camera:draw()
    camera:detach()


    Gui_draw()
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
    if key == "h" then
        local x, y = love.mouse.getPosition()
        print("Screen coordinates", x, y)
        print("World coordinates", camera:toWorldCoords({x,y}))
    end
    if key == "t" then
        targeting = not targeting
    end
    if key == "p" then
        pause = not pause
    end

    if not targeting then
        local dir = Vector2()
        if key == "w" then
            dir = dir + { 0, -10 }
        end
        if key == "s" then
            dir = dir + { 0, 10 }
        end
        if key == "a" then
            dir = dir + { -10, 0 }
        end
        if key == "d" then
            dir = dir + { 10, 0 }
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
