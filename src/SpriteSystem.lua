---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Meevere.
--- DateTime: 16.10.2022 16:43
---

local tiny = require("libs/tiny")
local Vector2 = require("utility/vector")[1]
local dump = require("utility/dump")

local SpriteSystem = tiny.processingSystem()
SpriteSystem.filter = tiny.filter('(msprite|sprite)&body')

SpriteSystem.focus_z = 1
SpriteSystem.focus_pos = Vector2(0,0)
SpriteSystem.focus_entity = nil

function SpriteSystem:preWrap(dt)
    if (self.focus_entity ~= nil) and (self.focus_entity.body ~= nil) then
        self.focus_pos = Vector2(self.focus_entity.body:getPosition())
    end
end

function SpriteSystem:processSprite(sprite, position, dt, scale, angle)
    local animation, image = sprite:current()
    local _scale = scale * sprite.scale

    animation:update(dt)

    if(sprite.camera_affected == false) then
        camera:detach()
        animation:draw(image, position[1], position[2], angle, _scale, _scale)
        camera:attach()
    else
        animation:draw(image, position[1], position[2], angle, _scale, _scale)
    end
end

function SpriteSystem:processMSprite(msprite, position, dt, scale, angle)
    for _, key in ipairs(msprite.sprites_order) do
        local sprite = msprite.sprites[key]
        self:processSprite(sprite.sprite, position + sprite.placement.offset, dt, scale * msprite.scale, angle)
    end
end

function SpriteSystem:process(entity, dt)
    local position = Vector2(entity.body:getPosition())
    local angle = entity.body:getAngle()
    local scale = 1

    -- Handle depth if it's not nil
    if( entity.depth ~= nil ) then
        local k = self.focus_z / entity.depth.z
        position = self.focus_pos - k * ( self.focus_pos - position)
        if ( entity.depth.scalable ) then
            scale = scale * k
        end
    end

    -- dispatch to processing different cases
    if(entity.msprite ~= nil) then
        SpriteSystem:processMSprite(entity.msprite, position, dt, scale, angle)
    else
        SpriteSystem:processSprite(entity.sprite, position, dt, scale, angle)
    end
end

return SpriteSystem