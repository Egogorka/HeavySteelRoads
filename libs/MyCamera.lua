---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Meevere.
--- DateTime: 04.03.2023 18:10
---

-- Utility functions
-- begin

local class = require("libs/30log")
local Vector2 = require("utility/vector")[1]

local function transform(vec, scale, angle)
    local cos, sin = scale * math.cos(angle), scale * math.sin(angle)
    -- Matrix for rotation
    -- [ cos(a), -sin(a) ]
    -- [ sin(a), cos(a) ]
    -- cuz with a=pi/2 (x=1,y=0) -> (x=0,y=1) and (0,1) -> (-1,0)
    return Vector2( cos * vec[1] - sin * vec[2], sin * vec[1] + cos * vec[2] )
end

local function cap(x)
    if x > 1 then
        return 1
    end
    return x
end

local screen = Vector2(love.graphics.getWidth(), love.graphics.getHeight())

-- utility end

local Camera = class("Camera", {
    from = {
        pos = Vector2({0,0}),
        size = screen,
        origin = screen/2,

        scale = 1,
        angle = 0,

        pos_previous = Vector2({0,0})
    },

    to = {
        pos = Vector2({0,0}),
        size = screen,
        origin = screen/2,

        scale = 1,
        angle = 0
    },

    deadzone = { --In World-Camera (or Screen-Camera cuz they are identical) coordinates
        center = {screen/2},
        size = {0,0}
    },

    target = nil,
    viscosity = nil,
    lead = 0
})

local function theta(x)
    if type(x) == "table" then
        return Vector2(theta(x[1]), theta(x[2]))
    else
        if x > 0 then
            return 1
        else if x == 0 then
            return 0.5 -- for proper addition
        end end
        return 0
    end
end

--- Initializes a new Camera with vector arguments
--- automatically converts them to vectors
---@param in_pos table \ Vector2(number) Camera's position in world_space
---@param out_pos table \ Vector2(number) Camera's position in screen_space
---@param in_origin table \ Vector2(number) self-explanatory
---@param out_origin table \ Vector2(number) self-explanatory
function Camera:init(in_pos, in_origin, out_pos, out_origin)
    if in_pos then self.from.pos = Vector2(in_pos) end
    if in_origin then self.from.origin = Vector2(in_origin) end
    if out_pos then self.to.pos = Vector2(out_pos) end
    if out_origin then self.to.origin = Vector2(out_origin) end
end

--- Auto-regulates the output scale so the camera would fit in the box of out_size
---@param out_pos table \ Vector2(number) Camera's position in screen_space
---@param out_size table \ Vector2(number) self-explanatory
---@param in_pos table \ Vector2(number) Camera's position in world_space
---@param in_size table \ Vector2(number) self-explanatory
function Camera:setFromSizes(out_pos, out_size, in_pos, in_size)
    if in_pos then self.from.pos = Vector2(in_pos) end
    if out_pos then self.to.pos = Vector2(out_pos) end

    if in_size then
        self.from.size = Vector2(in_size)
        self.from.origin = Vector2(in_size) / 2
    end

    if out_size then
        self.to.size = Vector2(out_size)
        self.to.origin = Vector2(out_size)/2
    end

    local scales = self.to.size/self.from.size
    self.to.scale = math.min(scales[1], scales[2])
end

function Camera:setDeadzone(center, size)
    if center then
        self.deadzone.center = Vector2(center)
    end
    if size then
        self.deadzone.size = Vector2(size)
    end
end

function Camera:attach()
    love.graphics.push()
    love.graphics.translate(
            self.to.pos[1] + self.to.origin[1], self.to.pos[2] + self.to.origin[2]
    )
    love.graphics.rotate(self.to.angle)
    love.graphics.scale(self.to.scale)
    --love.graphics.translate(-self.to.origin[1],-self.to.origin[2])
    --love.graphics.translate(self.from.origin[1], self.from.origin[2])
    love.graphics.rotate(-self.from.angle)
    love.graphics.scale(1/self.from.scale)

    love.graphics.translate(
         -self.from.pos[1] - self.from.origin[1], -self.from.pos[2] - self.from.origin[2]
    )
