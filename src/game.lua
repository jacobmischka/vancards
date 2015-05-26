local card = require("card")
local zone = require("zone")
local json = require("lib.dkjson")

local game = {}

function game:init()
	self.canvas = love.graphics.newCanvas(1920, 1080)

	self.bg = love.graphics.newImage("res/table_bg.png")
	self.playmat = {
		bg = love.graphics.newImage("res/playmat_bg.png"),
		shadow = love.graphics.newImage("res/playmat_shadow.png"),
		vanguard = love.graphics.newImage("res/playmat_vanguard.png"),
		rearguard = love.graphics.newImage("res/playmat_rearguard.png"),
		guardian = love.graphics.newImage("res/playmat_guardian.png")
	}

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
	self.zones.hand:init(0, 500, 720, 200, 7)
	self.zones.deck = zone:new()
	self.zones.deck:init(100, 100, 150, 200, 50)

	local f = assert(io.open("cards.json", "r"))
	local t = f:read("*all")
	f:close()
	local cards, pos, err = json.decode(t, 1, nil)

	for i=1,50 do
		self.zones.deck:addCard(card:new(cards[i]))
	end
end

function game:enter()

end

function game:update(dt)
	if self.card and self.card.dragging.active then
		self.card.x = mouseX() - self.card.dragging.dx
		self.card.y = mouseY() - self.card.dragging.dy
	end
end

function game:draw()
	love.graphics.setCanvas(self.canvas)
	self.canvas:clear()

	-- Draw playmat & table
	love.graphics.draw(self.bg, 0, 0)
	love.graphics.draw(self.playmat.bg, 417, 0)
	love.graphics.draw(self.playmat.bg, 417, 540)
	love.graphics.draw(self.playmat.shadow, 405, 0)
	love.graphics.draw(self.playmat.guardian, 750, 433)

	-- P1 rearguard & vanguard
	love.graphics.draw(self.playmat.rearguard, 663, 880) -- P1 back left
	love.graphics.draw(self.playmat.rearguard, 869, 880) -- P1 back center
	love.graphics.draw(self.playmat.rearguard, 1075, 880) -- P1 back right
	love.graphics.draw(self.playmat.rearguard, 663, 674) -- P1 front left
	love.graphics.draw(self.playmat.rearguard, 1075, 674) -- P1 front right
	love.graphics.draw(self.playmat.vanguard, 841, 646) -- P1 vanguard

	-- P2 rearguard & vanguard
	love.graphics.draw(self.playmat.rearguard, 663, 18) -- P1 back left
	love.graphics.draw(self.playmat.rearguard, 869, 18) -- P1 back center
	love.graphics.draw(self.playmat.rearguard, 1075, 18) -- P1 back right
	love.graphics.draw(self.playmat.rearguard, 663, 224) -- P1 front left
	love.graphics.draw(self.playmat.rearguard, 1075, 224) -- P1 front right
	love.graphics.draw(self.playmat.vanguard, 841+self.playmat.vanguard:getWidth(), 196+self.playmat.vanguard:getHeight(), math.pi, 1, 1) -- P1 vanguard

	-- Render cards here
	for i,zone in pairs(self.zones) do
		zone:draw()
	end
    if self.card then self.card:draw() end

	-- Scale render target to screen
	love.graphics.setCanvas()
	love.graphics.draw(self.canvas, love.graphics.newQuad(0, 0, 1920, 1080, love.graphics.getWidth(), love.graphics.getHeight()))
end

function game:mousepressed(x, y, button)
    x = (x/love.graphics.getWidth())*1920
    y = (y/love.graphics.getHeight())*1080
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
    x = (x/love.graphics.getWidth())*1920
    y = (y/love.graphics.getHeight())*1080
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

function mouseX()
	return (love.mouse.getX() / love.graphics.getWidth()) * 1920
end

function mouseY()
	return (love.mouse.getY() / love.graphics.getHeight()) * 1080
end

return game
