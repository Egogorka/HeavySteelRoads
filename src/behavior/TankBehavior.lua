---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Meevere.
--- DateTime: 27.11.2022 0:20
---

--- Example of tank component
--- tank = {
---     aim = Vector2() | nil - at what coordinate it aims
--- }

local Vector2 = require("utility/vector")[1]
local Stack = require("utility/stack")
local Torus = require("utility/torus")
local Timer = require("utility/timer")
local UserData = require("src/physics/UserData")

local Sprite = require("src/graphics/Sprite")[1]
local CategoryManager = require("src/physics/CategoryManager")
local Effects = require("src/graphics/Effects")

local TankBehavior = TINY.processingSystem()
TankBehavior.filter = TINY.requireAll("tank", "body", "msprite")

TankBehavior.states = {
    ramming = {
        shoot = true, move = true
    }
}

function TankBehavior:onAdd(entity)
    CategoryManager.setObject(entity.fixture, entity.tank.team)

    entity.tank.ram_pre_timer.on_end = function(timer) self:_ram(entity) end
    entity.tank.ram_timer.on_end = function(timer) entity.tank.messages:push({"stop"}) end
end

--- Aim block
local function tower_state(phi, flipped)
    -- if flipped then
    --     phi = (Torus(-(phi/2 + 1/2) + 1/2)).a*2 - 1
    -- end
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

function TankBehavior:process(entity, dt)
    local tank = entity.tank

    tank.shoot_reload_timer:update(dt)
    tank.ram_reload_timer:update(dt)
    tank.ram_pre_timer:update(dt)
    tank.ram_timer:update(dt)

    if not tank.aimed then
        local t_current = Torus(tank.rotation_angle/2 + 1/2)
        local t_target = Torus(tank.target_angle/2 + 1/2)

        local dist = Torus.dist(t_current - t_target)
        local dir = Torus.dir(t_current, t_target) and 1 or -1

        if 2*dist < tank.rotation_speed * dt then
            tank.rotation_angle = tank.target_angle
            tank.aimed = true
        else
            tank.rotation_angle = tank.rotation_angle + dir * tank.rotation_speed * dt
        end

        tank.rotation_angle = Torus(tank.rotation_angle/2 + 1/2).a * 2 - 1

        entity.msprite.sprites.tower.sprite:set(tower_state(tank.rotation_angle, entity.msprite.is_flippedH))
    end

    -- Command logic
    while tank.messages:size() ~= 0 do
        local message = tank.messages:pop()
        local command = message[1]

        if tank.ram_reload_timer.is_on and self.states.ramming[command] then
            goto continue
        end

        if self[command] then
            self[command](self, entity, dt, message[2])
        end
        ::continue::
    end
end

function TankBehavior:ram(entity, dt, pos)
    entity.tank.ram_reload_timer:start()
    entity.tank.ram_pre_timer:start()
    entity.msprite.effect = Effects.ram()
    entity.tank.ram_pos = Vector2(pos)
end

function TankBehavior:_ram(entity)
    local temp = entity.tank.ram_pos - Vector2(entity.body:getPosition())

    local vel = 500
    if ( temp[1] < 0 ) then
        vel = -500
    end

    entity.tank.ram_timer:start()
    entity.msprite.sprites.body.sprite:set("move")
    entity.body:setLinearVelocity(vel, 0)
end

--- Move block
---@param vel table
function TankBehavior:move(entity, dt, vel)
    local v = Vector2(vel)

    local velocity = v * entity.tank.max_speed
    if v:mag() > 1 then
        velocity = velocity / v:mag()
    end

    --entity.tank.is_moving = true
    entity.msprite.sprites.body.sprite:set("move")
    entity.body:setLinearVelocity(velocity:x(), velocity:y())
end

function TankBehavior:stop(entity, dt)
    --entity.tank.is_moving = false
    entity.msprite.sprites.body.sprite:set("idle")
    entity.body:setLinearVelocity(0, 0)
end


---@param aim table
function TankBehavior:aim(entity, dt, aim)
    if aim then
        local position = Vector2(entity.body:getPosition())
        entity.tank.target_angle = (aim - position):angle()/math.pi
        entity.tank.aimed = false
    else
        entity.tank.aimed = true
    end
end


--- Shoot block

function TankBehavior:_bullet(entity)
    local p_world = entity.body:getWorld()
    local world = self.world
    local x, y = entity.body:getPosition()

    local bullet = {
        sprite = Sprite(love.graphics.newImage("assets/player/Bullet1.png")),
        shape = love.physics.newRectangleShape(10, 10),
        bullet = {},
        behavior = "bullet"
    }
    bullet.body = love.physics.newBody(p_world, x+15, y, "kinematic")
    bullet.body:setFixedRotation(true)
    bullet.fixture = love.physics.newFixture(bullet.body, bullet.shape)
    bullet.fixture:setSensor(true)
    bullet.fixture:setUserData(UserData(bullet))

    CategoryManager.setBullet(bullet.fixture, entity.tank.team)

    world:addEntity(bullet)
    return bullet
end

function TankBehavior:shoot(entity, dt)

    if entity.tank.shoot_reload_timer.is_on or not entity.tank.aimed then
        return
    end
    entity.tank.shoot_reload_timer:start()

    local vel = 300 * Vector2.fromPolar(1, entity.tank.rotation_angle * math.pi)
    local bullet = self:_bullet(entity)
    bullet.body:setLinearVelocity(vel[1], vel[2])
    bullet.body:setAngle(entity.tank.rotation_angle * math.pi)
end

function TankBehavior:hurt(entity, dt)
    if entity.msprite.effect == nil then
        entity.msprite.effect = Effects.hurt()
    end
end

function TankBehavior:die(entity, dt)
    local world = self.world
    TINY.removeEntity(world, entity)
end

function TankBehavior:onRemove(entity)
    print("TankRemoved")
    entity.body:destroy()
end

function TankBehavior:contact(entity, dt, data)
    local other = data[2]
    if other.caller ~= nil then return end

    if other.entity.health then
        if entity.tank.ram_timer.is_on then
            other.entity.health.change = -20
        else
            other.entity.health.change = -5
        end
    end
end

return TankBehavior