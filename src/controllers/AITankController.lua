---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Meevere.
--- DateTime: 08.03.2023 12:12
---

local Vector2 = require("utility/vector")[1]
local Stack = require("utility/stack")
local class = require("libs/30log")

local CategoryManager = require("src/physics/CategoryManager")

local AITank = tiny.processingSystem(class("AITank"))
AITank.filter = tiny.requireAll("tank", "ai")

local Timer = require("utility/timer")

function AITank:init()
    self.target = nil
end

function AITank:onAdd(entity)
    fill_table(entity.ai, {
        messages = Stack(),
        stack = Stack(),
    })

    self:init_shoot(entity)
    self:init_ram(entity)
end

function AITank:process(entity, dt)
    local ai = entity.ai

    --- Messages
    while ai.messages:size() ~= 0 do
        local message = entity.ai.messages:pop()
        local command = message[1]

        if self[command] then
            self[command](self, entity, dt, message[2])
        end
    end

    --- Stack-machine stuff
    if ai.stack:size() == 0 then
        ai.stack:push("idle")
    end

    local state = ai.stack:pop()
    self[state](self, entity, dt)
end

-----------------------------------------
--- Idle state
-----------------------------------------

function AITank:idle(entity, dt)
    local ai = entity.ai

    -- Handle state

    entity.tank.messages:push({"move", Vector2({-0.3, 0})})


    -- State out branches

    if ai.in_ram_range and not entity.tank.ram_reload_timer.is_on then
        ai.ram_pos = Vector2(ai.target.body:getPosition()) -- State start code
        entity.tank.messages:push({"ram", entity.ai.ram_pos})
        ai.stack:push("ram")
        return
    end

    if ai.in_shoot_range then
        ai.stare_timer:start() -- State start code
        ai.target_pos = Vector2(ai.target.body:getPosition())
        ai.stack:push("action")
        return
    end

    ai.stack:push("idle") -- refill idle state

    -- Action if no state change
    entity.tank.messages:push({"aim", Vector2(entity.body:getPosition()) + {-10, 0}})

end

-----------------------------------------
--- Ram state
-----------------------------------------

function AITank:init_ram(entity)
    local ram_box = {}

    ram_box.shape = love.physics.newRectangleShape(50/2, 20/2, 100, 20)
    ram_box.fixture = love.physics.newFixture(entity.body, ram_box.shape)
    ram_box.fixture:setSensor(true)
    ram_box.fixture:setUserData({
        entity = entity,
        caller = "ai",
        name = "ram_box"
    })
    CategoryManager.setObject(ram_box.fixture, entity.tank.team)

    fill_table(entity.ai, {
        in_ram_range = false,
        ram_box = ram_box,
    })
end

function AITank:ram(entity, dt)
    -- Needs to be fixed
    if entity.tank.ram_timer.is_on or entity.tank.ram_pre_timer.is_on then
        entity.ai.stack:push("ram")
    end
end

-----------------------------------------
--- Action state (shooting, going around the player to go left)
-----------------------------------------

function AITank:init_shoot(entity)
    local shoot_box = {}

    shoot_box.shape = love.physics.newRectangleShape(50/2, 20/2, 400, 400)
    shoot_box.fixture = love.physics.newFixture(entity.body, shoot_box.shape)
    shoot_box.fixture:setSensor(true)
    shoot_box.fixture:setUserData({
        entity = entity,
        caller = "ai",
        name = "shoot_box"
    })
    CategoryManager.setObject(shoot_box.fixture, entity.tank.team)

    local stare_timer = Timer(1)
    stare_timer.on_end = function(timer)
        entity.tank.messages:push({"shoot"})
    end

    fill_table(entity.ai, {
        shoot_box = shoot_box,

        target = self.target,
        target_pos = nil,

        in_shoot_range = false,
        stare_timer = stare_timer
    })
end

function AITank:action(entity, dt)
    local ai = entity.ai
    local tank = entity.tank

    tank.messages:push({"aim", ai.target_pos})
    if not ai.stare_timer.is_on then
        ai.stare_timer:start()
    end
    if not ai.target.body:isDestroyed() then
        ai.target_pos = Vector2(ai.target.body:getPosition())
    end
    ai.stare_timer:update(dt)

    local d = ai.target_pos - {entity.body:getPosition()}

    if math.abs(d:y()) < 40 then
        local dir = 0.3
        if d:y() < 0 then dir = -dir end
        entity.tank.messages:push({"move", {0, -dir}})
    else
        entity.tank.messages:push({"move", {-0.3, 0}})
    end

    -- This one is bad in some sense
    -- I need to avoid duplication and writing state class code
    if ai.in_shoot_range and not (ai.in_ram_range and not entity.tank.ram_reload_timer.is_on) then
        ai.stack:push("action")
    end
end

-----------------------------------------
--- Contact handlers
-----------------------------------------

function AITank:contact(entity, dt, data)
    local other = data[2]
    local this = data[1]

    if this.name == "shoot_box" then
        if other.entity == entity.ai.target then
            entity.ai.in_shoot_range = true
        end
    end

    if this.name == "ram_box" then
        if other.entity == entity.ai.target then
            entity.ai.in_ram_range = true
        end
    end
end

function AITank:endContact(entity, dt, data)
    local other = data[2]
    local this = data[1]

    if this.name == "shoot_box" then
        if other.entity == entity.ai.target then
            entity.ai.in_shoot_range = false
        end
    end

    if this.name == "ram_box" then
        if other.entity == entity.ai.target then
            entity.ai.in_ram_range = false
        end
    end
end


return AITank

