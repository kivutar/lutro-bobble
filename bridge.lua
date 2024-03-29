local bridge = {}
bridge.__index = bridge

function NewBridge(n)
	n.type = ENT_BRIDGE
	n.width = 16
	n.height = 1
	n.img = IMG_bridge

	return setmetatable(n, bridge)
end

function bridge:update(dt)
end

function bridge:draw()
	love.graphics.draw(self.img, self.x, self.y)
end

function bridge:serialize()
	return {
		uid = self.uid,
		type = self.type,
		x = self.x,
		y = self.y,
	}
end

function bridge:unserialize(n)
	self.uid = n.uid
	self.type = n.type
	self.x = n.x
	self.y = n.y
end
