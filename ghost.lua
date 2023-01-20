local ghost = {}
ghost.__index = ghost

function NewGhost(n)
	n.type = ENT_GHOST
	n.width = 16
	n.height = 16
	n.xspeed = 0
	n.yspeed = 0
	if n.direction == nil then n.direction = DIR_RIGHT end
	n.stance = "ghost"
	n.speedlimit = 2
	n.t = 0

	n.skin = "turnip"
	if n.pad == 2 then n.skin = "croco" end
	if n.pad == 3 then n.skin = "cat" end

	if n.skin == "turnip" then
		n.animations = {
			ghost = {
				[DIR_LEFT]  = NewAnimation(IMG_turnip_ghost_left,  24, 24, 2, 10),
				[DIR_RIGHT] = NewAnimation(IMG_turnip_ghost_right, 24, 24, 2, 10)
			},
		}
	elseif n.skin == "croco" then
		n.animations = {
			ghost = {
				[DIR_LEFT]  = NewAnimation(IMG_croco_ghost_left,  24, 24, 2, 10),
				[DIR_RIGHT] = NewAnimation(IMG_croco_ghost_right, 24, 24, 2, 10)
			},
		}
	elseif n.skin == "cat" then
		n.animations = {
			ghost = {
				[DIR_LEFT]  = NewAnimation(IMG_cat_ghost_left,  24, 24, 2, 10),
				[DIR_RIGHT] = NewAnimation(IMG_cat_ghost_right, 24, 24, 2, 10)
			},
		}
	end

	n.anim = n.animations[n.stance][n.direction]

	return setmetatable(n, ghost)
end

function ghost:update(dt)
	if PHASE == "victory" then return end

	self.t = self.t + 1

	local JOY_LEFT = Input.isDown(self.pad, BTN_LEFT)
	local JOY_RIGHT = Input.isDown(self.pad, BTN_RIGHT)
	local JOY_DOWN = Input.isDown(self.pad, BTN_DOWN)
	local JOY_UP = Input.isDown(self.pad, BTN_UP)

	-- moving
	if JOY_LEFT then
		self.xspeed = self.xspeed - 0.05
		if self.xspeed < -self.speedlimit then
			self.xspeed = -self.speedlimit
		end
		self.direction = DIR_LEFT
	end

	if JOY_RIGHT then
		self.xspeed = self.xspeed + 0.05
		if self.xspeed > self.speedlimit then
			self.xspeed = self.speedlimit
		end
		self.direction = DIR_RIGHT
	end

	if JOY_UP then
		self.yspeed = self.yspeed - 0.05
		if self.yspeed < -self.speedlimit then
			self.yspeed = -self.speedlimit
		end
	end

	if JOY_DOWN then
		self.yspeed = self.yspeed + 0.05
		if self.yspeed > self.speedlimit then
			self.yspeed = self.speedlimit
		end
	end

	-- apply speed
	self.x = self.x + self.xspeed * 60 * dt
	self.y = self.y + self.yspeed * 60 * dt

	-- screen wrapping
	self.x = self.x % SCREEN_WIDTH
	self.y = self.y % SCREEN_HEIGHT

	-- decelerating
	if ((not JOY_RIGHT and self.xspeed > 0)
	or  (not JOY_LEFT  and self.xspeed < 0)
	or  (not JOY_UP  and self.yspeed < 0)
	or  (not JOY_DOWN  and self.yspeed > 0))
	then
		if self.xspeed > 0 then
			self.xspeed = self.xspeed - 0.01
			if self.xspeed < 0 then
				self.xspeed = 0
			end
		elseif self.xspeed < 0 then
			self.xspeed = self.xspeed + 0.01
			if self.xspeed > 0 then
				self.xspeed = 0
			end
		end
		if self.yspeed > 0 then
			self.yspeed = self.yspeed - 0.01
			if self.yspeed < 0 then
				self.yspeed = 0
			end
		elseif self.yspeed < 0 then
			self.yspeed = self.yspeed + 0.01
			if self.yspeed > 0 then
				self.yspeed = 0
			end
		end
	end

	local anim = self.animations[self.stance][self.direction]
	-- always animate from first frame
	if anim ~= self.anim then
		anim.timer = 0
	end
	self.anim = anim

	self.anim:update(dt)
end

function ghost:draw()
	if self.t % 2 == 0 then return end
	self.anim:draw(self.x-6, self.y-8)
	self.anim:draw(self.x+SCREEN_WIDTH-6, self.y-8)
	self.anim:draw(self.x-SCREEN_WIDTH-6, self.y-8)
	self.anim:draw(self.x-6, self.y+SCREEN_HEIGHT-8)
	self.anim:draw(self.x-6, self.y-SCREEN_HEIGHT-8)
end

function ghost:on_collide(e1, e2, dx, dy)
	if e2.type == ENT_CROSS then
		SFX_revive:play()
		entity_remove(e2)
		if self.pad == 1 then
			CHAR1 = NewCharacter({x=self.x, y=self.y, pad=self.pad, skin=self.skin, direction=self.direction})
			table.insert(ENTITIES, CHAR1)
		elseif self.pad == 2 then
			CHAR2 = NewCharacter({x=self.x, y=self.y, pad=self.pad, skin=self.skin, direction=self.direction})
			table.insert(ENTITIES, CHAR2)
		elseif self.pad == 3 then
			CHAR3 = NewCharacter({x=self.x, y=self.y, pad=self.pad, skin=self.skin, direction=self.direction})
			table.insert(ENTITIES, CHAR3)
		end
		entity_remove(self)
	end
end

function ghost:serialize()
	return {
		uid = self.uid,
		type = self.type,
		pad = self.pad,
		direction = self.direction,
		x = self.x,
		y = self.y,
		xspeed = self.xspeed,
		xaccel = self.xaccel,
		yspeed = self.yspeed,
		yaccel = self.yaccel,
		skin = self.skin,
		stance = self.stance,
	}
end

function ghost:unserialize(n)
	self.uid = n.uid
	self.type = n.type
	self.direction = n.direction
	self.pad = n.pad
	self.x = n.x
	self.y = n.y
	self.xspeed = n.xspeed
	self.xaccel = n.xaccel
	self.yspeed = n.yspeed
	self.yaccel = n.yaccel
	self.skin = n.skin
	self.stance = n.stance
end
