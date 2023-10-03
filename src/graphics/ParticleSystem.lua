---
--- Created by Meevere.
--- DateTime: 07.09.2023 0:01
---


local ParticleSystem = TINY.processingSystem()
ParticleSystem.filter = TINY.requireAll("particle_system", "body")

---@class ParticleSystem
---@field ps love.ParticleSystem
---@field emit number

function ParticleSystem:onAdd(entity)
    fill_table(entity.particles, {
        emit = 0
    })
end

---comment
---@param entity {particles: ParticleSystem, body: love.Body}
---@param dt number
function ParticleSystem:process(entity, dt)
    local x, y = entity.body:getPosition()
    entity.particles.ps:setPosition(x, y)
    entity.particles.ps:emit(1)
    entity.particles.ps:update(dt)
end

return ParticleSystem