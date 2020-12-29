local cross = {}
cross.__index = cross

function newCross(n)
	n.type = ENT_CROSS
	n.width = 16
	n.height = 16
	n.anim = newAnimation(IMG_cross,  16, 16, 1, 10)

	return setmetatable(n, cross)
end

function cross:update(dt)
	self.anim:update(dt)
end

function cross:draw()
	self.anim:draw(self.x, self.y)
end

function cross:serialize()
	return {
		type = self.type,
		x = self.x,
		y = self.y,
	}
end

function cross:unserialize(n)
	self.type = n.type
	self.x = n.x
	self.y = n.y
end
