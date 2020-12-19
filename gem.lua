local gem = {}
gem.__index = gem

function newGem(n)
	n.type = "gem"
	n.width = 16
	n.height = 16
	n.img = lutro.graphics.newImage("assets/gem.png")

	return setmetatable(n, gem)
end

function gem:update(dt)
end

function gem:draw()
	lutro.graphics.draw(self.img, self.x, self.y)
end
