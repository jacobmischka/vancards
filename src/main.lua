local state = require("lib.hump.gamestate")
local game = require("game")

function love.load()
    state.registerEvents()
    state.switch(game)
end
