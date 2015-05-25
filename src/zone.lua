local card = require("card")
local zone = {}

function zone:new()
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    o.x = 0
    o.y = 0
    o.width = 0
    o.height = 0

    o.capacity = 0
    o.contents = {}

    return o
end

function zone:init()
    self.x = 300
    self.y = 100
    self.width = 200
    self.height = 400

    self.capacity = 1
end

return zone
