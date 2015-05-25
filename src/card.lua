local card = {}

function card:new()
    o = {}
    setmetatable(o, self)
    self.__index = self

    o.x = 0
    o.y = 0
    o.z = 0
    o.face = love.graphics.newImage("cardfaces/G-BT01-088EN PR.jpg")
    o.dragging = { active = false, dx = 0, dy = 0, x0 = 0, y0 = 0}

    return o
end

function card:init(x, y)
    self.x = x
    self.dragging.x0 = x
    self.y = y
    self.dragging.y0 = y
    self.z = 1
end

function card:inside(x, y)
    return x >= self.x - self.face:getWidth()/2 and x <= self.x + self.face:getWidth()/2 and y >= self.y - self.face:getHeight()/2 and y <= self.y + self.face:getHeight()/2
end

return card
