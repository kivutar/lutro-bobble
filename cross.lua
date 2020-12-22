local cross = {}
cross.__index = cross

function newCross(n)
	n.type = "cross"
	n.width = 16
	n.height = 16
	n.anim = newAnimation(love.graphics.newImage("assets/cross.png"),  16, 16, 1, 10)

	return setmetatable(n, cross)
end

function cross:update(dt)
	self.anim:update(dt)
end

function cross:draw()
	self.anim:draw(self.x, self.y)
end
