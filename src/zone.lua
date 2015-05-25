local zone = {}

function zone:new()
    o = {}
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

function zone:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    self.capacity = 1
end

function zone:inside(x, y)
    return x >= self.x and x <= self.x + self.width and y >= self.y and y <= self.y + self.height
end

return zone
