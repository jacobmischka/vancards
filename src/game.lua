local card = require("card")
local zone = require("zone")

local game = {}

function game:init()
    self.cards = {}
    for i=1,2 do
        self.cards[i] = card:new()
        self.cards[i]:init(100*i, 100*i)
    end
    self.zones = {
        vanguard = nil,
        rearguard = nil,
        deck = nil,
        drop = nil,
        trigger = nil,
        damage = nil,
        gunit = nil,
        hand = nil
    }
    self.zones.drop = zone:new()
    self.zones.drop:init(400, 200, 150, 400)
    self.zones.hand = zone:new()
    self.zones.hand:init(0, 800, 1000, 200)
end

function game:enter()

end

function game:update(dt)
    for i,card in pairs(self.cards) do
        if card.dragging.active then
            card.x = love.mouse.getX() - card.dragging.dx
            card.y = love.mouse.getY() - card.dragging.dy
        end
    end
end

function game:draw()
    for i,card in pairs(self.cards) do
        love.graphics.draw(card.face, card.x, card.y, 0, 1, 1, card.face:getWidth()/2, card.face:getHeight()/2)
    end
    for i,zone in pairs(self.zones) do
        love.graphics.rectangle("line", zone.x, zone.y, zone.width, zone.height)
    end
end

function game:mousepressed(x, y, button)
    if button == "l" then
        z = 0
        selected_card = nil
        for i,card in pairs(self.cards) do
            if x > card.x - card.face:getWidth()/2 and x < card.x + card.face:getWidth()/2
            and y > card.y - card.face:getHeight()/2 and y < card.y + card.face:getHeight()/2
            and card.z > z
            then
                selected_card = card
                z = card.z
            end
        end
        if selected_card then
            selected_card.dragging.active = true
            selected_card.dragging.dx = x - selected_card.x
            selected_card.dragging.dy = y - selected_card.y
            selected_card.dragging.x0 = selected_card.x
            selected_card.dragging.y0 = selected_card.y
        end
    end
end

function game:mousereleased(x, y, button)
    if button == "l" then
        for i,card in pairs(self.cards) do
            for j,zone in pairs(self.zones) do
                if card.x > zone.x and card.x < zone.x + zone.width
                and card.y > zone.y and card.y < zone.y + zone.height
                then
                    card.x = zone.x + zone.width/2
                    card.y = zone.y + zone.height/2
                    card.dragging.active = false
                    break
                end
            end
            if card.dragging.active then
                card.x = card.dragging.x0
                card.y = card.dragging.y0
                card.dragging.active = false
            end
            for j,card2 in pairs(self.cards) do
                if card.z <= card2.z and card2:inside(card.x, card.y) then
                    card.z = card2.z + 1
                end
            end
        end
    end
end

return game
