local gamestate = require("lib.hump.gamestate")
local loveframes = require("lib.LoveFrames")
local cardmenu = require("cardmenu")

local card = require("card")
local zone = require("zone")
local json = require("lib.dkjson")

CARD_WIDTH = 126
CARD_LENGTH = 182
PADDING = 6
CIRCLE_WIDTH = CARD_LENGTH + (PADDING * 2)
GUARD_WIDTH = (CIRCLE_WIDTH * 2) + (PADDING * 2)
GUARD_HEIGHT = CARD_WIDTH + (PADDING * 2)
ZONE_HEIGHT = CARD_LENGTH + (PADDING * 4)
MAT_WIDTH = (CIRCLE_WIDTH * 3) + (ZONE_HEIGHT * 2) + (PADDING * 14)
DAMAGE_HEIGHT = ZONE_HEIGHT * 2 + PADDING
CANVAS_WIDTH = 1920
CANVAS_HEIGHT = 1200
FRAME_WIDTH = (CANVAS_WIDTH - MAT_WIDTH) / 2
CENTER_X = CANVAS_WIDTH / 2
CENTER_Y = CANVAS_HEIGHT / 2
HAND_OFFSET = 60

local game = {}

function game:init()
    math.randomseed(os.time())
	self.canvas = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)

	self.guiFont = love.graphics.newFont("res/font.ttf", 12)
	self.cardFont = love.graphics.newFont("res/font.ttf", 24)
	love.graphics.setFont(self.cardFont)

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
	self.zones.p1.vanguard:init(CENTER_X - (CIRCLE_WIDTH / 2), CENTER_Y + (GUARD_HEIGHT / 2) + PADDING - HAND_OFFSET, CIRCLE_WIDTH, CIRCLE_WIDTH, "up", "forward")
	self.zones.p1.rearBackLeft = zone:new()
	self.zones.p1.rearBackLeft:init(CENTER_X - (CIRCLE_WIDTH / 2) - PADDING - CIRCLE_WIDTH, CENTER_Y + (GUARD_HEIGHT / 2) + (PADDING * 2) + CIRCLE_WIDTH - HAND_OFFSET, CIRCLE_WIDTH, CIRCLE_WIDTH, "up", "forward")
	self.zones.p1.rearBackCenter = zone:new()
	self.zones.p1.rearBackCenter:init(CENTER_X - (CIRCLE_WIDTH / 2), CENTER_Y + (GUARD_HEIGHT / 2) + (PADDING * 2) + CIRCLE_WIDTH - HAND_OFFSET, CIRCLE_WIDTH, CIRCLE_WIDTH, "up", "forward")
	self.zones.p1.rearBackRight = zone:new()
	self.zones.p1.rearBackRight:init(CENTER_X + (CIRCLE_WIDTH / 2) + PADDING, CENTER_Y + (GUARD_HEIGHT / 2) + (PADDING * 2) + CIRCLE_WIDTH - HAND_OFFSET, CIRCLE_WIDTH, CIRCLE_WIDTH, "up", "forward")
	self.zones.p1.rearFrontLeft = zone:new()
	self.zones.p1.rearFrontLeft:init(CENTER_X - (CIRCLE_WIDTH / 2) - PADDING - CIRCLE_WIDTH, CENTER_Y + (GUARD_HEIGHT / 2) + PADDING - HAND_OFFSET, CIRCLE_WIDTH, CIRCLE_WIDTH, "up", "forward")
	self.zones.p1.rearFrontRight = zone:new()
	self.zones.p1.rearFrontRight:init(CENTER_X + (CIRCLE_WIDTH / 2) + PADDING, CENTER_Y + (GUARD_HEIGHT / 2) + PADDING - HAND_OFFSET, CIRCLE_WIDTH, CIRCLE_WIDTH, "up", "forward")

	self.zones.p1.deck = zone:new()
	self.zones.p1.deck:init(CENTER_X + (CIRCLE_WIDTH / 2) + CIRCLE_WIDTH + (PADDING * 4), CANVAS_HEIGHT - (PADDING * 4) - (ZONE_HEIGHT * 2), ZONE_HEIGHT, ZONE_HEIGHT, "down", "forward", 50, "none")

	self.zones.p1.drop = zone:new()
	self.zones.p1.drop:init(CENTER_X + (CIRCLE_WIDTH / 2) + CIRCLE_WIDTH + (PADDING * 4), CANVAS_HEIGHT - (PADDING * 3) - ZONE_HEIGHT, ZONE_HEIGHT, ZONE_HEIGHT, "up", "forward", 60, "none")

	self.zones.p1.damage = zone:new()
	self.zones.p1.damage:init(CENTER_X - (CIRCLE_WIDTH / 2) - CIRCLE_WIDTH - (PADDING * 4) - ZONE_HEIGHT, CANVAS_HEIGHT - (PADDING * 3) - DAMAGE_HEIGHT, ZONE_HEIGHT, DAMAGE_HEIGHT, "up", "sideward", 6, "flip", function(i, card, zone)
		card.x = zone.x + (CARD_LENGTH / 2) + (PADDING * 2)
		card.y = zone.y + math.floor((CARD_WIDTH / 2) + (PADDING * 2) - 1 + ((i - 1) * ((DAMAGE_HEIGHT - CARD_WIDTH - (PADDING * 4)) / 5)))
	end)

	self.zones.p1.gunit = zone:new()
	self.zones.p1.gunit:init(CENTER_X - (CIRCLE_WIDTH / 2) - CIRCLE_WIDTH - (PADDING * 4) - ZONE_HEIGHT, CANVAS_HEIGHT - (PADDING * 4) - DAMAGE_HEIGHT - ZONE_HEIGHT, ZONE_HEIGHT, ZONE_HEIGHT, "up", "forward", 8, "flip", function(i, card, zone)
		card.x = zone.x + math.floor((CARD_WIDTH / 2) + (PADDING * 2) + ((i - 1) * ((ZONE_HEIGHT - CARD_WIDTH - (PADDING * 2)) / 8.5)))
		card.y = zone.y + (CARD_LENGTH / 2) + (PADDING * 2)
	end)

    self.zones.p1.hand = zone:new()
	self.zones.p1.hand:init(CENTER_X - (CIRCLE_WIDTH / 2) - CIRCLE_WIDTH, CANVAS_HEIGHT - CARD_LENGTH, (CIRCLE_WIDTH * 3) + (PADDING * 2), CARD_LENGTH, "up", "forward", 60, "none", function(i, card, zone)
		local max = zone.width - CARD_WIDTH
		local w = #zone.cards * CARD_WIDTH + (PADDING * (#zone.cards - 1))
		local s = CARD_WIDTH + PADDING
		if w > max then
			s = max / #zone.cards
		end
		card.x = zone.x + math.floor((CARD_WIDTH / 2) + (max / 2) + ((i - 1) * s) - ((s * (#zone.cards - 1)) / 2) - PADDING)
		card.y = zone.y + (CARD_LENGTH / 2)
	end)

	local f = assert(io.open("cards.json", "r"))
	local t = f:read("*all")
	f:close()
	local cards, pos, err = json.decode(t, 1, nil)

	for i=1,50 do
		self.zones.p1.deck:addCard(card:new(cards[i]))
	end

	self.frame = loveframes.Create("frame")
	self.frame:SetPos(canvasX(0), canvasY(0)):ShowCloseButton(false):SetSize(canvasX(FRAME_WIDTH), canvasY(CANVAS_HEIGHT))
    self.frame:SetDraggable(false)
    self.frame:SetName("Info")

    self.toolbox = loveframes.Create("frame")
    self.toolbox:SetPos(canvasX(FRAME_WIDTH + MAT_WIDTH), canvasY(0)):ShowCloseButton(false):SetSize(canvasX(FRAME_WIDTH), canvasY(CANVAS_HEIGHT / 2))
    self.toolbox:SetDraggable(false)
    self.toolbox:SetName("Toolbox")
    self.toolList = loveframes.Create("list", self.toolbox)
    self.shuffle = loveframes.Create("button")
    self.shuffle:SetText("Shuffle"):SetClickable(true)
    self.toolList:AddItem(self.shuffle)
    local deck = self.zones.p1.deck
    self.shuffle.OnClick = function(object, x, y)
        shuffle(deck)
    end


	self.chat = loveframes.Create("frame")
	self.chat:SetPos(canvasX(FRAME_WIDTH + MAT_WIDTH), canvasY(CANVAS_HEIGHT / 2)):ShowCloseButton(false):SetSize(canvasX(FRAME_WIDTH), canvasY(CANVAS_HEIGHT / 2))
	self.chat:SetDraggable(false)
	self.chat:SetName("Chat")

	self.list = loveframes.Create("list", self.frame)
	self.list:SetPos(canvasX(14), canvasY(49)):SetSize(canvasX(388), canvasY(1017))

	-- self.name = loveframes.Create("text", self.frame)
	-- self.name:SetText(""):SetY(30, true)

	local numbers = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"}

    self.imageForm = loveframes.Create("form")
    self.imageForm:SetLayoutType("horizontal"):SetName("")
	self.image = loveframes.Create("image")
	self.image:SetImage("res/sleeve_back.png")
    self.grade = loveframes.Create("text")
    self.grade:SetText("0")
    self.imageForm:AddItem(self.image):AddItem(self.grade)
	self.list:AddItem(self.imageForm)

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

    self.criticalForm = loveframes.Create("form")
    self.criticalForm:SetLayoutType("horizontal"):SetName("Critical")
    self.critical = loveframes.Create("textinput")
    self.critical:SetEditable(true):SetMultiline(false):SetUsable(numbers)
    self.critical:SetText("0"):SetWidth(canvasX(200))
    self.critical.OnEnter = function(object, text)
        if self.menucard then
            self.menucard.critical = text
        end
    end
    self.basecritical = loveframes.Create("text")
    self.basecritical:SetDefaultColor(100,0,0,255):SetText("0")
    self.criticalForm:AddItem(self.critical):AddItem(self.basecritical)
    self.list:AddItem(self.criticalForm)

    self.skillForm = loveframes.Create("form")
    self.skillForm:SetLayoutType("horizontal"):SetName("Skill")
    self.skill = loveframes.Create("text")
    self.skill:SetText("-")
    self.skillForm:AddItem(self.skill)
    self.list:AddItem(self.skillForm)

    self.triggerForm = loveframes.Create("form")
    self.triggerForm:SetLayoutType("horizontal"):SetName("Trigger")
    self.trigger = loveframes.Create("text")
    self.trigger:SetText("-")
    self.triggerForm:AddItem(self.trigger)
    self.list:AddItem(self.triggerForm)

    self.nationForm = loveframes.Create("form")
    self.nationForm:SetLayoutType("horizontal"):SetName("Nation")
    self.nation = loveframes.Create("text")
    self.nation:SetText("-")
    self.nationForm:AddItem(self.nation)
    self.list:AddItem(self.nationForm)

    self.raceForm = loveframes.Create("form")
    self.raceForm:SetLayoutType("horizontal"):SetName("Race")
    self.race = loveframes.Create("text")
    self.race:SetText("-")
    self.raceForm:AddItem(self.race)
    self.list:AddItem(self.raceForm)

    self.clanForm = loveframes.Create("form")
    self.clanForm:SetLayoutType("horizontal"):SetName("Clan")
    self.clan = loveframes.Create("text")
    self.clan:SetText("-")
    self.clanForm:AddItem(self.clan)
    self.list:AddItem(self.clanForm)

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
	love.graphics.draw(self.playmat.guardian, CENTER_X - (GUARD_WIDTH / 2), CENTER_Y - (GUARD_HEIGHT / 2) - HAND_OFFSET)

	-- P1 rearguard & vanguard
	love.graphics.draw(self.playmat.rearguard, CENTER_X - (CIRCLE_WIDTH / 2) - PADDING - CIRCLE_WIDTH, CENTER_Y + (GUARD_HEIGHT / 2) + PADDING + CIRCLE_WIDTH + PADDING - HAND_OFFSET) -- P1 back left
	love.graphics.draw(self.playmat.rearguard, CENTER_X - (CIRCLE_WIDTH / 2), CENTER_Y + (GUARD_HEIGHT / 2) + PADDING + CIRCLE_WIDTH + PADDING - HAND_OFFSET) -- P1 back center
	love.graphics.draw(self.playmat.rearguard, CENTER_X + (CIRCLE_WIDTH / 2) + PADDING, CENTER_Y + (GUARD_HEIGHT / 2) + PADDING + CIRCLE_WIDTH + PADDING - HAND_OFFSET) -- P1 back right
	love.graphics.draw(self.playmat.rearguard, CENTER_X - (CIRCLE_WIDTH / 2) - PADDING - CIRCLE_WIDTH, CENTER_Y + (GUARD_HEIGHT / 2) + PADDING - HAND_OFFSET) -- P1 front left
	love.graphics.draw(self.playmat.rearguard, CENTER_X + (CIRCLE_WIDTH / 2) + PADDING, CENTER_Y + (GUARD_HEIGHT / 2) + PADDING - HAND_OFFSET) -- P1 front right
	love.graphics.draw(self.playmat.vanguard, CENTER_X - (CIRCLE_WIDTH / 2), CENTER_Y + (GUARD_HEIGHT / 2) + PADDING - HAND_OFFSET) -- P1 vanguard

	-- P2 rearguard & vanguard
	love.graphics.draw(self.playmat.rearguard, CENTER_X - (CIRCLE_WIDTH / 2) - PADDING - CIRCLE_WIDTH, CENTER_Y - (GUARD_HEIGHT / 2) - PADDING - CIRCLE_WIDTH - PADDING - CIRCLE_WIDTH - HAND_OFFSET) -- P2 back left
	love.graphics.draw(self.playmat.rearguard, CENTER_X - (CIRCLE_WIDTH / 2), CENTER_Y - (GUARD_HEIGHT / 2) - PADDING - CIRCLE_WIDTH - PADDING - CIRCLE_WIDTH - HAND_OFFSET) -- P2 back center
	love.graphics.draw(self.playmat.rearguard, CENTER_X + (CIRCLE_WIDTH / 2) + PADDING, CENTER_Y - (GUARD_HEIGHT / 2) - PADDING - CIRCLE_WIDTH - PADDING - CIRCLE_WIDTH - HAND_OFFSET) -- P2 back right
	love.graphics.draw(self.playmat.rearguard, CENTER_X - (CIRCLE_WIDTH / 2) - PADDING - CIRCLE_WIDTH, CENTER_Y - (GUARD_HEIGHT / 2) - PADDING - CIRCLE_WIDTH - HAND_OFFSET) -- P2 front left
	love.graphics.draw(self.playmat.rearguard, CENTER_X + (CIRCLE_WIDTH / 2) + PADDING, CENTER_Y - (GUARD_HEIGHT / 2) - PADDING - CIRCLE_WIDTH - HAND_OFFSET) -- P2 front right
	love.graphics.draw(self.playmat.vanguard, CENTER_X - (CIRCLE_WIDTH / 2), CENTER_Y - (GUARD_HEIGHT / 2) - PADDING - CIRCLE_WIDTH - HAND_OFFSET) -- P2 vanguard

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
    self.grade:SetText(self.card.grade)
	self.power:SetText(self.card.power)
    self.basepower:SetText(self.card.basepower)
	self.shield:SetText(self.card.shield)
    self.baseshield:SetText(self.card.baseshield)
    self.critical:SetText(self.card.critical)
    self.basecritical:SetText(self.card.basecritical)
    self.skill:SetText(self.card.skill)
    self.trigger:SetText(self.card.trigger)
    self.nation:SetText(self.card.nation)
    self.race:SetText(self.card.race)
    self.clan:SetText(self.card.clan)
    self.text:SetText(self.card.text)
end

function shuffle(deck)
    local cards = deck.cards
    deck.cards = {}
    for i=1,#cards do
        table.insert(deck.cards, table.remove(cards, math.random(1, #cards)))
    end
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
			if zone:contains(self.card.x, self.card.y) and zone ~= self.card.zone then
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
		card.zone:execute(card)
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
