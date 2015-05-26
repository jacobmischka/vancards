local gamestate = require("lib.hump.gamestate")
local loveframes = require("lib.LoveFrames")
local cardmenu = {}

function cardmenu:init()
	self.frame = loveframes.Create("frame")
	self.frame:ShowCloseButton(false)
	self.list = loveframes.Create("list", self.frame)
	self.list:Center()
	self.exitButton = loveframes.Create("button", self.list)
	self.exitButton:SetSize(100, 100):SetText("Exit"):SetClickable(true)
	self.exitButton.OnClick = function(object, x, y)
		gamestate.pop()
	end
	self.text = loveframes.Create("text", self.list)
	self.text:SetText("")
end

function cardmenu:enter(game, card)
	self.game = game
	self.text:SetText(card.text)
end

function cardmenu:leave()

end

function cardmenu:update(dt)
	loveframes.update(dt)
end

function cardmenu:draw()
	self.game:draw()
	loveframes.draw()
end

function cardmenu:keyreleased(key)
	if key == "escape" then
		gamestate.pop()
	end
end

function cardmenu:mousepressed(x, y, button)
	loveframes.mousepressed(x, y, button)
end

function cardmenu:mousereleased(x, y, button)
	loveframes.mousereleased(x, y, button)
end

return cardmenu
