local shadow = {}
shadow.__index = shadow

function newShadow(n)
	n.type = ENT_SHADOW
	n.width = 16
	n.height = 16
	n.img = IMG_shadow

	return setmetatable(n, shadow)
end

function shadow:update(dt)
end

function shadow:draw()
	love.graphics.draw(self.img, self.x, self.y)
end

function shadow:serialize()
	return {
		uid = self.uid,
		type = self.type,
		x = self.x,
		y = self.y,
	}
end

function shadow:unserialize(n)
	self.uid = n.uid
	self.type = n.type
	self.x = n.x
	self.y = n.y
end
