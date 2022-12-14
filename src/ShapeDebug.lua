---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Meevere.
--- DateTime: 20.11.2022 1:08
---

local tiny = require("libs/tiny")
local Vector2 = require("utility/vector")[1]
local dump = require("utility/dump")

local ShapeSystem = tiny.processingSystem()
ShapeSystem.filter = tiny.requireAll("shape", "body")

function ShapeSystem:process(entity, dt)
    local x1, y1, x2, y2, x3, y3, x4, y4 = entity.shape:getPoints()
    local pos  = Vector2(entity.body:getPosition())

    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor({1,0,0})
    love.graphics.rectangle("line", pos[1] + x2, pos[2] + y2, x4 - x2, y4 - y2)
    love.graphics.setColor(r, g, b, a)
end

return ShapeSystem