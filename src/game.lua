local card = require("card")
local zone = require("zone")
local json = require("lib.dkjson")

local game = {}

function game:init()
    self.card = nil
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
    self.zones.drop:init(400, 200, 150, 200)
    self.zones.hand = zone:new()
    self.zones.hand:init(0, 800, 1000, 200, 7)
    self.zones.deck = zone:new()
    self.zones.deck:init(100, 100, 150, 200, 50)

    local f = assert(io.open("cards.json", "r"))
    local t = f:read("*all")
    f:close()
    local cards, pos, err = json.decode(t, 1, nil)
    table.foreach(cards, print)

    for i=1,50 do
        self.zones.deck:addCard(card:new(cards[i]["[Number]"], cards[i]["[Image]"]))
    end
end

function game:enter()

end

function game:update(dt)
	if self.card and self.card.dragging.active then
		self.card.x = love.mouse.getX() - self.card.dragging.dx
		self.card.y = love.mouse.getY() - self.card.dragging.dy
	end
end

function game:draw()
	for i,zone in pairs(self.zones) do
		zone:draw()
	end
end

function game:mousepressed(x, y, button)
	if button == "l" then
		self.card = nil
		for i,zone in pairs(self.zones) do
			if zone:contains(x, y) then
				for j,card in ipairs(zone.cards) do
					if card:contains(x, y) then self.card = card end
				end
			end
		end
		if self.card then
			self.card.dragging.active = true
			self.card.dragging.dx = x - self.card.x
			self.card.dragging.dy = y - self.card.y
			self.card.dragging.x0 = self.card.x
			self.card.dragging.y0 = self.card.y
		end
	end
end

function game:mousereleased(x, y, button)
	if button == "l" and self.card then
		for k,zone in pairs(self.zones) do
			if zone:contains(self.card.x, self.card.y) then
				zone:addCard(self.card)
				self.card = nil
				break
			end
		end
		if self.card then
			self.card.x = self.card.dragging.x0
			self.card.y = self.card.dragging.y0
			self.card.dragging.active = false
		end
		self.card = nil
	end
end

return game
