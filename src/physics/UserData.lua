---
--- Created by Meevere.
--- DateTime: 26.07.2023 15:03 GTM
---

local SensorMask = require("src/physics/SensorMask")

--- @class UserData Data that is used by Fixture (at fixture:setUserData)
--- @field entity table Reference to the entity
--- @field name string|nil Name of fixture
--- @field caller string|nil "Owner" of fixture
--- @field sensor_mask number|SensorMask
local UserData = CLASS("UserData")

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
