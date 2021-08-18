local heady = {}
heady.__index = heady

function NewHeady(n)
	n.type = ENT_HEADY
	n.width = 16
	n.height = 16
	n.direction = DIR_RIGHT
	if n.direction == DIR_LEFT then
		n.xspeed = -1
	else
		n.xspeed = 1
	end
	n.yspeed = 0
	n.yaccel = 0.17
	n.xaccel = 0
	n.captured = false
	n.dead = false
	n.stance = "run"

	n.animations = {
		run = {
			[DIR_LEFT]  = NewAnimation(IMG_heady_run_left,  16, 16, 1, 10),
			[DIR_RIGHT] = NewAnimation(IMG_heady_run_right, 16, 16, 1, 10)
		},
		captured = {
			[DIR_LEFT]  = NewAnimation(IMG_heady_captured_left,  16, 16, 1, 10),
			[DIR_RIGHT] = NewAnimation(IMG_heady_captured_right, 16, 16, 1, 10)
		},
		die = {
			[DIR_LEFT]  = NewAnimation(IMG_heady_die_left,  16, 16, 1, 10),
			[DIR_RIGHT] = NewAnimation(IMG_heady_die_right, 16, 16, 1, 10)
		},
	}

	n.anim = n.animations[n.stance][n.direction]

	return setmetatable(n, heady)
end

function heady:on_the_ground()
	return solid_at(self.x + 1, self.y + 16, self)
		or solid_at(self.x + 15, self.y + 16, self)
end

function heady:die()
	self.dead = true
	self.yspeed = -1
	self.stance = "die"
	SFX_enemy_die:play()
end

function heady:update(dt)
	if PHASE == "victory" then return end

	if self.dead then
		self.yspeed = self.yspeed + self.yaccel
		if (self.yspeed > 3) then self.yspeed = 3 end
		self.y = self.y + self.yspeed
		self.anim = self.animations[self.stance][self.direction]
		self.anim:update(dt)
		if self.y > SCREEN_HEIGHT then entity_remove(self) end
		return
	end

	if self.captured then
		self.stance = "captured"
		self.anim = self.animations[self.stance][self.direction]
		self.anim:update(dt)
		return
	end

	local otg = self:on_the_ground()

	self.xspeed = self.xspeed + self.xaccel
	self.yspeed = self.yspeed + self.yaccel
	if (self.yspeed > 3) then self.yspeed = 3 end
	if otg and self.yspeed > 0 then self.yspeed = 0 end

	self.x = self.x + self.xspeed
	self.y = self.y + self.yspeed

	-- screen wrapping
	self.x = self.x % SCREEN_WIDTH
	self.y = self.y % SCREEN_HEIGHT

	self.anim = self.animations[self.stance][self.direction]
	self.anim:update(dt)
	solid_collisions(self)
end

function heady:draw()
	self.anim:draw(self.x, self.y)
	self.anim:draw(self.x+SCREEN_WIDTH, self.y)
	self.anim:draw(self.x-SCREEN_WIDTH, self.y)
end

function heady:on_collide(e1, e2, dx, dy)

	if self.captured or self.dead then return end

	if e2.type == ENT_GROUND then
		if math.abs(dy) < math.abs(dx) and ((dy < 0 and self.yspeed > 0) or (dy > 0 and self.yspeed < 0)) then
			self.yspeed = 0
			self.y = self.y + dy
		end

		if math.abs(dx) < math.abs(dy) and dx ~= 0 then
			self.x = self.x + dx
			if self.direction == DIR_RIGHT then self.direction = DIR_LEFT
			elseif self.direction == DIR_LEFT then self.direction = DIR_RIGHT end
			self.xspeed = -self.xspeed
		end
	elseif e2.type == ENT_BRIDGE then
		if math.abs(dy) < math.abs(dx) and ((dy < 0 and self.yspeed > 0) or (dy > 0 and self.yspeed < 0)) then
			self.yspeed = 0
			self.y = self.y + dy
		end

		if math.abs(dx) < math.abs(dy) and dx ~= 0 then
			self.x = self.x + dx
			if self.direction == DIR_RIGHT then self.direction = DIR_LEFT
			elseif self.direction == DIR_LEFT then self.direction = DIR_RIGHT end
			self.xspeed = -self.xspeed
		end
	elseif e2.type == ENT_BUBBLE then
		if math.abs(e2.xspeed) < 0.5 then
			self.x = self.x + dx
			if self.direction == DIR_RIGHT then self.direction = DIR_LEFT
			elseif self.direction == DIR_LEFT then self.direction = DIR_RIGHT end
			self.xspeed = -self.xspeed
		elseif math.abs(e2.xspeed) >= 0.5 and e2.child == nil then
			self.captured = true
			e2.child = self
			e2.childuid = self.uid
		end
	elseif e2.type == ENT_SPIKES then
		self:die()
	elseif e2.type == ENT_EYE or e2.type == ENT_HEADY then
		if math.abs(dy) < math.abs(dx) and ((dy < 0 and self.yspeed > 0) or (dy > 0 and self.yspeed < 0)) then
			self.yspeed = 0
			self.y = self.y + dy
		end

		if math.abs(dx) < math.abs(dy) and dx ~= 0 then
			self.x = self.x + dx
			if self.direction == DIR_RIGHT then self.direction = DIR_LEFT
			elseif self.direction == DIR_LEFT then self.direction = DIR_RIGHT end
			self.xspeed = -self.xspeed

			e2.x = e2.x - dx
			if e2.direction == DIR_RIGHT then e2.direction = DIR_LEFT
			elseif e2.direction == DIR_LEFT then e2.direction = DIR_RIGHT end
			e2.xspeed = -e2.xspeed
		end
	end
end

function heady:serialize()
	return {
		uid = self.uid,
		type = self.type,
		direction = self.direction,
		x = self.x,
		y = self.y,
		xspeed = self.xspeed,
		xaccel = self.xaccel,
		yspeed = self.yspeed,
		yaccel = self.yaccel,
		captured = self.captured,
		dead = self.dead,
		stance = self.stance,
	}
end

function heady:unserialize(n)
	self.uid = n.uid
	self.type = n.type
	self.direction = n.direction
	self.x = n.x
	self.y = n.y
	self.xspeed = n.xspeed
	self.xaccel = n.xaccel
	self.yspeed = n.yspeed
	self.yaccel = n.yaccel
	self.captured = n.captured
	self.dead = n.dead
	self.stance = n.stance
end
