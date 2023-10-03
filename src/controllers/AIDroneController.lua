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
    
        shoot_reload_timer = Timer(0.5)
    })
    
    DetectorBox.init(entity, {50/2, 50/2}, {400, 400}, "shoot_box")
end

-----------------------------------------
--- Idle state
-----------------------------------------

function AIDrone:idle(entity, dt)
    local ai = entity.ai

    -- Handle state

    entity.drone.messages:push({ "move", Vector2({ -0.5, 0 }) })

    -- State out branches

    if ai.in_shoot_box then
        ai.target_pos = Vector2(ai.target.body:getPosition())
        ai.states:push("action")
        return
    end

    ai.states:push("idle") -- refill idle state
end

-----------------------------------------
--- Action state
-----------------------------------------

---@param entity {ai: any, body: love.Body, drone: Drone}
---@param dt any
function AIDrone:action(entity, dt)
    local ai = entity.ai
    
    local target = Vector2(ai.target.body:getPosition())
    local pos = Vector2(entity.body:getPosition())
    local direction = entity.drone.direction

    local dist = target - pos

    -- if dist[1] > 0 then -- Drone is to the left of the target
    --     direction = direction + Vector2(5*dt,0)
    -- else
    --     direction = direction + Vector2(5*dt,0)
    -- end
    local function cap(a)
        if a > 1 then
            return 1
        end
        if a < -1 then
            return -1
        end
        return a
    end

    direction = direction + Vector2(5*dt*cap(dist[1]/50), 0)
    entity.drone.messages:push({"move", direction})

    -- State out branches

    if ai.in_shoot_box then
        ai.target_pos = Vector2(ai.target.body:getPosition())
        ai.states:push("action")
        return
    else
        ai.states:push("idle")
    end
end

-----------------------------------------
--- Contact handlers
-----------------------------------------

function AIDrone:contact(entity, dt, data)
    DetectorBox.onContact(entity, data, entity.ai.target, "shoot_box")
end

function AIDrone:endContact(entity, dt, data)
    DetectorBox.onEndContact(entity, data, entity.ai.target, "shoot_box")
end

return AIDrone
