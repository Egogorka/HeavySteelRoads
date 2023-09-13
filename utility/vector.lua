---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Meevere.
--- DateTime: 04.11.2022 0:15
---

local Class = require("libs/30log")

--- @class Vector2
--- @operator unm: Vector2
--- @operator add(Vector2|table): Vector2
--- @operator sub(Vector2|table): Vector2
--- @operator mul(Vector2|table|number): Vector2
--- @operator div(Vector2|table|number): Vector2
local Vector2 = Class("Vector2", { 0, 0 })

function Vector2:init(a, b)
    if type(a) == "table" then
        -- Create from table --
        if (a["x"] ~= nil) and (a["y"] ~= nil) then
            -- This is something like Vector2 - duck typing
            if type(a["x"]) == "function" then
                self[1] = a:x();
            else
                self[1] = a.x;
            end
            if type(a["y"]) == "function" then
                self[2] = a:y();
            else
                self[2] = a.y;
            end
        else
            -- Then just by numbers
            self[1] = a[1]; self[2] = a[2]
        end
    else
        -- Then think of an a as number
        self[1] = a or 0; self[2] = b or 0
    end
end

function Vector2.__tostring(v)
    return 'Vector<' .. tostring(v[1]) .. ',' .. tostring(v[2]) .. '>'
end

function Vector2.fromPolar(r, phi)
    local x = r * math.cos(phi)
    local y = r * math.sin(phi)
    return Vector2(x, y)
end

function Vector2:x()
    return self[1]
end

function Vector2:y()
    return self[2]
end

function Vector2.__eq(v1, v2)
    return v1[1] == v2[1] and v1[2] == v2[2]
end

function Vector2.__add(v1, v2)
    local out = Vector2()
    out[1] = v1[1] + v2[1]
    out[2] = v1[2] + v2[2]
    return out
end

function Vector2.__unm(v)
    return Vector2(-v[1], -v[2])
end

function Vector2.__sub(v1, v2)
    local out = Vector2()
    out[1] = v1[1] - v2[1]
    out[2] = v1[2] - v2[2]
    return out
end

function Vector2.__mul(a, b)
    local out = Vector2()
    if (type(a) == "table") and (type(b) == "table") then
        -- Multiply component-vice
        out[1] = a[1] * b[1]
        out[2] = a[2] * b[2]
        return out
    end

    if (type(a) == "table") then
        return b * a -- swap order
    end
    -- Multiply by scalar (first argument)
    out[1] = a * b[1]
    out[2] = a * b[2]
    return out
end

local function inverse(v)
    return Vector2(1 / v[1], 1 / v[2])
end

function Vector2.__div(a, b)
    local inv;
    if type(b) == "table" then
        inv = inverse(b)
    else
        inv = 1 / b
    end
    return a * inv
end

function Vector2:magsqr()
    return self[1] * self[1] + self[2] * self[2]
end

function Vector2:mag()
    return math.sqrt(self:magsqr())
end

-- Returns the angle from x axis from in range [-pi,pi)
function Vector2:angle()
    local phi = math.acos(self[1] / math.sqrt(self:magsqr()))
    if (self[2] < 0) then
        phi = -phi
    end
    return phi
end

---Rotates the vector anti-clockwise (from +x to +y to -x and -y)
---@param angle number in radians
---@return Vector2
function Vector2:rotate(angle)
    local x = self[1] * math.cos(angle) - self[2] * math.sin(angle)
    local y = self[1] * math.sin(angle) + self[2] * math.cos(angle)

    return Vector2(x, y)
end

---Returns perpendicular vector
---@return Vector2
function Vector2:perp()
    return Vector2(-self[2], self[1])
end

--- @class Vector3
--- @operator unm: Vector3
--- @operator add(Vector3|table): Vector3
--- @operator sub(Vector3|table): Vector3
--- @operator mul(Vector3|table|number): Vector3
--- @operator div(Vector3|table|number): Vector3
local Vector3 = Class("Vector3", { 0, 0, 0 })

function Vector3:init(a, b, c)
    if type(a) == "table" then
        -- Create from table --
        if (a["x"] ~= nil) and (a["y"] ~= nil) and (a["z"] ~= nil) then
            -- This is something like Vector2 - duck typing
            self[1] = a.x; self[2] = a.y; self[3] = a.y
        else
            -- Then just by numbers
            self[1] = a[1]; self[2] = a[2]; self[3] = a[3]
        end
    else
        -- Then think of an a as number
        self[1] = a or 0; self[2] = b or 0; self[3] = c or 0
    end
end

function Vector3:x()
    return self[1]
end

function Vector3:y()
    return self[2]
end

function Vector3:z()
    return self[3]
end

function Vector3.__add(v1, v2)
    local out = Vector3()
    out[1] = v1[1] + v2[1]
    out[2] = v1[2] + v2[2]
    out[3] = v1[3] + v2[3]
    return out
end

function Vector3.__unm(v)
    return Vector3(-v[1], -v[2], -v[3])
end

function Vector3.__sub(v1, v2)
    return v1 + (-v2)
end

function Vector3.__mul(a, b)
    local out = Vector3()
    if (type(a) == "table") and (type(b) == "table") then
        -- Multiply component-vice
        out[1] = a[1] * b[1]
        out[2] = a[2] * b[2]
        out[3] = a[3] * b[3]
        return out
    end

    if (type(a) == "table") then
        return b * a -- swap order
    end
    -- Multiply by scalar (first argument)
    out[1] = a * b[1]
    out[2] = a * b[2]
    out[3] = a * b[3]
    return out
end

-- adjacent methods
function Vector3:getXY()
    return Vector2(self[1], self[2])
end

function Vector3:setXY(v)
    self[1] = v[1]
    self[2] = v[2]
end

return { Vector2, Vector3 }
