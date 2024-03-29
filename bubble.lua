local bubble = {}
bubble.__index = bubble

function NewBubble(n)
	n.type = ENT_BUBBLE
	n.width = 16
	n.height = 16
	if n.direction == DIR_LEFT then
		n.xspeed = -2.5
		n.xaccel = 0.05
	else
		n.xaccel = -0.05
		n.xspeed = 2.5
	end
	n.child = nil
	n.childuid = nil

	n.anim = NewAnimation(IMG_bubble, 16, 16, 1, 10)

	return setmetatable(n, bubble)
end

function bubble:update(dt)
	self.xspeed = self.xspeed + self.xaccel

	if self.direction == DIR_LEFT and self.xspeed > 0 then
		self.xspeed = 0
	end
	if self.direction == DIR_RIGHT and self.xspeed < 0 then
		self.xspeed = 0
	end
	self.x = self.x + self.xspeed * 60 * dt

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

function bubble:die()
	if self.child ~= nil then
		self.child:die()
		self.childuid = nil
		table.insert(EFFECTS, NewNotif({uid=NewUID(),x=self.x, y=self.y, text="500"}))
	else
		table.insert(EFFECTS, NewNotif({uid=NewUID(),x=self.x, y=self.y, text="100"}))
		SFX_explode:play()
	end
	table.insert(EFFECTS, NewBubbleexp({uid=NewUID(),x=self.x,y=self.y}))
	entity_remove(self)
end

function bubble:on_collide(e1, e2, dx, dy)
	if e2.type == ENT_GROUND then
		self.xaccel = 0
		self.xspeed = 0
		self.x = self.x + dx
		if math.abs(dx) > 8 then self:die() end
	elseif e2.type == ENT_BUBBLE then
		self.xaccel = 0
		self.xspeed = self.xspeed/2
		self.x = self.x + dx/2
	elseif e2.type == ENT_CHARACTER then
		self.xaccel = 0
		self.xspeed = self.xspeed/2
		if dx ~= 0 then
			self.x = self.x + dx/2
		end
	elseif e2.type == ENT_SPIKES then
		self:die()
	end
end

function bubble:serialize()
	return {
		uid = self.uid,
		type = self.type,
		direction = self.direction,
		x = self.x,
		y = self.y,
		xspeed = self.xspeed,
		xaccel = self.xaccel,
		childuid = self.childuid,
	}
end

function bubble:unserialize(n)
	self.uid = n.uid
	self.type = n.type
	self.direction = n.direction
	self.x = n.x
	self.y = n.y
	self.xspeed = n.xspeed
	self.xaccel = n.xaccel
	self.childuid = n.childuid
end
