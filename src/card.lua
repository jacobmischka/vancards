local card = {}

function card:new()
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    o.x = 0
    o.y = 0
    o.face = love.graphics.newImage("cardfaces/G-BT01-088EN PR.jpg")
    o.dragging = { active = false, dx = 0, dy = 0, x0 = 0, y0 = 0}

    return o
end

function card:init(x, y)
    self.x = x
    self.y = y
end

return card
