local gamestate = require("lib.hump.gamestate")
local loveframes = require("lib.LoveFrames")
local cardmenu = require("cardmenu")

local card = require("card")
local zone = require("zone")
local json = require("lib.dkjson")

local CARD_WIDTH = 126
local CARD_LENGTH = 182
local PADDING = 6
local CIRCLE_WIDTH = CARD_LENGTH + (PADDING * 2)
local GUARD_WIDTH = (CIRCLE_WIDTH * 2) + (PADDING * 2)
local GUARD_HEIGHT = CARD_WIDTH + (PADDING * 2)
local ZONE_HEIGHT = CARD_LENGTH + (PADDING * 4)
local MAT_WIDTH = (CIRCLE_WIDTH * 3) + (ZONE_HEIGHT * 2) + (PADDING * 14)
local DAMAGE_HEIGHT = ZONE_HEIGHT * 2 + PADDING
local CANVAS_WIDTH = 1920
local CANVAS_HEIGHT = 1200
local CENTER_X = CANVAS_WIDTH / 2
local CENTER_Y = CANVAS_HEIGHT / 2

love.graphics.setNewFont(24)

local game = {}

function game:init()
	self.canvas = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)

	self.bg = love.graphics.newImage("res/table_bg.png")
	self.playmat = {
		bg = love.graphics.newImage("res/playmat_bg.png"),
		shadow = love.graphics.newImage("res/playmat_shadow.png"),
		vanguard = love.graphics.newImage("res/playmat_vanguard.png"),
		rearguard = love.graphics.newImage("res/playmat_rearguard.png"),
		guardian = love.graphics.newImage("res/playmat_guardian.png"),
		zone = love.graphics.newImage("res/playmat_zone.png"),
		zoneDamage = love.graphics.newImage("res/playmat_zone_damage.png"),
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
	self.zones.p1.vanguard:init(CENTER_X - (CIRCLE_WIDTH / 2), CENTER_Y + (GUARD_HEIGHT / 2) + PADDING, CIRCLE_WIDTH, CIRCLE_WIDTH, false)
	self.zones.p1.rearBackLeft = zone:new()
	self.zones.p1.rearBackLeft:init(CENTER_X - (CIRCLE_WIDTH / 2) - PADDING - CIRCLE_WIDTH, CENTER_Y + (GUARD_HEIGHT / 2) + (PADDING * 2) + CIRCLE_WIDTH, CIRCLE_WIDTH, CIRCLE_WIDTH, false)
	self.zones.p1.rearBackCenter = zone:new()
	self.zones.p1.rearBackCenter:init(CENTER_X - (CIRCLE_WIDTH / 2), CENTER_Y + (GUARD_HEIGHT / 2) + (PADDING * 2) + CIRCLE_WIDTH, CIRCLE_WIDTH, CIRCLE_WIDTH, false)
	self.zones.p1.rearBackRight = zone:new()
	self.zones.p1.rearBackRight:init(CENTER_X + (CIRCLE_WIDTH / 2) + PADDING, CENTER_Y + (GUARD_HEIGHT / 2) + (PADDING * 2) + CIRCLE_WIDTH, CIRCLE_WIDTH, CIRCLE_WIDTH, false)
	self.zones.p1.rearFrontLeft = zone:new()
	self.zones.p1.rearFrontLeft:init(CENTER_X - (CIRCLE_WIDTH / 2) - PADDING - CIRCLE_WIDTH, CENTER_Y + (GUARD_HEIGHT / 2) + PADDING, CIRCLE_WIDTH, CIRCLE_WIDTH, false)
	self.zones.p1.rearFrontRight = zone:new()
	self.zones.p1.rearFrontRight:init(CENTER_X + (CIRCLE_WIDTH / 2) + PADDING, CENTER_Y + (GUARD_HEIGHT / 2) + PADDING, CIRCLE_WIDTH, CIRCLE_WIDTH, false)

	self.zones.p1.deck = zone:new()
	self.zones.p1.deck:init(CENTER_X + (CIRCLE_WIDTH / 2) + CIRCLE_WIDTH + (PADDING * 4), CANVAS_HEIGHT - (PADDING * 4) - (ZONE_HEIGHT * 2), ZONE_HEIGHT, ZONE_HEIGHT, false, 50)
	self.zones.p1.deck.addCard = function(self, card)
		self.__index.addCard(self, card)
		card:flip("down")
	end

	self.zones.p1.damage = zone:new()
	self.zones.p1.damage:init(431, 778, 209, 288, false)

	local f = assert(io.open("cards.json", "r"))
	local t = f:read("*all")
	f:close()
	local cards, pos, err = json.decode(t, 1, nil)

	for i=1,50 do
		self.zones.p1.deck:addCard(card:new(cards[i]))
	end

	self.frame = loveframes.Create("frame")
	self.frame:SetPos(canvasX(0), canvasY(0)):ShowCloseButton(false):SetSize(canvasX(415), canvasY(CANVAS_HEIGHT))

	--self.chat = loveframes.Create("frame")
	--self.chat:SetPos(canvasX(1505), canvasY(0)):ShowCloseButton(false):SetSize(canvasX(415), canvasY(CANVAS_HEIGHT))

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
	self.power = loveframes.Create("textinput")
    self.power:SetEditable(true):SetMultiline(false):SetUsable(numbers)
    self.power:SetText("0"):SetWidth(canvasX(200))
    self.power.OnEnter = function(object, text)
        if self.menucard then
            self.menucard.power = text
        end
    end
    self.basepower = loveframes.Create("text")
    self.basepower:SetDefaultColor(100,0,0,255):SetText("0")
	self.powerForm:AddItem(self.power):AddItem(self.basepower)
	self.list:AddItem(self.powerForm)

	self.shieldForm = loveframes.Create("form")
	self.shieldForm:SetLayoutType("horizontal"):SetName("Shield")
	self.shield = loveframes.Create("textinput")
    self.shield:SetEditable(true):SetMultiline(false):SetUsable(numbers)
    self.shield:SetText("0"):SetWidth(canvasX(200))
    self.shield.OnEnter = function(object, text)
        if self.menucard then
            self.menucard.shield = text
        end
    end
    self.baseshield = loveframes.Create("text")
    self.baseshield:SetDefaultColor(100,0,0,255):SetText("0")
    self.shieldForm:AddItem(self.shield):AddItem(self.baseshield)
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
	love.graphics.setColor(15, 15, 15)
	love.graphics.rectangle("fill", CENTER_X - (MAT_WIDTH / 2), 0, MAT_WIDTH, CANVAS_HEIGHT)
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.playmat.guardian, CENTER_X - (GUARD_WIDTH / 2), CENTER_Y - (GUARD_HEIGHT / 2))

	-- P1 rearguard & vanguard
	love.graphics.draw(self.playmat.rearguard, CENTER_X - (CIRCLE_WIDTH / 2) - PADDING - CIRCLE_WIDTH, CENTER_Y + (GUARD_HEIGHT / 2) + PADDING + CIRCLE_WIDTH + PADDING) -- P1 back left
	love.graphics.draw(self.playmat.rearguard, CENTER_X - (CIRCLE_WIDTH / 2), CENTER_Y + (GUARD_HEIGHT / 2) + PADDING + CIRCLE_WIDTH + PADDING) -- P1 back center
	love.graphics.draw(self.playmat.rearguard, CENTER_X + (CIRCLE_WIDTH / 2) + PADDING, CENTER_Y + (GUARD_HEIGHT / 2) + PADDING + CIRCLE_WIDTH + PADDING) -- P1 back right
	love.graphics.draw(self.playmat.rearguard, CENTER_X - (CIRCLE_WIDTH / 2) - PADDING - CIRCLE_WIDTH, CENTER_Y + (GUARD_HEIGHT / 2) + PADDING) -- P1 front left
	love.graphics.draw(self.playmat.rearguard, CENTER_X + (CIRCLE_WIDTH / 2) + PADDING, CENTER_Y + (GUARD_HEIGHT / 2) + PADDING) -- P1 front right
	love.graphics.draw(self.playmat.vanguard, CENTER_X - (CIRCLE_WIDTH / 2), CENTER_Y + (GUARD_HEIGHT / 2) + PADDING) -- P1 vanguard

	-- P2 rearguard & vanguard
	love.graphics.draw(self.playmat.rearguard, CENTER_X - (CIRCLE_WIDTH / 2) - PADDING - CIRCLE_WIDTH, CENTER_Y - (GUARD_HEIGHT / 2) - PADDING - CIRCLE_WIDTH - PADDING - CIRCLE_WIDTH) -- P2 back left
	love.graphics.draw(self.playmat.rearguard, CENTER_X - (CIRCLE_WIDTH / 2), CENTER_Y - (GUARD_HEIGHT / 2) - PADDING - CIRCLE_WIDTH - PADDING - CIRCLE_WIDTH) -- P2 back center
	love.graphics.draw(self.playmat.rearguard, CENTER_X + (CIRCLE_WIDTH / 2) + PADDING, CENTER_Y - (GUARD_HEIGHT / 2) - PADDING - CIRCLE_WIDTH - PADDING - CIRCLE_WIDTH) -- P2 back right
	love.graphics.draw(self.playmat.rearguard, CENTER_X - (CIRCLE_WIDTH / 2) - PADDING - CIRCLE_WIDTH, CENTER_Y - (GUARD_HEIGHT / 2) - PADDING - CIRCLE_WIDTH) -- P2 front left
	love.graphics.draw(self.playmat.rearguard, CENTER_X + (CIRCLE_WIDTH / 2) + PADDING, CENTER_Y - (GUARD_HEIGHT / 2) - PADDING - CIRCLE_WIDTH) -- P2 front right
	love.graphics.draw(self.playmat.vanguard, CENTER_X - (CIRCLE_WIDTH / 2), CENTER_Y - (GUARD_HEIGHT / 2) - PADDING - CIRCLE_WIDTH) -- P2 vanguard

	-- P1 zones
	love.graphics.draw(self.playmat.zoneDamage, CENTER_X - (CIRCLE_WIDTH / 2) - CIRCLE_WIDTH - (PADDING * 4) - ZONE_HEIGHT, CANVAS_HEIGHT - (PADDING * 3) - DAMAGE_HEIGHT) -- P1 damage
	love.graphics.draw(self.playmat.zone, CENTER_X - (CIRCLE_WIDTH / 2) - CIRCLE_WIDTH - (PADDING * 4) - ZONE_HEIGHT, CANVAS_HEIGHT - (PADDING * 4) - DAMAGE_HEIGHT - ZONE_HEIGHT) -- P1 g units
	love.graphics.draw(self.playmat.zone, CENTER_X + (CIRCLE_WIDTH / 2) + CIRCLE_WIDTH + (PADDING * 4), CANVAS_HEIGHT - (PADDING * 3) - ZONE_HEIGHT) -- P1 drop
	love.graphics.draw(self.playmat.zone, CENTER_X + (CIRCLE_WIDTH / 2) + CIRCLE_WIDTH + (PADDING * 4), CANVAS_HEIGHT - (PADDING * 4) - (ZONE_HEIGHT * 2)) -- P1 deck

	-- P2 zones
	love.graphics.draw(self.playmat.zoneDamage, CENTER_X + (CIRCLE_WIDTH / 2) + CIRCLE_WIDTH + (PADDING * 4), PADDING * 3)
	love.graphics.draw(self.playmat.zone, CENTER_X + (CIRCLE_WIDTH / 2) + CIRCLE_WIDTH + (PADDING * 4), (PADDING * 4) + DAMAGE_HEIGHT)
	love.graphics.draw(self.playmat.zone, CENTER_X - (CIRCLE_WIDTH / 2) - CIRCLE_WIDTH - (PADDING * 4) - ZONE_HEIGHT, PADDING * 3)
	love.graphics.draw(self.playmat.zone, CENTER_X - (CIRCLE_WIDTH / 2) - CIRCLE_WIDTH - (PADDING * 4) - ZONE_HEIGHT, (PADDING * 4) + ZONE_HEIGHT)


	-- Render cards here
	for i,zone in pairs(self.zones.p1) do
		zone:draw()
	end
	if self.card then self.card:draw() end

	-- Scale render target to screen
	love.graphics.setCanvas()
	love.graphics.draw(self.canvas, love.graphics.newQuad(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT, love.graphics.getWidth(), love.graphics.getHeight()))

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
    self.menucard = card
    self.frame:SetName(self.card.name)
    self.image:SetImage(self.card.face)
	self.power:SetText(self.card.power)
    self.basepower:SetText(self.card.basepower)
	self.shield:SetText(self.card.shield)
    self.baseshield:SetText(self.card.baseshield)
    self.text:SetText(self.card.text)
end

function game:mousepressed(x, y, button)
	loveframes.mousepressed(x, y, button)
	x = (x/love.graphics.getWidth())*CANVAS_WIDTH
	y = (y/love.graphics.getHeight())*CANVAS_HEIGHT
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
	-- x = (x/love.graphics.getWidth())*CANVAS_WIDTH
	-- y = (y/love.graphics.getHeight())*CANVAS_HEIGHT
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
	return (love.mouse.getX() / love.graphics.getWidth()) * CANVAS_WIDTH
end

function mouseY()
	return (love.mouse.getY() / love.graphics.getHeight()) * CANVAS_HEIGHT
end

function canvasX(x)
	return (x/CANVAS_WIDTH) * love.graphics.getWidth()
end

function canvasY(y)
	return(y/CANVAS_HEIGHT) * love.graphics.getHeight()
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
