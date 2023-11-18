---
--- Created by Meevere.
--- DateTime: 13.09.2023 18:56
---


---@class Truck: Behavior
---@field max_speed number
---@field max_speed_full number
---@field max_speed_empty number 
---
---@field team CategoriesNames
---@field contents table


function TruckFabricate(raw, loader, current)
    --- Variables that are present in json
    raw.max_speed = raw.max_speed_full
    --max_speed_full
    --max_speed_empty

    --- Variables that are technical/unnecessary for json
    raw.team = "enemy"
    raw.contents = {}

    return raw
end

return TruckFabricate