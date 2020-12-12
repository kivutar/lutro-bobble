local ground = {}
ground.__index = ground

function newGround(n)
	n.type = "ground"
	n.width = 16
	n.height = 16
	n.img = img_ground

	if not solid_at(n.x, n.y-1) then n.img = img_ground_top end

	return setmetatable(n, ground)
end

function ground:draw()
	lutro.graphics.draw(self.img, self.x, self.y)
end

