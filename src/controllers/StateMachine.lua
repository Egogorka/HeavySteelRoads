---
--- Created by Meevere.
--- DateTime: 24.09.2023 15:49
---

local Stack = require("utility/stack")

--- @class StateMachine
--- @field messages Stack
--- @field state Stack

local StateMachine = CLASS("StateMachine")

function StateMachine:onAdd(entity)
    fill_table(entity.ai, {
        messages = Stack(),
        states = Stack()
    })
end

function StateMachine:process(entity, dt)
    local ai = entity.ai

    --- Messages
    while ai.messages:size() ~= 0 do
        local message = ai.messages:pop()
        local command = message[1]

        if self[command] then
            self[command](self, entity, dt, message[2])
        end
    end

    --- Stack-machine stuff
    if ai.states:size() == 0 then
        ai.states:push("idle")
    end

    local state = ai.states:pop()
    self[state](self, entity, dt)
end

return StateMachine