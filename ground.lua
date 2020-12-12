local ground = {}
ground.__index = ground

function newGround(n)
	n.type = "ground"
	n.width = 16
	n.height = 16

	return setmetatable(n, ground)
end

function ground:draw()
	lutro.graphics.draw(img_ground, self.x, self.y)
end

