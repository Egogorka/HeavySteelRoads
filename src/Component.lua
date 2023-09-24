--- Because of duck-typing it's better *not* to have
--- classes for each component, and just functions that fill them

--- @class Component
---
--- @field json_encode function(Component):string
--- @field json_decode function(string):Component

local json = require("libs/json/json")
local Component = CLASS("Component")

function Component.json_encode(self)
    return json.encode(self)
end

---@param str string
---@return Component
function Component.json_decode(str)
    return json.decode(str)
end

return Component