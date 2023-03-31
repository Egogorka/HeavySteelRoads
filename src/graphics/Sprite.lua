---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Meevere.
--- DateTime: 23.10.2022 14:59
---

local anim8 = require("libs/anim8")
local class = require("libs/30log")
local Vector2, Vector3 = unpack(require("utility/vector"))

-----------------------------------------
--- Classes
-----------------------------------------

---
--- z - value of depth
--- scalable - determines if sprite would be scaled with depth
---
local Depth = class("Depth", {
    z = 1,
    scalable = true
})

local Placement = class("Placement", {
    offset = Vector2(0,0),
    z_index = 0, -- higher - 'closer' to the screen in terms of order of sprites
})

local Sprite = class("Sprite", {
    animations = {},
    current_animation = "default",

    scale = 1,
    offset = Vector2(),
    origin = Vector2(),

    camera_affected = true,
    effects = {}, -- Effects
})

-- Short for MultipleSprite
local MSprite = class("MSprite", {
    sprites = {
        default = Sprite(love.graphics.newImage("assets/placeholder.png")),
    },
    sprites_z_order = {"default"}, --- sprites Z order
    scale = 1
})

-----------------------------------------
--- Depth implementation
-----------------------------------------

function Depth:init(z, scalable)
    self.z = z

    if( scalable ~= nil ) then
        self.scalable = scalable
    end
end

-----------------------------------------
--- Placement implementation
-----------------------------------------

function Placement:init(offset, z_index)
    if(offset ~= nil) then
        self.offset = Vector2(offset)
    end
    if(z_index ~= nil) then
        self.z_index = z_index
    end
end

-----------------------------------------
--- Sprite implementation
-----------------------------------------

function Sprite:init(o, camera_affected, offset, origin, scale)
    if not o then
        return
    end

    if(offset ~= nil) then
        self.offset = offset
    end
    if(origin ~= nil) then
        self.origin = origin
    end
    if(scale ~= nil) then
        self.scale = scale
    end
    if(camera_affected ~= nil) then
        self.camera_affected = camera_affected
    end

    if( o["type"] ~= nil and o:type() == "Image") then
        local grid = anim8.newGrid(o:getWidth(), o:getHeight(), o:getWidth(), o:getHeight())
        self.animations = {
            default = {anim8.newAnimation(grid(1,1), 1), o}
        }
        self.current_animation = "default"
    else
        self.current_animation = o.current_animation

        self.animations = {}
        for k, v in pairs(o.animations) do
            self.animations[k] = {v[1]:clone(), v[2]}
        end
    end
end

function Sprite:set(type)
    if( self.animations[type] == nil or self.current_animation == type) then
        return
    end
    self:current():gotoFrame(1) -- reset the previous animation
    self.current_animation = type
end

function Sprite:current()
    local temp = self.animations[self.current_animation]
    return temp[1], temp[2]
end

function Sprite:size()
    local anim = self:current()
    local w, h = anim:getDimensions()
    return Vector2(w, h)
end

function Sprite:clone()
    return Sprite(self, self.camera_affected, self.offset, self.origin, self.scale)
end

-----------------------------------------
--- MSprite implementation
-----------------------------------------

local function my_sort(t, ord)
    -- Construct table from keys and values => {key, value}
    local temp = {}
    for k, v in pairs(t) do
        table.insert(temp, {key=k, value=v})
    end
    table.sort(temp, function(a, b) return ord(a.value, b.value) end)
    local out = {}
    for i, v in ipairs(temp) do
        table.insert(out, i, v.key)
    end
    return out
end

function MSprite:sort()
    self.sprites_z_order = my_sort(self.sprites, function(a, b) return a.placement.z_index < b.placement.z_index end)
end

function MSprite:init(o, scale)
    if(o["type"] ~= nil and o:type() == "Image") then
        self.sprites.default.sprite = Sprite(o)
        self.sprites.default.placement = Placement()
    elseif(o ~= nil) then
        local source = o
        if(o.sprites ~= nil) then
            source = o.sprites
        end
        self.sprites = {}
        for k, v in pairs(source) do
            self.sprites[k] = {
                sprite = v.sprite:clone(),
                placement = v.placement
            }
        end
    end

    if(scale ~= nil) then
        self.scale = scale
    end

    -- Presort sprites according to their placement z_index
    self:sort()
end

function MSprite:clone()
    return MSprite(self, self.scale)
end

return {Sprite, MSprite, Depth, Placement}