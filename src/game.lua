local gamestate = require("lib.hump.gamestate")
local loveframes = require("lib.LoveFrames")
local cardmenu = require("cardmenu")

local card = require("card")
local zone = require("zone")
local json = require("lib.dkjson")

love.graphics.setNewFont(24)

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
		p1 = {
			vanguard = nil,
			rearFrontLeft = nil,
			rearFrontRight = nil,
			rearBackLeft = nil,
			rearBackCenter = nil,
			rearBackRight = nil,
			deck = nil,
			drop = nil,
			trigger = nil,
			damage = nil,
			gunit = nil,
			hand = nil
		},
		p2 = {
			vanguard = nil,
			rearFrontLeft = nil,
			rearFrontRight = nil,
			rearBackLeft = nil,
			rearBackCenter = nil,
			rearBackRight = nil,
			deck = nil,
			drop = nil,
			trigger = nil,
			damage = nil,
			gunit = nil,
			hand = nil
		},
	}

	self.zones.p1.vanguard = zone:new()
	self.zones.p1.vanguard:init(841, 646, 238, 238, false)
	self.zones.p1.rearBackLeft = zone:new()
	self.zones.p1.rearBackLeft:init(663, 880, 182, 182, false)
	self.zones.p1.rearBackCenter = zone:new()
	self.zones.p1.rearBackCenter:init(869, 880, 182, 182, false)
	self.zones.p1.rearBackRight = zone:new()
	self.zones.p1.rearBackRight:init(1075, 880, 182, 182, false)
	self.zones.p1.rearFrontLeft = zone:new()
	self.zones.p1.rearFrontLeft:init(663, 674, 182, 182, false)
	self.zones.p1.rearFrontRight = zone:new()
	self.zones.p1.rearFrontRight:init(1075, 674, 182, 182, false)

	self.zones.p1.deck = zone:new()
	self.zones.p1.deck:init(1300, 800, 150, 200, true, 50)
	self.zones.p1.deck.addCard = function(self, card)
		self.__index.addCard(self, card)
		card:flip("down")
	end

	self.zones.p1.damage = zone:new()
	self.zones.p1.damage:init(431, 778, 209, 288, true)

	local f = assert(io.open("cards.json", "r"))
	local t = f:read("*all")
	f:close()
	local cards, pos, err = json.decode(t, 1, nil)

	for i=1,50 do
		self.zones.p1.deck:addCard(card:new(cards[i]))
	end

	self.frame = loveframes.Create("frame")
	self.frame:SetPos(canvasX(0), canvasY(0)):ShowCloseButton(false):SetSize(canvasX(415), canvasY(1080))

	--self.chat = loveframes.Create("frame")
	--self.chat:SetPos(canvasX(1505), canvasY(0)):ShowCloseButton(false):SetSize(canvasX(415), canvasY(1080))

	self.list = loveframes.Create("list", self.frame)
	self.list:SetPos(canvasX(14), canvasY(49)):SetSize(canvasX(388), canvasY(1017))

	-- self.name = loveframes.Create("text", self.frame)
	-- self.name:SetText(""):SetY(30, true)

	local numbers = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"}

	self.image = loveframes.Create("image")
	self.image:SetImage("res/sleeve_back.png")
	self.list:AddItem(self.image)

	self.powerForm = loveframes.Create("form")
	self.powerForm:SetLayoutType("horizontal"):SetName("Power")
	self.power = loveframes.Create("text")
	self.power:SetText("0")
	self.powerForm:AddItem(self.power)
	self.list:AddItem(self.powerForm)

	self.shieldForm = loveframes.Create("form")
	self.shieldForm:SetLayoutType("horizontal"):SetName("Shield")
	self.shield = loveframes.Create("text")
	self.shield:SetText("0")
	self.shieldForm:AddItem(self.shield)
	self.list:AddItem(self.shieldForm)

	self.text = loveframes.Create("text")
	self.list:AddItem(self.text)

end

function game:enter()

end

function game:resume()
	loveframes.SetState("none")
end

function game:update(dt)
	if self.card and self.card.dragging.active then
		self.card.x = mouseX() - self.card.dragging.dx
		self.card.y = mouseY() - self.card.dragging.dy
	end

	loveframes.update(dt)
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
	for i,zone in pairs(self.zones.p1) do
		zone:draw()
	end
	if self.card then self.card:draw() end

	-- Scale render target to screen
	love.graphics.setCanvas()
	love.graphics.draw(self.canvas, love.graphics.newQuad(0, 0, 1920, 1080, love.graphics.getWidth(), love.graphics.getHeight()))

	loveframes.draw()
end

function game:clickedCard(x, y)
	local returncard
	for i,zone in pairs(self.zones.p1) do
		if zone:contains(x, y) then
			for j,card in ipairs(zone.cards) do
				if card:contains(x, y) then returncard = card end
			end
		end
	end
	return returncard
end

function game:updateCardmenu(card)
	self.frame:SetName(self.card.name)
	self.image:SetImage(self.card.face)
	self.power:SetText(self.card.power)
	self.shield:SetText(self.card.shield)
	self.text:SetText(self.card.text)
end

function game:mousepressed(x, y, button)
	loveframes.mousepressed(x, y, button)
	x = (x/love.graphics.getWidth())*1920
	y = (y/love.graphics.getHeight())*1080
	self.card = nil
	self.card = self:clickedCard(x, y)
	if button == "l" then
		if self.card then
			if self.card and self.card.orientation == "up" then
				self:updateCardmenu(self.card)
			end
			self.card.dragging.active = true
			self.card.dragging.dx = x - self.card.x
			self.card.dragging.dy = y - self.card.y
			self.card.dragging.x0 = self.card.x
			self.card.dragging.y0 = self.card.y
		end
	end

end

function game:mousereleased(x, y, button)
	loveframes.mousereleased(x, y, button)
	-- x = (x/love.graphics.getWidth())*1920
	-- y = (y/love.graphics.getHeight())*1080
	if button == "l" and self.card then
		for k,zone in pairs(self.zones.p1) do
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
	elseif button == "r" and self.card then
		local card = self.card
		if self.cardcontext then
			self.cardcontext:Remove()
			self.cardcontext = nil
		end
		self.cardcontext = loveframes.Create("menu")
		self.cardcontext:AddOption("Rotate", false, function() card:rotate() end)
		self.cardcontext:AddOption("Flip", false, function() card:flip() end)
		self.cardcontext:SetPos(x, y)
	end
	self.card = nil
end

function mouseX()
	return (love.mouse.getX() / love.graphics.getWidth()) * 1920
end

function mouseY()
	return (love.mouse.getY() / love.graphics.getHeight()) * 1080
end

function canvasX(x)
	return (x/1920) * love.graphics.getWidth()
end

function canvasY(y)
	return(y/1080) * love.graphics.getHeight()
end

function game:keypressed(key, code)
	loveframes.keypressed(key, code)
end

function game:keyreleased(key)
	loveframes.keyreleased(key)
end

function game:textinput(text)
	loveframes.textinput(text)
end

return game
