---
--- Created by Meevere.
--- DateTime: 10.02.2023 18:31
---

local class = require("libs/30log")
local tiny = require("libs/tiny")
local Timer = require("utility/timer")
local CategoryManager = require("src/physics/CategoryManager")

local Behavior = require("src/behavior/Behavior")
local DroneBehavior = tiny.processingSystem(Behavior:extend("DroneBehavior"))
DroneBehavior.filter = tiny.requireAll("drone", "body", "fixture", "sprite")

---@class Drone
---@field shoot_reload_timer Timer
---@field wiggle_timer Timer
---@field wiggle_amplitude number
---@field max_speed number
---@field team CategoriesNames

--- @alias drone_entity {fixture: love.Fixture, body: love.Body, drone: Drone, sprite: Sprite}

--- @param entity {fixture: love.Fixture, body: love.Body, drone: Drone, sprite: Sprite}
function DroneBehavior:onAdd(entity)
    DroneBehavior.super.onAdd(self, entity)
    fill_table(entity.drone, {
        shoot_reload_timer = Timer(0.5),
        wiggle_timer = Timer(1),
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

    DroneBehavior.super.process(self, entity, dt)
end


---Command to move drone in certain direction
---@param entity drone_entity 
---@param dt number
---@param v Vector2 length must be < 1 (otherwise would be trimmed)
function DroneBehavior:move(entity, dt, v)
    if v:magsqr() > 1 then
        v = v / v:mag()
    end
end