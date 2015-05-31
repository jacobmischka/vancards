local zone = {}

function zone:new()
    o = {}
    setmetatable(o, self)
    self.__index = self

    o.x = 0
    o.y = 0
    o.width = 0
    o.height = 0

    o.orientation = "forward"
    o.face = "up"

    o.positioner = nil

    o.capacity = 0
    o.cards = nil

    return o
end

function zone:init(x, y, width, height, face, orientation, capacity, positioner)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.cards = {}

    if orientation == "forward" or orientation == "sideward" then
        self.orientation = orientation
    end

    if face == "up" or face == "down" then
        self.face = face
    end

    self.capacity = capacity or 1

    self.positioner = positioner
end

function zone:contains(x, y)
    return x >= self.x and x <= self.x + self.width and y >= self.y and y <= self.y + self.height
end

function zone:draw()
    for i,card in ipairs(self.cards) do
        card:draw()
    end
end

function zone:position()
    for i, card in ipairs(self.cards) do
        if self.positioner then
            self.positioner(i, card, zone)
        else
            card.x = self.x + self.width/2
            card.y = self.y + self.height/2
        end
    end
end

function zone:addCard(card)
    if(#self.cards < self.capacity) then
        self:position()
        card.dragging.active = false
        table.insert(self.cards, card)
        if card.zone then card.zone:removeCard(card) end
        card.zone = self
        card:flip(self.face)
        card:rotate(self.orientation)
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
