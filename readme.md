
## Параметры 

Версия Love2D - 11.4, версия Lua - LuaJIT 2.1.0-beta3

## Настройка окружения

### Visual Studio code

Плагины
- Lua (``publisher: sumneko``) - для синтаксической проверки кода во время письма
- ~~Lua Debug (``publisher: actboy``) - для дебага (по названию видно) (не работает с Love2D)~~
- Local Lua Debugger (``publisher: Tom Blind``) - для дебага
- Love2D Support (``publisher: Pixelbyte Studios``) - для запуска Love2D прямо из IDE

Для первых двух плагинов нужно в настройках указать версию jit (или LuaJIT), а в последнем путь к Love2D. Также на Windows нужно поменять ``Require Separator`` с ``.`` на ``/``

### Debug

В самом пакете `Local Lua Debugger` указано как он работает, но продублирую для удобства:

---


#### Custom Lua Environment (LÖVE)
To debug using a custom Lua executable, you must set up your launch.json with the name/path of the executable and any additional arguments that may be needed.


.vscode/launch.json
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug Love",
      "type": "lua-local",
      "request": "launch",
      "program": {
        "command": "love"
      },
      "args": [
        "game"
      ],
      "scriptRoots": [
        "game"
      ]
    }
  ]
}
```

./main.lua
```lua
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end

function love.load()
  ...
```

Note that console must be set to false (the default value) in conf.lua, or the debugger will not be able to communicate with the running program.

./conf.lua
```lua
function love.conf(t)
  t.console = false
end
```

---

Но просто так не работает, я же вместо `command` указал путь до Löve
