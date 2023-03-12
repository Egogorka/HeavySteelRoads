---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Meevere.
--- DateTime: 16.10.2022 16:43
---

local class = require("libs/30log")
local flux = require("libs/flux")

local tiny = require("libs/tiny")
local Vector2 = require("utility/vector")[1]

local SpriteSystem = tiny.processingSystem(class("SpriteSystem"))
SpriteSystem.filter = tiny.filter('(msprite|sprite)&(body|position)')

function SpriteSystem:init()
    self.focus_z = 1
    self.focus_pos = Vector2(0,0)
    self.focus_entity = nil
end

function SpriteSystem:preWrap(dt)
    if (self.focus_entity ~= nil) and (self.focus_entity.body ~= nil) then
        self.focus_pos = Vector2(self.focus_entity.body:getPosition())
    end
end

function SpriteSystem:processSprite(sprite, dt, position, depth, scale, angle)
    local animation, image = sprite:current()
    local pos = position + sprite.offset

    animation:update(dt)

    -- Sprite-scale effects
    local offset = (1 - sprite.scale) * sprite.origin
    pos = pos + offset

    -- Depth-scale effects
    if( depth ~= nil ) then
        local k = self.focus_z / depth.z
        pos = self.focus_pos - k * ( self.focus_pos - pos)
        if ( depth.scalable ) then
            scale = scale * k
        end
    end
    scale = scale * sprite.scale

    local color = {love.graphics.getColor()}
    if sprite.hurt_effect then
        sprite.hurt_effect = false

        sprite.hurt_effect_flag = true
        sprite.hurt_color = 1

        local temp = flux
            .to(sprite, 0.1, { hurt_color = 0.2} )
            :ease("elasticout")
            :after(sprite, 0.1, { hurt_color = 1} )
            :oncomplete(
        function()
            sprite.hurt_effect_flag = false
        end)
    end

    if sprite.hurt_effect_flag then
        love.graphics.setColor(1, sprite.hurt_color, sprite.hurt_color, 1)
    end

    if sprite.camera_affected then
        animation:draw(image, pos[1], pos[2], angle, scale, scale)
    else
        camera:detach()
        animation:draw(image, pos[1], pos[2], angle, scale, scale)
        camera:attach()
    end

    if sprite.hurt_effect_flag then
        love.graphics.setColor(color)
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
    local position, angle
    local scale = 1
    if entity.body then
        position = Vector2(entity.body:getPosition())
        angle = entity.body:getAngle()
    else
        position = entity.position.pos
        if entity.position.angle then
            angle = entity.position.angle
        end
    end

    -- dispatch to processing different cases
    if(entity.msprite ~= nil) then
        self:processMSprite(entity.msprite, dt, position, entity.depth, scale, angle)
    else
        self:processSprite(entity.sprite, dt, position, entity.depth, scale, angle)
    end
end

return SpriteSystem