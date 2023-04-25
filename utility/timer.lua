---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Meevere.
--- DateTime: 18.04.2023 22:24
---

local class = require("libs/30log")

local Timer = class("Timer", {
    time = 0,
    max = 1,

    is_on = false,

    cycle = false,
    cycle_number = 0,

    on_end = function(self) end
})

function Timer:init(max, on_end, cycle)
    self.max = max
    self.on_end = on_end
    if cycle ~= nil then self.cycle = cycle end
end


function Timer:update(dt)
    if not self.is_on then
        return
    end

    self.time = self.time + dt

    if self.time < self.max then
        return
    end

    if self.cycle then
        -- Because in Lua 1 is considered a starting number
        self.cycle_number = self.cycle_number + 1
        self.on_end(self)
        self:rewind()
    else
        self.on_end(self)
        self:off()
    end
end


function Timer:start()
    self:off()
    self.is_on = true
end


function Timer:rewind()
    self.time = self.time - self.max
end


function Timer:off()
    self.time = 0
    self.cycle_number = 0
    self.is_on = false
end


return Timer