end

function Camera:detach()
    love.graphics.pop()
end

function Camera:toScreenCoords(vec) -- w2s / world to screen
    local _vec = Vector2(vec)
    local temp = transform(
        _vec - self.from.pos - self.from.origin,
        1/self.from.scale,
        -self.from.angle
    )
    local out = transform(
        temp,
            self.to.scale,
            self.to.angle
    ) + self.to.origin + self.to.pos
    return out
end

function Camera:toWorldCoords(vec) -- s2w / screen to world
    local _vec = Vector2(vec)
    local temp = transform(
            _vec - self.to.pos - self.to.origin,
            1/self.to.scale,
            -self.to.angle
    )
    local out = transform(
            temp,
            self.from.scale,
            self.from.angle
    ) + self.from.origin + self.from.pos
    return out
end

function Camera:w2wc(vec)
    return transform(
            vec - self.from.origin - self.from.pos,
            1/self.from.scale,
            -self.from.angle
    ) + self.from.origin
end

function Camera:wc2w(vec)
    return transform(
            vec - self.from.origin,
            self.from.scale,
            self.from.angle
    ) + self.from.origin + self.from.pos
end

function Camera:getMousePosition()
    return self:toWorldCoords({love.mouse.getPosition()})
end

function Camera:_deadzone_process(target)
    local p1 = self.deadzone.center - self.deadzone.size/2
    local p2 = self.deadzone.center + self.deadzone.size/2
    return
        (target - p1) * theta(p1 - target) +
        (target - p2) * theta(target - p2)
end

--- Updates the camera.
---@param dt number The time step delta
function Camera:update(dt)

    if not self.target then
        -- If there is no target there's nothing to do
        return
    end
    local target = self.target + (self.target - self.target_previous) * self.lead

    local delta = self:_deadzone_process(self:w2wc(target))

    --local temp1 = 1
    --local temp2 = 1
    --if self.viscosity then
    --    temp1 = dt / self.viscosity
    --end
    --
    --if self.inertia then
    --    temp2 = dt / self.inertia * dt
    --end
    --
    --local temp = self.from.pos
    --self.from.pos = self.from.pos +
    --        cap(temp2) * transform(delta, self.from.scale, self.from.angle) +
    --        (1 - temp1) * (self.from.pos - self.from.pos_previous)
    --self.from.pos_previous = temp

    local temp = 1
    if self.viscosity then
        temp = dt / self.viscosity
    end

    self.from.pos = self.from.pos + cap(temp) * transform(
            delta, self.from.scale, self.from.angle
    )

end

function Camera:draw_camera_box() -- While camera is attached
    local color = {love.graphics.getColor()}

    local p1 = self.from.pos
    local p2 = self.from.pos + self.from.size
    local size = p2 - p1

    love.graphics.setColor(255,0,255)
    love.graphics.rectangle('line', p1[1], p1[2], size[1], size[2])

    love.graphics.setColor(color)
end

function Camera:draw()
    local color = {love.graphics.getColor()}

    do
        local p1 = self.from.pos
        local p2 = self.from.pos + self.from.size
        local size = p2 - p1

        love.graphics.setColor(255,128,0)
        love.graphics.rectangle('line', p1[1], p1[2], size[1], size[2])
    end

    do
        local p = self:wc2w(self.from.origin)
        love.graphics.circle('line', p[1], p[2], 5)
    end

    do
        local p1 = self:wc2w(self.deadzone.center - self.deadzone.size/2)
        local size = self.deadzone.size * self.to.scale

        love.graphics.setColor(255,255,255)
        love.graphics.rectangle('line', p1[1], p1[2], size[1], size[2])
    end

    love.graphics.setColor(color)
end


function Camera:follow(vec)
    if vec then
        self.target_previous = self.target or Vector2(vec)
        self.target = Vector2(vec)
        return
    end
    self.target = nil
end

return Camera