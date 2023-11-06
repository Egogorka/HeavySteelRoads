---
--- Created by Meevere.
--- DateTime: 13.09.2023 18:56
---

local Stack = require("utility/stack")
local Timer = require("utility/timer")
local CategoryManager = require("src/physics/CategoryManager")

---@class Tank: Behavior
---@field stack Stack For states
---@field max_speed number
---@field team CategoriesNames
---
---@field shoot_reload_timer Timer
---
---@field aimed boolean
---@field rotation_speed number
---@field rotation_angle number
---@field target_angle number
---
---@field ram_reload_timer Timer
---@field ram_pre_timer Timer
---@field ram_pos Vector2|nil
---@field ram_distance number
---@field ram_velocity number
---@field ram_timer Timer


function TankFabricate(raw, loader, current)
    --- Variables that are present in json and have user type
    raw.max_speed = raw.max_speed
    raw.shoot_reload_timer = Timer(raw.shoot_reload_timer)
    raw.ram_reload_timer = Timer(raw.ram_reload_timer)
    raw.ram_pre_timer = Timer(raw.ram_pre_timer)

    --- Variables that are technical/unnecessary for json
    raw.aimed = false
    raw.rotation_speed = raw.rotation_speed or 1
    raw.rotation_angle = raw.rotation_angle or 0 -- In units of Pi : Right is 0, Down is 1/2
    raw.target_angle = 0

    raw.ram_pos = nil
    raw.ram_timer = Timer(raw.ram_distance/raw.ram_velocity)

    raw.messages = Stack()
    raw.stack = Stack()

    raw.team = "enemy"
    CategoryManager.setObject(current.fixture, raw.team)
    return raw
end

return TankFabricate