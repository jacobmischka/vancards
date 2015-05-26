local card = {}

function card:new(id, face)
	o = {}
	setmetatable(o, self)
	self.__index = self

	o.sleeve = {
		bottom = love.graphics.newImage("res/sleeve_back.png"),
		border = love.graphics.newImage("res/sleeve_border.png"),
		top = love.graphics.newImage("res/sleeve_overlay.png")
	}

	o.x = 0
	o.y = 0
	face = face or "G-BT01-088EN PR.jpg"
	o.face = love.graphics.newImage("cardfaces/"..face)
	o.id = id
	o.dragging = { active = false, dx = 0, dy = 0, x0 = 0, y0 = 0}
	o.zone = nil

	return o
end

function card:init(x, y)
	self.x = x
	self.dragging.x0 = x
	self.y = y
	self.dragging.y0 = y
end

function card:contains(x, y)
	return x >= self.x - self.face:getWidth()/2 and x <= self.x + self.face:getWidth()/2
	and y >= self.y - self.face:getHeight()/2 and y <= self.y + self.face:getHeight()/2
end

function card:draw()
	love.graphics.draw(self.sleeve.bottom, self.x - 8, self.y - 8)
	if self.face then love.graphics.draw(self.face, self.x, self.y, 0, 1, 1, self.face:getWidth()/2, self.face:getHeight()/2) end
	love.graphics.draw(self.sleeve.border, self.x, self.y)
	love.graphics.draw(self.sleeve.top, self.x, self.y)
end

return card
