local bubble = {}
bubble.__index = bubble

function newBubble(n)
	n.type = "bubble"
	n.width = 16
	n.height = 16
	if n.direction == "left" then
		n.xspeed = -2.5
		n.xaccel = 0.05
	else
		n.xaccel = -0.05
		n.xspeed = 2.5
	end
	n.yspeed = 0
	n.yaccel = 0
	n.die = -1
	n.child = nil

	n.anim = newAnimation(love.graphics.newImage("assets/bubble.png"), 16, 16, 1, 10)

	return setmetatable(n, bubble)
end

function bubble:update(dt)
	self.xspeed = self.xspeed + self.xaccel
	self.yspeed = self.yspeed + self.yaccel

	if self.direction == "left" and self.xspeed > 0 then
		self.xspeed = 0
	end
	if self.direction == "right" and self.xspeed < 0 then
		self.xspeed = 0
	end
	self.x = self.x + self.xspeed

	if self.x >= SCREEN_WIDTH then self.x = 0 end
	if self.x < 0 then self.x = SCREEN_WIDTH end

	if self.child ~= nil then
		self.child.x = self.x
		self.child.y = self.y
	end

	self.anim:update(dt)
	solid_collisions(self)
end

function bubble:draw()
	self.anim:draw(self.x, self.y)
	self.anim:draw(self.x+SCREEN_WIDTH, self.y)
	self.anim:draw(self.x-SCREEN_WIDTH, self.y)
end

function bubble:on_collide(e1, e2, dx, dy)
	if e2.type == "ground" then
		self.xaccel = 0
		self.yaccel = 0
		self.xspeed = 0
		self.yspeed = 0
		self.x = self.x + dx
	elseif e2.type == "bubble" then
		self.xaccel = 0
		self.yaccel = 0
		self.xspeed = self.xspeed/2
		self.yspeed = 0
		self.x = self.x + dx/2
	elseif e2.type == "character" then
		self.xaccel = 0
		self.yaccel = 0
		self.xspeed = 0
		self.yspeed = 0
		if dx ~= 0 then
			self.x = self.x + dx/2
		end
	elseif e2.type == "spikes" then
		if self.child ~= nil then
			self.child:die()
			table.insert(effects, newNotif({x=self.x, y=self.y, text="500"}))
		else
			table.insert(effects, newNotif({x=self.x, y=self.y, text="100"}))
			love.audio.play(sfx_explode)
		end
		table.insert(effects, newBubbleexp(self))
		entity_remove(self)
	end
end
