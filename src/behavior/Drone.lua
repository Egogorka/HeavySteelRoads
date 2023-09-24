---
--- Created by Meevere.
--- DateTime: 13.09.2023 18:56
---

local Timer = require("utility/timer")
local Compenent = require("src/Component")
local json      = require("libs/json/json")

---@class Drone: Component
---@field shoot_reload_timer Timer
---
---@field direction Vector2 Velocity without wiggle
---@field wiggle_timer Timer
---@field wiggle_amplitude number
---
---@field max_speed number
---@field team CategoriesNames

local Drone = Compenent:extend("Drone")

function Drone.json_decode(str)
    local raw = json.decode(str)
    fill_table(raw, {
        shoot_reload_timer = Timer(0.5),
    
        direction = Vector2(0, 0),
        wiggle_timer = Timer(1),
        wiggle_amplitude = 10,
    
        max_speed = 60,
    
        team = "enemy"
    })
    return raw
end

return Drone