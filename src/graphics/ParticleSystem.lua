---
--- Created by Meevere.
--- DateTime: 07.09.2023 0:01
---

local tiny = require("libs/tiny")

local ParticleSystem = tiny.processingSystem()
ParticleSystem.filter = tiny.requireAll("particle_system", "body")

function ParticleSystem:process(entity, dt)
    local x, y = entity.body:getPosition()
    entity.particle_system:setPosition()
    entity.particle_system:update()
end