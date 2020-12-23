local shadow = {}
shadow.__index = shadow

function newShadow(n)
	n.type = "shadow"
	n.width = 16
	n.height = 16
	n.img = IMG_shadow

	return setmetatable(n, shadow)
end

function shadow:update(dt)
end

function shadow:draw()
	lutro.graphics.draw(self.img, self.x, self.y)
end
