---
--- Created by Meevere.
--- DateTime: 26.07.2023 13:18 GTM
---

--- @class SensorMask
--- @field n number The mask itself
local SensorMask = CLASS("SensorMask")

--- @param n number|table
function SensorMask:init(n)
    if n == nil then
        self.n = 0x0000
        return
    end
    if type(n) == "number" then
        self.n = n
        return
    end
    if type(n) == "table" then
        if n.n == nil then
            error("Argument passed to SensorMask constructor is table and has no [n] key", 2)
            return
        end
        self.n = n.n
    end
end

--- @param ... integer Category numbers to add (from 1 to 8?)
function SensorMask:addMask(...)
    local arg = { ... }
    for _, value in pairs(arg) do
        -- value-1 because categories are numbered from 1
        self.n = bit.bxor(self.n, bit.lshift(1, value - 1))
    end
end

--- @param ... integer Category numbers to set (from 1 to 8?)
function SensorMask:setMask(...)
    local arg = { ... }
    self.n = 0x0000 -- reset mask
    self:addMask(unpack(arg))
end

function SensorMask.fixtureSetMask(fixture, ...)
    local arg = { ... }
    local userData = fixture:getUserData()
    userData.sensor_mask:setMask(unpack(arg))
end

function SensorMask.fixtureAddMask(fixture, ...)
    local arg = { ... }
    local userData = fixture:getUserData()
    userData.sensor_mask:addMask(unpack(arg))
end

--- TODO: SensorMask:getMask()

return SensorMask