--- Dependency Injection for prefabs loader
--- Order of register matters!

local json = require("libs/json/json")
local UserData = require("src/physics/UserData")

local Sprite, MSprite, Depth, Placement = unpack(require('src/graphics/Sprite'))


PREFABS_LOADER:register("body", 1, function (raw, loader)
    local t = love.physics.newBody(loader.physics_world, 0, 0, raw)
    t:setFixedRotation(true)
    return t
end)


PREFABS_LOADER:register("shape", 1, function (raw)
    return love.physics.newRectangleShape(unpack(raw))
end)


PREFABS_LOADER:register("fixture", 2, function (raw, loader, current)
    local fname = nil
    local caller = nil
    local is_sensor = nil
    if type(raw) == "table" then
        fname = raw.name
        caller = raw.caller
        is_sensor = raw.sensor
    end
    local t = love.physics.newFixture(current.body, current.shape)
    if is_sensor then
        t:setSensor(true)
    end
    t:setUserData(UserData(current, fname, caller))
    return t
end)


PREFABS_LOADER:register("depth", 1, function (raw)
    if type(raw) == "number" then
        return Depth(raw)
    end
    return Depth(raw.z, raw.scalable)
end)


PREFABS_LOADER:register("sprite", 1, function (raw, loader)
    local t
    if loader.graphics_loader.sprites[raw] then
        t = loader.graphics_loader.sprites[raw]:clone()
    else
        if loader.graphics_loader.animations[raw] then
            t = loader.graphics_loader.animations[raw]:clone()
        else
            print("Warning: Trying to fabricate entity without sprite "..raw)
            pdump(loader.graphics_loader.animations)
            pdump(loader.graphics_loader.sprites)
        end
    end
    return t
end)

PREFABS_LOADER:register("msprite", 1, function (raw, loader)
    return loader.graphics_loader.msprites[raw]:clone()
end)

-- 3 because after fixture
PREFABS_LOADER:register("drone", 3, require("src/behavior/Drone"))
PREFABS_LOADER:register("tank", 3, require("src/behavior/Tank"))
PREFABS_LOADER:register("truck", 3, require("src/behavior/Truck"))
