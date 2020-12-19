local gem = {}
gem.__index = gem

function newGem(n)
	n.type = "gem"
	n.width = 16
	n.height = 16
	n.anim = newAnimation(love.graphics.newImage("assets/gem.png"),  16, 16, 1, 10)

	return setmetatable(n, gem)
end

function gem:update(dt)
	if PHASE == "victory" then return end
	self.anim:update(dt)
end

function gem:draw()
	self.anim:draw(self.x, self.y)
end
