local spikes = {}
spikes.__index = spikes

function newSpikes(n)
	n.type = ENT_SPIKES
	if n.direction == nil then n.direction = DIR_UP end
	if n.direction == DIR_DOWN then
		n.width = 16
		n.height = 8
		n.img = IMG_spikes_down
	elseif n.direction == DIR_UP then
		n.y = n.y + 8
		n.width = 16
		n.height = 8
		n.img = IMG_spikes_up
	elseif n.direction == DIR_RIGHT then
		n.width = 8
		n.height = 16
		n.img = IMG_spikes_right
	elseif n.direction == DIR_LEFT then
		n.x = n.x + 8
		n.width = 8
		n.height = 16
		n.img = IMG_spikes_left
	end

	return setmetatable(n, spikes)
end

function spikes:draw()
	if self.direction == DIR_UP then
		love.graphics.draw(self.img, self.x, self.y-8)
	elseif self.direction == DIR_LEFT then
		love.graphics.draw(self.img, self.x-8, self.y)
	else
		love.graphics.draw(self.img, self.x, self.y)
	end
end

function spikes:serialize()
	return {
		uid = self.uid,
		type = self.type,
		direction = self.direction,
		x = self.x,
		y = self.y,
		width = self.width,
		height = self.height,
	}
end

function spikes:unserialize(n)
	self.uid = n.uid
	self.type = n.type
	self.direction = n.direction
	self.x = n.x
	self.y = n.y
	self.width = n.width
	self.height = n.height
end
