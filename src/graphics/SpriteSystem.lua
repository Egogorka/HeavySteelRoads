---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Meevere.
--- DateTime: 16.10.2022 16:43
---

local flux = require("libs/flux")

local Vector2 = require("utility/vector")[1]

local SpriteSystem = TINY.processingSystem(CLASS("SpriteSystem"))
-- local SpriteSystem = TINY.sortedProcessingSystem(CLASS("SpriteSystem"))
SpriteSystem.filter = TINY.filter('(msprite|sprite)&(body|position)')

function SpriteSystem:init()
    self.focus_z = 1
    self.focus_pos = Vector2(0,0)
    self.focus_entity = nil
end

-- local function compare(z1, y1, z2, y2)
--     if z1 ~= z2 then
--         return z1 < z2
--     end
--     return y1 > y2
-- end

-- function SpriteSystem:compare(e1, e2)
--     local z1 = 1 --TODO: inject depth dependancy
--     local z2 = 1

--     if e1.depth then z1 = e1.depth.z end
--     if e2.depth then z2 = e2.depth.z end

--     local y1, y2

--     if e1.body then _, y1 = e1.body:getPosition() end
--     if e2.body then _, y2 = e2.body:getPosition() end

--     if e1.position then y1 = e1.position.pos[2] end
--     if e2.position then y2 = e2.position.pos[2] end

--     return compare(z1, y1, z2, y2)
-- end

function SpriteSystem:preWrap(dt)
    if (self.focus_entity ~= nil) and (not self.focus_entity.body:isDestroyed()) then
        self.focus_pos = Vector2(self.focus_entity.body:getPosition())
    end
end


---Process sprite
---@param sprite Sprite
---@param dt number
---@param position Vector2
---@param depth {scalable: boolean, z: number}
---@param scale number
---@param angle number
function SpriteSystem:processSprite(sprite, dt, position, depth, scale, angle)
    local animation = sprite:current().animation
    local image = sprite:current().image
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

    if sprite.effect then
        sprite.effect:beforeDraw(sprite)
    end

    if sprite.camera_affected then
        animation:draw(image, pos[1], pos[2], angle, scale, scale)
    else
        camera:detach()
        animation:draw(image, pos[1], pos[2], angle, scale, scale)
        camera:attach()
    end

    if sprite.effect then
        sprite.effect:afterDraw(sprite)
        if sprite.effect.is_done then
            sprite.effect = nil
        end
    end
end

function SpriteSystem:processMSprite(msprite, dt, position, depth, scale, angle)
    local flag = false
    for _, key in ipairs(msprite.sprites_z_order) do
        local sprite = msprite.sprites[key].sprite
        local placement = msprite.sprites[key].placement

        if sprite.effect == nil and msprite.effect ~= nil then
            sprite.effect = msprite.effect
            flag = true
        end

        self:processSprite(sprite, dt, position + placement.offset, depth, scale * msprite.scale, angle)
    end

    if flag then
        msprite.effect = nil
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