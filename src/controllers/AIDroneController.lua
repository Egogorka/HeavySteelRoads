local Stack = require("utility/stack")
local Timer = require("utility/timer")

local UserData = require("src/physics/UserData")

local StateMachine = require("src/controllers/StateMachine")
local CategoryManager = require("src/physics/CategoryManager")
local DetectorBox = require("src/controllers/DetectorBox")

local AIDrone = TINY.processingSystem(StateMachine:extend("AIDrone"))
AIDrone.filter = TINY.requireAll("drone", "ai")

function AIDrone:init()
    self.target = nil
end

function AIDrone:onAdd(entity)
    AIDrone.super.onAdd(self, entity)

    fill_table(entity.ai, {
        target = self.target,
        target_pos = nil,
    })

    DetectorBox.init(entity, {50/2, 50/2}, {400, 400}, "shoot_box")
end

-----------------------------------------
--- Idle state
-----------------------------------------

function AIDrone:idle(entity, dt)
    local ai = entity.ai

    -- Handle state

    entity.drone.messages:push({ "move", Vector2({ -1, 0 }) })

    -- State out branches

    if ai.in_avoid_box then
        ai.target_pos = Vector2(ai.target.body:getPosition())
        ai.states:push("action")
        return
    end

    ai.states:push("idle") -- refill idle state
end

-----------------------------------------
--- Action state
-----------------------------------------

function AIDrone:action(entity, dt)
    
end


return AIDrone
