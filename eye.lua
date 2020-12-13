local eye = {}
eye.__index = eye

function newEye(n)
	n.type = "eye"
	n.width = 16
	n.height = 16
	n.direction = "right"
	if n.direction == "left" then
		n.xspeed = -0.5
	else
		n.xspeed = 0.5
	end
	n.yspeed = 0
	n.yaccel = 0.17
	n.xaccel = 0
	n.captured = false
	n.dead = false
	n.stance = "run"

	n.animations = {
		run = {
			left  = newAnimation(love.graphics.newImage("assets/eye_run_left.png"),  16, 16, 1, 10),
			right = newAnimation(love.graphics.newImage("assets/eye_run_right.png"), 16, 16, 1, 10)
		},
		captured = {
			left  = newAnimation(love.graphics.newImage("assets/eye_captured_left.png"),  16, 16, 1, 10),
			right = newAnimation(love.graphics.newImage("assets/eye_captured_right.png"), 16, 16, 1, 10)
		},
		die = {
			left  = newAnimation(love.graphics.newImage("assets/eye_die_left.png"),  16, 16, 1, 10),
			right = newAnimation(love.graphics.newImage("assets/eye_die_right.png"), 16, 16, 1, 10)
		},
	}

	n.anim = n.animations[n.stance][n.direction]

	return setmetatable(n, eye)
end

function eye:on_the_ground()
	return solid_at(self.x + 1, self.y + 16, self)
		or solid_at(self.x + 15, self.y + 16, self)
end

function eye:die()
	self.dead = true
	self.yspeed = -1
	self.stance = "die"
	love.audio.play(sfx_enemy_die)
end

function eye:update(dt)
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
	if otg then self.yspeed = 0 end

	self.x = self.x + self.xspeed
	self.y = self.y + self.yspeed

	if self.y >= SCREEN_HEIGHT then self.y = 0 end
	if self.y < 0 then self.y = SCREEN_HEIGHT end
	if self.x > SCREEN_WIDTH then self.x = 0 end
	if self.x < 0 then self.x = SCREEN_WIDTH end

	self.anim = self.animations[self.stance][self.direction]
	self.anim:update(dt)
	solid_collisions(self)
end

function eye:draw()
	self.anim:draw(self.x, self.y)
	self.anim:draw(self.x+SCREEN_WIDTH, self.y)
	self.anim:draw(self.x-SCREEN_WIDTH, self.y)
end

function eye:on_collide(e1, e2, dx, dy)

	if self.captured or self.dead then return end

	if e2.type == "ground" then
		if math.abs(dy) < math.abs(dx) and ((dy < 0 and self.yspeed > 0) or (dy > 0 and self.yspeed < 0)) then
			self.yspeed = 0
			self.y = self.y + dy
		end

		if math.abs(dx) < math.abs(dy) and dx ~= 0 then
			self.x = self.x + dx
			if self.direction == "right" then self.direction = "left"
			elseif self.direction == "left" then self.direction = "right" end
			self.xspeed = -self.xspeed
		end
	elseif e2.type == "bubble" then
		if math.abs(e2.xspeed) < 0.5 then
			self.x = self.x + dx
			if self.direction == "right" then self.direction = "left"
			elseif self.direction == "left" then self.direction = "right" end
			self.xspeed = -self.xspeed
		elseif math.abs(e2.xspeed) >= 0.5 and e2.child == nil then
			self.captured = true
			e2.child = self
		end
	end
end
