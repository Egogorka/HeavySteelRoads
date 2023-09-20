---
--- Created by Meevere.
--- DateTime: 07.09.2023 0:01
---


local ParticleSystem = TINY.processingSystem()
ParticleSystem.filter = TINY.requireAll("particle_system", "body")

function ParticleSystem:process(entity, dt)
    local x, y = entity.body:getPosition()
    entity.particle_system:setPosition()
    entity.particle_system:update()
end