---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Meevere.
--- DateTime: 20.11.2022 0:49
---

local class = require("libs/30log")
local json = require("libs/json/json")

require("utility/rcall")
local anim8 = require("libs/anim8")
local Sprite, MSprite, Depth, Placement = unpack(require('src/graphics/Sprite'))

local GraphicsLoader = class("GraphicsLoader")

function GraphicsLoader:init()
    self.animations = {}
    self.sprites = {}
    self.msprites = {}
end


--- Function for loading animations from directory
---
--- @param path string
--- contains the path to assets directory. This directory must contain da.json file
--- Example of path - "assets/effects/"
---
--- @param name boolean|string
--- if true, then animations are saved in 'animations' property,
--- if string - they are saved under 'self.animations[name]'
---
--- @return table
--- always returns a table containing loaded animations
function GraphicsLoader:loadAnimations(path, name)

    local f = assert(io.open(path.."da.json", "rb"))
    local content = f:read("*all")
    f:close()

    local raw = json.decode(content)

    local destination = {}
    if name then
        if type(name) == "boolean" then
            destination = self.animations
        else
            self.animations.name = {}
            destination = self.animations.name
        end
    end

    for k, v in pairs(raw) do
        local image = love.graphics.newImage(path..v.filename)

        local camera_affected, offset, origin, scale
        if v.camera_affected ~= nil then camera_affected = v.camera_affected end
        if v.offset ~= nil then offset = v.offset end
        if v.origin ~= nil then origin = v.origin end
        if v.scale ~= nil then scale = v.scale end

        local grid = nil
        if v.grid then
            local offset_x, offset_y
            if v.grid.offset ~= nil then
                offset_x = v.grid.offset[1]
                offset_y = v.grid.offset[2]
            end

            grid = anim8.newGrid(
                    v.grid.size[1], v.grid.size[2],
                    image:getWidth(), image:getHeight(),
                    offset_x, offset_y,
                    v.grid.border
            )
        end

        local animations = nil
        if v.animations and v.grid then
            animations = {}
            for k1, anim in pairs(v.animations) do
                animations[k1] = {
                    anim8.newAnimation(grid(unpack(anim.frames)), anim.durations or 1),
                    image
                }
            end
        end

        destination[v.name] = Sprite({
            animations = animations,
            current_animation = v.current_animation
        }, camera_affected, offset, origin, scale)
    end
    return destination
end


--- Function for loading sprites from directory
---
--- @param path string
--- contains the path to assets directory. This directory must contain ds.json file
--- Example of path - "assets/effects/"
---
--- @param name boolean|string
--- if true, then sprites are saved in 'sprites' property,
--- if string - they are saved under 'self.sprites[name]'
---
--- @return table
--- always returns a table containing loaded sprites
function GraphicsLoader:loadSprites(path, name)

    local f = assert(io.open(path.."ds.json", "rb"))
    local content = f:read("*all")
    f:close()

    local raw = json.decode(content)

    local destination = {}
    if name then
        if type(name) == "boolean" then
            destination = self.sprites
        else
            self.sprites.name = {}
            destination = self.sprites.name
        end
    end

    for k, v in pairs(raw) do
        local image = love.graphics.newImage(path..v.filename)

        local camera_affected, offset, origin, scale
        if v.camera_affected ~= nil then camera_affected = v.camera_affected end
        if v.offset ~= nil then offset = v.offset end
        if v.origin ~= nil then origin = v.origin end
        if v.scale ~= nil then scale = v.scale end

        destination[v.name] = Sprite(
            image, camera_affected, offset, origin, scale
        )
    end
    return destination
end


function GraphicsLoader:loadMSprites(path, name)

    local f = assert(io.open(path.."dms.json", "rb"))
    local content = f:read("*all")
    f:close()

    local raw = json.decode(content)

    local destination = {}
    if name then
        if type(name) == "boolean" then
            destination = self.msprites
        else
            self.msprites.name = {}
            destination = self.msprites.name
        end
    end

    for k, v in pairs(raw) do
        destination[k] = {}
        local temp = {}
        for key, data in pairs(v) do
            local sprite = rcall(self, data.sprite)
            local placement = Placement({data.placement[1], data.placement[2]}, data.placement[3])

            temp[key] = {
                sprite = sprite,
                placement = placement
            }
        end
        destination[k] = MSprite(temp)
    end
    return destination
end

return GraphicsLoader