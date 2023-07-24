---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Meevere.
--- DateTime: 15.07.2023 15:28
---

local Vector2 = require("utility/vector")[1]
local Stack = require("utility/stack")
local dump = require("utility/dump")
local Torus = require("utility/torus")
local Timer = require("utility/timer")

local Sprite = require("src/graphics/Sprite")[1]
local CategoryManager = require("src/CategoryManager")
local Effects = require("src/graphics/Effects")

local tiny = require("libs/tiny")

local Behavior = require("Behavior")
local PickupBehavior = tiny.processingSystem(Behavior:extend("PickupBehavior"))
PickupBehavior.filter = tiny.requireAll("pickup", "body", "fixture", "sprite")

function PickupBehavior:onAdd(entity)
    PickupBehavior.super.onAdd(self, entity)

    fill_table(entity.pickup, {
        on_pickup = function(pickup, picker)
            picker.health.change = 20
        end,
        expiration_timer = nil -- Otherwise Timer
    })

    entity.fixture:setSensor(true)
end

function PickupBehavior:process(entity, dt)
    local pickup = entity.pickup
    if pickup.expiration_timer ~= nil then
        pickup.expiration_timer.update(dt)
    end

    PickupBehavior.super.process(self, entity, dt)
end

function PickupBehavior:contact(entity, dt, data)
    print("PickupContact!")
    pdump(data[2])

    local other_data = data[2]
    local this_data = data[1]

    local other = other_data.entity
    if other.health == nil then
        return
    end

    if other.player == nil then
        return
    end

    entity.pickup.on_pickup(entity, other)
    tiny.removeEntity(self.world, entity)
end

function PickupBehavior:onRemove(entity)
    entity.body:destroy()
end

return PickupBehavior