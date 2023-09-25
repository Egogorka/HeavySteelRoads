---
--- Created by Meevere.
--- DateTime: 10.02.2023 18:31
---

local Timer = require("utility/timer")
local CategoryManager = require("src/physics/CategoryManager")
local Effects         = require("src/graphics/Effects")

local Behavior = require("src/behavior/Behavior")
local DroneBehavior = TINY.processingSystem(Behavior:extend("DroneBehavior"))
DroneBehavior.filter = TINY.requireAll("drone", "body", "fixture", "sprite")

--- @alias drone_entity {fixture: love.Fixture, body: love.Body, drone: Drone, sprite: Sprite}

--- @param entity {fixture: love.Fixture, body: love.Body, drone: Drone, sprite: Sprite}
function DroneBehavior:onAdd(entity)
    DroneBehavior.super.onAdd(self, entity)
    fill_table(entity.drone, {
        shoot_reload_timer = Timer(0.5),

        direction = Vector2(0,0),
        wiggle_timer = Timer(1, nil, true),
        wiggle_amplitude = 10,

        max_speed = 60,

        team = "enemy"
    })

    entity.drone.wiggle_timer:start()
    CategoryManager.setObject(entity.fixture, entity.drone.team)
    entity.fixture:setSensor(true)
end

---
---@param entity drone_entity
---@param dt number
function DroneBehavior:process(entity, dt)
    entity.drone.shoot_reload_timer:update(dt)
    entity.drone.wiggle_timer:update(dt)

    --- Process messages
    DroneBehavior.super.process(self, entity, dt)

    --- Wiggle processing (because it's always there)
    local wiggle_amplitude = entity.drone.wiggle_amplitude
    local direction = entity.drone.direction
    local wiggle = direction:perp()
    wiggle = wiggle * math.sin(2 * math.pi * entity.drone.wiggle_timer.time)

    local vel = wiggle * wiggle_amplitude + direction * entity.drone.max_speed
    entity.body:setLinearVelocity(vel:x(), vel:y())
end


---Command to move drone in certain direction
---@param entity drone_entity 
---@param dt number
---@param v Vector2 length must be < 1 (otherwise would be trimmed)
function DroneBehavior:move(entity, dt, v)
    if v:magsqr() > 1 then
        v = v / v:mag()
    end
    local velocity = v * entity.drone.max_speed

    -- select sprite
    if math.abs(v:x()) < 0.1 then
        entity.sprite:set("front")
    else
        entity.sprite:set("left")
    end

    if v:x() < 0 and entity.sprite.is_flippedH then
        entity.sprite:flipH()
    end
    if v:x() > 0 and not entity.sprite.is_flippedH then
        entity.sprite:flipH()
    end

    entity.drone.direction = v;
end

---@param entity drone_entity
---@param dt number
function DroneBehavior:hurt(entity, dt)
    if entity.sprite.effect == nil then
        entity.sprite.effect = Effects.hurt()
    end
end

function DroneBehavior:die(entity, dt)
    local world = self.world
    TINY.removeEntity(world, entity)
end

function DroneBehavior:onRemove(entity)
    entity.body:destroy()
end

function DroneBehavior:contact(entity, dt, data)
    local other = data[2]
    if other.caller ~= nil then return end

    if other.entity.health then
        other.entity.health.change = -5
    end
end

return DroneBehavior
