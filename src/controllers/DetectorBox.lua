---
--- Created by Meevere.
--- DateTime: 24.09.2023 16:15
---

local UserData = require("src/physics/UserData")
local CategoryManager = require("src/physics/CategoryManager")

local DetectorBox = {}

--- Initializes detector box in entity.ai
---@param entity any Entity that box would be in
---@param offset Vector2|number[] Offset from entity's body position
---@param size Vector2|number[] Size of the box (centered on offset)
---@param name string Name of the box
---@param flag_name ?string Flag that box sets to true on contact
function DetectorBox.init(entity, offset, size, name, flag_name)
    local box = {}

    if flag_name == nil then
        flag_name = "in_"+name
    end

    box.shape = love.physics.newRectangleShape(offset[1], offset[2], size[1], size[2])
    box.fixture = love.physics.newFixture(entity.body, box.shape)
    box.fixture:setSensor(true)
    box.fixture:setUserData(UserData(entity, name, "ai"))
    CategoryManager.setObject(box.fixture, entity[entity.behavior].team)

    local ftable = {}
    ftable[name] = box
    ftable[flag_name] = false

    fill_table(entity.ai, ftable)
end

--- Checks if box with given name is in contact with target
---@param data UserData[]
---@param target table
---@param name string
---@return boolean
function DetectorBox.checkContact(data, target, name)
    local other = data[2]
    local this = data[1]

    return (this.name == name) and (other.entity == target)
end


function DetectorBox.onContact(entity, data, target, name, flag_name)
    if flag_name == nil then
        flag_name = "in_"+name
    end
    if DetectorBox.checkContact(data, target, name) then
        entity.ai[flag_name] = true
    end
end

function DetectorBox.onEndContact(entity, data, target, name, flag_name)
    if flag_name == nil then
        flag_name = "in_"+name
    end
    if DetectorBox.checkContact(data, target, name) then
        entity.ai[flag_name] = false
    end
end

return DetectorBox