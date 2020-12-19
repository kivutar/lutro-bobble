local ground = {}
ground.__index = ground

function newGround(n)
	n.type = "ground"
	n.width = 16
	n.height = 16
	n.img = IMG_ground

	if not solid_at(n.x, n.y-1) and n.y ~= 0 then n.img = IMG_ground_top end

	return setmetatable(n, ground)
end

function ground:draw()
	lutro.graphics.draw(self.img, self.x, self.y)
end

