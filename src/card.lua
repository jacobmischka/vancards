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
    o.name = json["[Name]"]
	o.critical = json["[Critical]"]
    o.basecritical = json["[Critical]"]
	o.grade = json["[Grade]"]
	o.trigger = json["[Trigger]"]
    o.nation = json["[Nation]"]
	o.race = json["[Race]"]
	o.clan = json["[Clan]"]
	o.rarity = json["[Rarity]"]
	o.unit = json["[Unit]"]
	o.power = json["[Power]"]
    o.basepower = json["[Power]"]
	o.expansion = json["[Expansion]"]
    o.skill = json["[Skill]"]
	o.shield = json["[Shield]"]
    o.baseshield = json["[Shield]"]
    o.flavortext = json["[Flavor Text]"]
	o.text = json["[Text]"]

    o.orientation = "up"
	o.rotation = "forward"

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
    if self.rotation == "forward" then
    	return x >= self.x - self.face:getWidth()/2 and x <= self.x + self.face:getWidth()/2
    	and y >= self.y - self.face:getHeight()/2 and y <= self.y + self.face:getHeight()/2
    else
        return x >= self.x - self.face:getHeight()/2 and x <= self.x + self.face:getHeight()/2
        and y >= self.y - self.face:getWidth()/2 and y <= self.y + self.face:getWidth()/2
    end
end

function card:draw()
	local rotation = 0
	if self.rotation == "sideward" then rotation = math.pi/2 end
    if self.orientation == "up" then
    	love.graphics.draw(self.sleeve.bottom, self.x, self.y, rotation, 1, 1, math.floor(self.sleeve.bottom:getWidth()/2), math.floor(self.sleeve.bottom:getHeight()/2))
    	if self.face then love.graphics.draw(self.face, self.x, self.y, rotation, 1, 1, math.floor(self.face:getWidth()/2), math.floor(self.face:getHeight()/2)) end
    	love.graphics.draw(self.sleeve.border, self.x, self.y, rotation, 1, 1, math.floor(self.sleeve.border:getWidth()/2), math.floor(self.sleeve.border:getHeight()/2))
    	love.graphics.draw(self.sleeve.top, self.x, self.y, rotation, 1, 1, math.floor(self.sleeve.top:getWidth()/2), math.floor(self.sleeve.top:getHeight()/2))
    elseif self.orientation == "down" then
        love.graphics.draw(self.sleeve.bottom, self.x, self.y, rotation, 1, 1, math.floor(self.sleeve.bottom:getWidth()/2), math.floor(self.sleeve.bottom:getHeight()/2))
        love.graphics.draw(self.sleeve.border, self.x, self.y, rotation, 1, 1, math.floor(self.sleeve.border:getWidth()/2), math.floor(self.sleeve.border:getHeight()/2))
    	love.graphics.draw(self.sleeve.top, self.x, self.y, rotation, 1, 1, math.floor(self.sleeve.top:getWidth()/2), math.floor(self.sleeve.top:getHeight()/2))
    end
end

function card:drawText()
	if self.rotation == "forward" then
		love.graphics.print(self.grade, self.x-math.floor(self.face:getWidth()/2), self.y-math.floor(self.face:getHeight()/2))
		love.graphics.print(self.power, self.x-math.floor(self.face:getWidth()/2), self.y+math.floor(self.face:getWidth()/2))
		love.graphics.print(self.shield, self.x-math.floor(self.face:getWidth()/4), self.y-math.floor(self.face:getHeight()/4), math.pi/2)
	else
		love.graphics.print(self.grade, self.x+math.floor(self.face:getHeight()/2), self.y-math.floor(self.face:getWidth()/2), math.pi/2)
		love.graphics.print(self.power, self.x-math.floor(self.face:getWidth()/2), self.y-math.floor(self.face:getWidth()/2), math.pi/2)
		love.graphics.print(self.shield, self.x+math.floor(self.face:getWidth()/4), self.y-math.floor(self.face:getWidth()/4), math.pi)
	end
end

function card:goBack()
	self.x = self.dragging.x0
	self.y = self.dragging.y0
	self.dragging.active = false
end

function card:flip(orientation)
    if orientation then self.orientation = orientation
    elseif self.orientation == "up" then self.orientation = "down"
    else self.orientation = "up" end
end

function card:rotate(rotation)
	if rotation then self.rotation = rotation
	elseif self.rotation == "forward" then self.rotation = "sideward"
	else self.rotation = "forward" end
end

return card
