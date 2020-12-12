local bubbleexp = {}
bubbleexp.__index = bubbleexp

function newBubbleexp(n)
	n.type = "bubbleexp"
	n.t = 0
	n.anim = newAnimation(love.graphics.newImage("assets/bubble_explode.png"), 16, 16, 1, 10)
	return setmetatable(n, bubbleexp)
end

function bubbleexp:update(dt)
	self.t = self.t + 1
	if self.t == 10 then
		for i=1, #effects do
			if effects[i] == self then
				table.remove(effects, i)
			end
		end
	end
	self.anim:update(dt)
end

function bubbleexp:draw()
	self.anim:draw(self.x, self.y)
end
