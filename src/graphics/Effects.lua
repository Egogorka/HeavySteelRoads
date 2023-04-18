---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Meevere.
--- DateTime: 02.03.2023 0:03
---

local class = require("libs/30log")
local flux = require("libs/flux")

-- Effect is a class that does some 'effect' on a sprite, like hurt animation

local Effect = class("Effect", {
    is_done = false,
    beforeDraw = function(self, sprite) end,
    afterDraw = function(self, sprite)  end
})

local HurtEffect = Effect:extend("HurtEffect")
local RamEffect = Effect:extend("RamEffect")

-----------------------------------------------------------
--- Hurt Effect
-----------------------------------------------------------

function HurtEffect:init(sprite)
    self.hurt_color = 1
    flux.to(self, 0.1, { hurt_color = 0.2 })
        :ease("elasticout")
        :after(self, 0.1, { hurt_color = 1 })
        :oncomplete(function()
        self.is_done = true
    end)
end

function HurtEffect:beforeDraw(sprite)
    self.color = {love.graphics.getColor()}
    love.graphics.setColor(1, self.hurt_color, self.hurt_color, 1)
end

function HurtEffect:afterDraw(sprite)
    love.graphics.setColor(self.color)
end

-----------------------------------------------------------
--- Ram Effect
-----------------------------------------------------------

local EffectArray = {
    hurt = HurtEffect,
    ram = RamEffect
}

return EffectArray