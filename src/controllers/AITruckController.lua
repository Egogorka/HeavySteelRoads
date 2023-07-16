---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Meevere.
--- DateTime: 09.07.2023 13:34
---

local Vector2 = require("utility/vector")[1]
local Stack = require("utility/stack")
local class = require("libs/30log")

local CategoryManager = require("src/CategoryManager")

local AITruck = tiny.processingSystem(class("AITruck"))
AITruck.filter = tiny.requireAll("truck", "ai")

function AITruck:init()
    self.target = nil
end

function AITruck:onAdd(entity)
    fill_table(entity.ai, {
        messages = Stack(),
        stack = Stack(),
    })

    self:init_avoid_box(entity)
end

function AITruck:process(entity, dt)
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

function AITruck:idle(entity, dt)
    local ai = entity.ai

    -- Handle state

    entity.truck.messages:push({"move", Vector2({-0.15, 0})})

    -- State out branches

    if ai.in_avoid_box then
        ai.target_pos = Vector2(ai.target.body:getPosition())
        ai.stack:push("action")
        return
    end

    ai.stack:push("idle") -- refill idle state
end

-----------------------------------------
--- Action state (shooting, going around the player to go left)
-----------------------------------------

function AITruck:init_avoid_box(entity)
    local avoid_box = {}

    avoid_box.shape = love.physics.newRectangleShape(50/2, 20/2, 400, 400)
    avoid_box.fixture = love.physics.newFixture(entity.body, avoid_box.shape)
    avoid_box.fixture:setSensor(true)
    avoid_box.fixture:setUserData({
        entity = entity,
        caller = "ai",
        name = "avoid_box"
    })
    CategoryManager.setObject(avoid_box.fixture, entity.truck.team)

    fill_table(entity.ai, {
        avoid_box = avoid_box,

        target = self.target,
        target_pos = nil,

        in_avoid_box = false,
    })
end

function AITruck:action(entity, dt)
    local ai = entity.ai
    local truck = entity.truck

    local d = ai.target_pos - {entity.body:getPosition()}

    if math.abs(d:y()) < 40 then
        local dir = 0.3
        if d:y() < 0 then dir = -dir end
        truck.messages:push({"move", {0, -dir}})
    else
        truck.messages:push({"move", {-0.3, 0}})
    end

    if ai.in_avoid_box then
        ai.stack:push("action")
    end
end

-----------------------------------------
--- Contact handlers
-----------------------------------------

function AITruck:contact(entity, dt, data)
    local other = data[2]
    local this = data[1]

    if this.name == "avoid_box" then
        if other.entity == entity.ai.target then
            entity.ai.in_avoid_box = true
        end
    end
end

function AITruck:endContact(entity, dt, data)
    local other = data[2]
    local this = data[1]

    if this.name == "avoid_box" then
        if other.entity == entity.ai.target then
            entity.ai.in_avoid_box = false
        end
    end
end


return AITruck

