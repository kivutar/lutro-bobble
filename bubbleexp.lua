local bubbleexp = {}
bubbleexp.__index = bubbleexp

function NewBubbleexp(n)
	n.type = ENT_BUBBLEEXP
	n.t = 0
	n.anim = NewAnimation(IMG_bubbleexp, 16, 16, 1, 10)
	return setmetatable(n, bubbleexp)
end

function bubbleexp:update(dt)
	self.t = self.t + 1
	if self.t == 10 then
		effect_remove(self)
	end
	self.anim:update(dt)
end

function bubbleexp:draw()
	self.anim:draw(self.x, self.y)
end

function bubbleexp:serialize()
	return {
		uid = self.uid,
		type = self.type,
		x = self.x,
		y = self.y,
		t = self.t,
	}
end

function bubbleexp:unserialize(n)
	self.uid = n.uid
	self.type = n.type
	self.x = n.x
	self.y = n.y
	self.t = n.t
end
