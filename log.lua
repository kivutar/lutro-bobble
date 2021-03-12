local log = {}
log.__index = log

function newLog(n)
	n.type = ENT_LOG
	n.width = 64
	n.height = 8
	n.img = IMG_log

	return setmetatable(n, log)
end

function log:update(dt)
	self.y = self.y - 0.5

	-- screen wrapping
	self.x = self.x % SCREEN_WIDTH
	self.y = self.y % SCREEN_HEIGHT
end

function log:draw()
	love.graphics.draw(self.img, self.x, self.y)
end

function log:serialize()
	return {
		uid = self.uid,
		type = self.type,
		x = self.x,
		y = self.y,
	}
end

function log:unserialize(n)
	self.uid = n.uid
	self.type = n.type
	self.x = n.x
	self.y = n.y
end
