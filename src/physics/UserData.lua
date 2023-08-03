---
--- Created by Meevere.
--- DateTime: 26.07.2023 15:03 GTM
---

local class = require("libs/30log")
local SensorMask = require("src/physics/SensorMask")

local UserData = class("UserData")

--- @param entity table
--- @param name string|nil
--- @param caller string|nil -- "owner" of fixture
--- @param sensor_mask number|table
function UserData:init(entity, name, caller, sensor_mask)
    self.entity = entity
    self.name = name
    self.caller = caller
    self.sensor_mask = SensorMask(sensor_mask)
end

return UserData
