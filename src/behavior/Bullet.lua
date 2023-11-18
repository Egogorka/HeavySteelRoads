---
--- Created by Meevere.
--- DateTime: 18.11.2023 17:50
---

local Stack = require("utility/stack")
local CategoryManager = require("src/physics/CategoryManager")
local Timer = require("utility/timer")

---@class Bullet: Behavior
---@field damage number
---@field lifetime Timer
---@field team CategoriesNames

local function BulletFabricate(raw, loader, entity)
    local t = {damage = 10, lifetime = Timer(5)}
    if type(raw) == "table" then
        t.damage = raw.damage
    elseif type(raw) == "number" then
        t.damage = raw
    end
    t.team = "enemy"
    CategoryManager.setObject(entity.fixture, t.team)
    return t
end

return BulletFabricate