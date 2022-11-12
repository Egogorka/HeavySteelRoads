---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Meevere.
--- DateTime: 16.10.2022 16:41
---

local Vector2, Vector3 = unpack(require('utility/vector'))
local tiny = require("libs/tiny")
local dump = require('utility/dump')

local PlayerControlSystem = tiny.processingSystem()
PlayerControlSystem.filter = tiny.requireAll("player", "body", "msprite", "depth")

local function keyboard_handle()
    local velocity = Vector2()
    local type = "idle"
    if love.keyboard.isDown("up") then
        velocity = velocity + {0,-100}
        type = "move"
    end
    if love.keyboard.isDown("down") then
        velocity = velocity + {0,100}
        type = "move"
    end
    if love.keyboard.isDown("left") then
        velocity = velocity + {-100,0}
        type = "move"
    end
    if love.keyboard.isDown("right") then
        velocity = velocity + {100,0}
        type = "move"
    end
    return {velocity, type}
end

local function mouse_handle(entity)
    local mouse_pos = Vector2(love.mouse.getPosition())
    local position = Vector2(camera:toCameraCoords(entity.body:getX(), entity.body:getY()))
    local phi = (mouse_pos - position):angle()/math.pi

    if( phi > 7/8 ) then
        return "left"
    end
    if( phi > 5/8) then
        return "left_down"
    end
    if( phi > 3/8) then
        return "down"
    end
    if( phi > 1/8) then
        return "right_down"
    end
    if( phi > -1/8) then
        return "right"
    end
    if( phi > -3/8) then
        return "right_up"
    end
    if( phi > -5/8) then
        return "up"
    end
    if( phi > -7/8) then
        return "left_up"
    end
    return "left"
end

function PlayerControlSystem:process(entity, dt)
    local velocity, type = unpack(keyboard_handle())
    local orientation = mouse_handle(entity)
    local depth = entity.depth.z
    if love.keyboard.isDown("q") then
        depth = depth / 0.95
    end
    if love.keyboard.isDown("e") then
        depth = depth * 0.95
    end



    entity.body:setLinearVelocity(velocity:x(), velocity:y())
    entity.msprite.sprites.body.sprite:set(type)
    entity.msprite.sprites.tower.sprite:set(orientation)
    entity.depth.z = depth
end

return PlayerControlSystem