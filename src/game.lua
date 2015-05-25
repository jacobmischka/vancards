local card = require("card")
local zone = require("zone")

local game = {}

function game:new()
    o = {}
    setmetatable(o, self)
    self.__index = self

    o.card = nil
    o.zone = nil

    -- o.vanguard = nil
    -- o.rearguard = nil
    -- o.deck = nil
    -- o.drop = nil
    -- o.trigger = nil
    -- o.damage = nil
    -- o.gunit = nil
    -- o.hand = nil

    return o
end

function game:init()
    self.card = card:new()
    self.card:init(100, 100)
    self.zone = zone:new()
    self.zone:init(400, 200, 150, 400)
end

function game:enter()

end

function game:update(dt)
    if self.card.dragging.active then
        self.card.x = love.mouse.getX() - self.card.dragging.dx
        self.card.y = love.mouse.getY() - self.card.dragging.dy
    end
end

function game:draw()
    love.graphics.draw(self.card.face, self.card.x, self.card.y, 0, 1, 1, self.card.face:getWidth()/2, self.card.face:getHeight()/2)
    love.graphics.rectangle("line", self.zone.x, self.zone.y, self.zone.width, self.zone.height)
end

function game:mousepressed(x, y, button)
    if button == "l"
    and x > self.card.x - self.card.face:getWidth()/2 and x < self.card.x + self.card.face:getWidth()/2
    and y > self.card.y - self.card.face:getHeight()/2 and y < self.card.y + self.card.face:getHeight()/2
    then
        self.card.dragging.active = true
        self.card.dragging.dx = x - self.card.x
        self.card.dragging.dy = y - self.card.y
        self.card.dragging.x0 = self.card.x
        self.card.dragging.y0 = self.card.y
    end
end

function game:mousereleased(x, y, button)
    if button == "l" then
        if self.card.x > self.zone.x and self.card.x < self.zone.x + self.zone.width
        and self.card.y > self.zone.y and self.card.y < self.zone.y + self.zone.height
        then
            self.card.x = self.zone.x + self.zone.width/2
            self.card.y = self.zone.y + self.zone.height/2
        else
            self.card.x = self.card.dragging.x0
            self.card.y = self.card.dragging.y0
        end
        self.card.dragging.active = false
    end
end

return game
