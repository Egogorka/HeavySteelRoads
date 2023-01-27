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

function SpriteSystem:processSprite(sprite, dt, position, depth, scale, angle)
    local animation, image = sprite:current()
    local pos = position + sprite.offset

    animation:update(dt)

    if( depth ~= nil ) then
        local k = self.focus_z / depth.z
        pos = self.focus_pos - k * ( self.focus_pos - pos)
        if ( depth.scalable ) then
            scale = scale * k
        end
    end
    scale = scale * sprite.scale

    if(sprite.camera_affected == false) then
        camera:detach()
        animation:draw(image, pos[1], pos[2], angle, scale, scale)
        camera:attach()
    else
        animation:draw(image, pos[1], pos[2], angle, scale, scale)
    end
end

function SpriteSystem:processMSprite(msprite, dt, position, depth, scale, angle)
    for _, key in ipairs(msprite.sprites_z_order) do
        local sprite = msprite.sprites[key].sprite
        local placement = msprite.sprites[key].placement
        self:processSprite(sprite, dt, position + placement.offset, depth, scale * msprite.scale, angle)
    end
end

function SpriteSystem:process(entity, dt)
    local position = Vector2(entity.body:getPosition())
    local angle = entity.body:getAngle()
    local scale = 1

    -- dispatch to processing different cases
    if(entity.msprite ~= nil) then
        SpriteSystem:processMSprite(entity.msprite, dt, position, entity.depth, scale, angle)
    else
        SpriteSystem:processSprite(entity.sprite, dt, position, entity.depth, scale, angle)
    end
end

return SpriteSystem