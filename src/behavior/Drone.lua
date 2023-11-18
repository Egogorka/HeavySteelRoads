---
--- Created by Meevere.
--- DateTime: 13.09.2023 18:56
---

local Stack = require("utility/stack")
local Timer = require("utility/timer")
local CategoryManager = require("src/physics/CategoryManager")

---@class Drone: Behavior
---@field shoot_reload_timer Timer
---
---@field direction Vector2 Velocity without wiggle
---@field wiggle_timer Timer
---@field wiggle_amplitude number
---
---@field max_speed number
---@field team CategoriesNames

local function DroneFactory(raw, loader, entity)
    --- Variables that are present in json and have user type
    raw.shoot_reload_timer = Timer(raw.shoot_reload_timer)
    raw.wiggle_timer = Timer(raw.wiggle_timer, nil, true)

    --- Variables that are technical/unnecessary for json
    if raw.direction then
        raw.direction = Vector2(raw.direction[0], raw.direction[1])
    else
        raw.direction = Vector2(0,0)
    end

    raw.team = "enemy"
    CategoryManager.setObject(entity.fixture, raw.team)
    entity.fixture:setSensor(true)
    return raw
end

return DroneFactory