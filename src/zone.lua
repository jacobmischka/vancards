local zone = {}

function zone:new()
    o = {}
    setmetatable(o, self)
    self.__index = self

    o.x = 0
    o.y = 0
    o.width = 0
    o.height = 0

    o.border = false
    o.capacity = 0
    o.cards = nil

    return o
end

function zone:init(x, y, width, height, border, capacity)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.cards = {}

    self.border = border or false
    self.capacity = capacity or 1
end

function zone:contains(x, y)
    return x >= self.x and x <= self.x + self.width and y >= self.y and y <= self.y + self.height
end

function zone:draw()
    if self.border then love.graphics.rectangle("line", self.x, self.y, self.width, self.height) end
    for i,card in ipairs(self.cards) do
        card:draw()
    end
end

function zone:addCard(card)
    if(#self.cards < self.capacity) then
        card.x = self.x + self.width/2
        card.y = self.y + self.height/2
        card.dragging.active = false
        table.insert(self.cards, card)
        if card.zone then card.zone:removeCard(card) end
        card.zone = self
        card:flip("up")
    else
        card.x = card.dragging.x0
        card.y = card.dragging.y0
        card.dragging.active = false
    end
end

function zone:removeCard(removedCard)
    for i,card in ipairs(self.cards) do
        if card.id == removedCard.id then
            table.remove(self.cards, i)
        end
    end
end

return zone
