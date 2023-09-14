---
--- Created by Meevere.
--- DateTime: 13.09.2023 18:56
---

local Timer = require("utility/timer")
local class = require("libs/30log")

---@class Drone
---@field shoot_reload_timer Timer
---
---@field direction Vector2 Velocity without wiggle
---@field wiggle_timer Timer
---@field wiggle_amplitude number
---
---@field max_speed number
---@field team CategoriesNames

local Drone = class("Drone", {
    shoot_reload_timer = Timer(0.5),

    direction = Vector2(0, 0),
    wiggle_timer = Timer(1),
    wiggle_amplitude = 10,

    max_speed = 60,

    team = "enemy"
})

