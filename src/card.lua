local card = {}

function card:new(json)
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

	json["[Image]"] = json["[Image]"] or "G-BT01-088EN PR.jpg"
	o.face = love.graphics.newImage("cardfaces/"..json["[Image]"])
	o.id = json["[Number]"]
	o.critical = json["[Critical]"]
	o.grade = json["[Grade]"]
	o.trigger = json["[Trigger]"]
	o.race = json["[Race]"]
	o.clan = json["[Clan]"]
	o.rarity = json["[Rarity]"]
	o.unit = json["[Unit]"]
	o.power = json["[Power]"]
	o.expansion = json["[Expansion]"]
	o.shield = json["[Shield]"]
	o.text = json["[Text]"]

    o.orientation = "up"

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
    if self.orientation == "up" then
    	love.graphics.draw(self.sleeve.bottom, self.x, self.y, 0, 1, 1, 70, 99)
    	if self.face then love.graphics.draw(self.face, self.x, self.y, 0, 1, 1, math.floor(self.face:getWidth()/2), math.floor(self.face:getHeight()/2)) end
    	love.graphics.draw(self.sleeve.border, self.x, self.y, 0, 1, 1, 70, 99)
    	love.graphics.draw(self.sleeve.top, self.x, self.y, 0, 1, 1, 70, 99)
    elseif self.orientation == "down" then
        love.graphics.draw(self.sleeve.bottom, self.x, self.y, 0, 1, 1, 70, 99)
    end
end

function card:flip(orientation)
    if orientation then self.orientation = orientation
    elseif self.orientation == "up" then self.orientation = "down"
    else self.orientation = "up" end
end

return card
