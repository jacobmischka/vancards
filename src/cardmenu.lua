local gamestate = require("lib.hump.gamestate")
local loveframes = require("lib.LoveFrames")
local cardmenu = {}

function cardmenu:init()
	self.frame = loveframes.Create("frame")
	self.frame:ShowCloseButton(false):SetSize(400, 500)

	self.list = loveframes.Create("list", self.frame)
	self.list:SetPos(50, 50):SetSize(300, 350)

	self.exitButton = loveframes.Create("button", self.frame)
	self.exitButton:SetSize(50, 25):SetY(450):CenterX():SetText("Exit"):SetClickable(true)
	self.exitButton.OnClick = function(object, x, y)
		gamestate.pop()
	end
	self.name = loveframes.Create("text", self.frame)
	self.name:SetText(""):SetY(30, true)

	local numbers = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"}

	self.powerForm = loveframes.Create("form")
	self.powerForm:SetLayoutType("horizontal"):SetName("Power")
	self.power = loveframes.Create("textinput")
	self.power:SetEditable(true):SetMultiline(false):SetUsable(numbers)
	self.powerForm:AddItem(self.power):CenterX()
	self.list:AddItem(self.powerForm)

	self.shieldForm = loveframes.Create("form")
	self.shieldForm:SetLayoutType("horizontal"):SetName("Shield")
	self.shield = loveframes.Create("textinput")
	self.shield:SetEditable(true):SetMultiline(false):SetUsable(numbers)
	self.shieldForm:AddItem(self.shield):CenterX()
	self.list:AddItem(self.shieldForm)

end

function cardmenu:enter(game, card)
	self.game = game
	self.card = card
	self.name:SetText(self.card.name):CenterX()
	self.power:SetText(self.card.power)
	self.shield:SetText(self.card.shield)
end

function cardmenu:leave()
	self.card.power = self.power:GetText()
	self.card.shield = self.shield:GetText()
end

function cardmenu:update(dt)
	loveframes.update(dt)
end

function cardmenu:draw()
	self.game:draw()
	loveframes.draw()
end

function cardmenu:keypressed(key, code)
	loveframes.keypressed(key, code)
end

function cardmenu:keyreleased(key)
	if key == "escape" then
		gamestate.pop()
	end
	loveframes.keyreleased(key)
end

function cardmenu:mousepressed(x, y, button)
	loveframes.mousepressed(x, y, button)
end

function cardmenu:mousereleased(x, y, button)
	loveframes.mousereleased(x, y, button)
end

function cardmenu:textinput(text)
	loveframes.textinput(text)
end

return cardmenu
