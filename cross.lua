local cross = {}
cross.__index = cross

function NewCross(n)
	n.type = ENT_CROSS
	n.width = 16
	n.height = 16
	n.anim = NewAnimation(IMG_cross,  16, 16, 1, 10)

	return setmetatable(n, cross)
end

function cross:update(dt)
	self.anim:update(dt)
end

function cross:draw()
	self.anim:draw(self.x, self.y)
end

function cross:serialize()
	return {
		uid = self.uid,
		type = self.type,
		x = self.x,
		y = self.y,
		animtimer = self.anim.timer,
	}
end

function cross:unserialize(n)
	self.uid = n.uid
	self.type = n.type
	self.x = n.x
	self.y = n.y
	self.anim.timer = n.animtimer
end
