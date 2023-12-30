local gem = {}
gem.__index = gem

function NewGem(n)
	n.type = ENT_GEM
	n.width = 16
	n.height = 16
	n.anim = NewAnimation(IMG_gem,  16, 16, 1, 10)

	return setmetatable(n, gem)
end

function gem:update(dt)
	if PHASE == "victory" then return end
	self.anim:update(dt)
end

function gem:draw()
	self.anim:draw(self.x, self.y)
end

function gem:serialize()
	return {
		uid = self.uid,
		type = self.type,
		x = self.x,
		y = self.y,
		animtimer = self.anim.timer,
	}
end

function gem:unserialize(n)
	self.uid = n.uid
	self.type = n.type
	self.x = n.x
	self.y = n.y
	self.anim.timer = n.animtimer
end
