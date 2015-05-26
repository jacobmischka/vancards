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
	self.sleeve = {
		bottom = love.graphics.newImage("res/sleeve_back.png"),
		border = love.graphics.newImage("res/sleeve_border.png"),
		top = love.graphics.newImage("res/sleeve_overlay.png")
	}

	self.cards = {}
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
end

function game:enter()

end

function game:update(dt)

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
	love.graphics.draw(self.playmat.vanguard, 841, 196) -- P1 vanguard

	-- Scale render target to screen
	love.graphics.setCanvas()
	love.graphics.draw(self.canvas, love.graphics.newQuad(0, 0, 1920, 1080, love.graphics.getWidth(), love.graphics.getHeight()))
end

return game
