local bridge = {}
bridge.__index = bridge

function newBridge(n)
	n.type = "bridge"
	n.width = 16
	n.height = 4
	n.img = lutro.graphics.newImage("assets/bridge.png")

	return setmetatable(n, bridge)
end

function bridge:update(dt)
end

function bridge:draw()
	lutro.graphics.draw(self.img, self.x, self.y)
end
