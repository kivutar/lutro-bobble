local spikes = {}
spikes.__index = spikes

function newSpikes(n)
	n.type = "spikes"
	if n.direction == nil then n.direction = "up" end
	if n.direction == "down" then
		n.width = 16
		n.height = 8
	elseif n.direction == "up" then
		n.y = n.y + 8
		n.width = 16
		n.height = 8
	elseif n.direction == "right" then
		n.width = 8
		n.height = 16
	elseif n.direction == "left" then
		n.x = n.x + 8
		n.width = 8
		n.height = 16
	end
	n.img = lutro.graphics.newImage("assets/spikes_"..n.direction..".png")

	return setmetatable(n, spikes)
end

function spikes:update(dt)
end

function spikes:draw()
	if self.direction == "up" then
		lutro.graphics.draw(self.img, self.x, self.y-8)
	elseif self.direction == "left" then
		lutro.graphics.draw(self.img, self.x-8, self.y)	
	else
		lutro.graphics.draw(self.img, self.x, self.y)
	end
end

function spikes:serialize()
	return {
		type = self.type,
		direction = self.direction,
		x = self.x,
		y = self.y,
		width = self.width,
		height = self.height,
	}
end

function spikes:unserialize(n)
	self.type = n.type
	self.direction = n.direction
	self.x = n.x
	self.y = n.y
	self.width = n.width
	self.height = n.height
end
