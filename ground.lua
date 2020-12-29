local ground = {}
ground.__index = ground

function newGround(n)
	n.type = ENT_GROUND
	n.width = 16
	n.height = 16
	n.img = IMG_ground

	if not solid_at(n.x, n.y-1) and n.y ~= 0 then n.img = IMG_ground_top end

	return setmetatable(n, ground)
end

function ground:draw()
	love.graphics.draw(self.img, self.x, self.y)
end

function ground:serialize()
	return {
		type = self.type,
		x = self.x,
		y = self.y,
	}
end

function ground:unserialize(n)
	self.type = n.type
	self.x = n.x
	self.y = n.y
end
