---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Meevere.
--- DateTime: 08.02.2023 18:31
---

local Vector2 = require("utility/vector")[1]
local Stack = require("utility/stack")
local dump = require("utility/dump")

local Sprite = require("src/graphics/Sprite")[1]
local CategoryManager = require("src/physics/CategoryManager")

local Behavior = require("src/behavior/Behavior")

local BulletBehavior = TINY.processingSystem(Behavior:extend("BulletBehavior"))
BulletBehavior.filter = TINY.requireAll("bullet", "body")

function BulletBehavior:onAdd(entity)
    BulletBehavior.super.onAdd(self, entity)
    fill_table(entity.bullet, {
        damage = 10
    })
end

function BulletBehavior:_explosion(entity)
    local p_world = entity.body:getWorld()
    local world = self.world
    local x, y = entity.body:getPosition()

    --- Usage of variable outside of current scope, beware!!
    local animation = GRAPHICS_LOADER.animations.explosion:clone()
    local explosion = {
        sprite = animation
    }
    explosion.body = love.physics.newBody(p_world, x, y, "static")
    animation.animations.default.animation.onLoop = function(anim, loops)
        explosion.body:destroy()
        TINY.removeEntity(world, explosion)
    end

    world:addEntity(explosion)
    return explosion
end

function BulletBehavior:contact(entity, dt, data)
    local other = data[2]
    if other.caller ~= nil then return end

    if other.entity.health then
        other.entity.health.change = -entity.bullet.damage
    end

    local world = self.world
    self:_explosion(entity)
    TINY.removeEntity(world, entity)
end

function BulletBehavior:onRemove(entity)
    entity.body:destroy()
end


return BulletBehavior