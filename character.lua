local character = {}
character.__index = character

JUMP_FORGIVENESS = 8

function newCharacter(n)
	n.type = ENT_CHARACTER
	n.width = 12
	n.height = 16
	n.xspeed = 0
	n.yspeed = 0
	n.xaccel = 0.5
	n.yaccel = 0.15
	if n.direction == nil then n.direction = DIR_RIGHT end
	n.stance = "jump"
	n.DO_JUMP = 0
	n.DO_ATTACK = 0
	n.speedlimit = 2
	n.ko = 0
	n.dead_t = 0
	n.dead = false
	n.ungrounded_time = 0

	n.skin = "turnip"
	if n.pad == 2 then n.skin = "croco" end
	if n.pad == 3 then n.skin = "cat" end

	if n.skin == "turnip" then
		n.animations = {
			stand = {
				[DIR_LEFT]  = newAnimation(IMG_turnip_stand_left,  24, 24, 2, 10),
				[DIR_RIGHT] = newAnimation(IMG_turnip_stand_right, 24, 24, 2, 10)
			},
			run = {
				[DIR_LEFT]  = newAnimation(IMG_turnip_run_left,  24, 24, 1, 10),
				[DIR_RIGHT] = newAnimation(IMG_turnip_run_right, 24, 24, 1, 10)
			},
			jump = {
				[DIR_LEFT]  = newAnimation(IMG_turnip_jump_left,  24, 24, 1, 10),
				[DIR_RIGHT] = newAnimation(IMG_turnip_jump_right, 24, 24, 1, 10)
			},
			fall = {
				[DIR_LEFT]  = newAnimation(IMG_turnip_fall_left,  24, 24, 1, 10),
				[DIR_RIGHT] = newAnimation(IMG_turnip_fall_right, 24, 24, 1, 10)
			},
			ko = {
				[DIR_LEFT]  = newAnimation(IMG_turnip_ko_left,  16, 16, 1, 10),
				[DIR_RIGHT] = newAnimation(IMG_turnip_ko_right, 16, 16, 1, 10)
			},
			die = {
				[DIR_LEFT]  = newAnimation(IMG_turnip_die_left,  24, 24, 1, 10),
				[DIR_RIGHT] = newAnimation(IMG_turnip_die_right, 24, 24, 1, 10)
			},
		}
	elseif n.skin == "croco" then
		n.animations = {
			stand = {
				[DIR_LEFT]  = newAnimation(IMG_croco_stand_left,  24, 24, 2, 10),
				[DIR_RIGHT] = newAnimation(IMG_croco_stand_right, 24, 24, 2, 10)
			},
			run = {
				[DIR_LEFT]  = newAnimation(IMG_croco_run_left,  24, 24, 1, 10),
				[DIR_RIGHT] = newAnimation(IMG_croco_run_right, 24, 24, 1, 10)
			},
			jump = {
				[DIR_LEFT]  = newAnimation(IMG_croco_jump_left,  24, 24, 1, 10),
				[DIR_RIGHT] = newAnimation(IMG_croco_jump_right, 24, 24, 1, 10)
			},
			fall = {
				[DIR_LEFT]  = newAnimation(IMG_croco_fall_left,  24, 24, 1, 10),
				[DIR_RIGHT] = newAnimation(IMG_croco_fall_right, 24, 24, 1, 10)
			},
			ko = {
				[DIR_LEFT]  = newAnimation(IMG_croco_ko_left,  16, 16, 1, 10),
				[DIR_RIGHT] = newAnimation(IMG_croco_ko_right, 16, 16, 1, 10)
			},
			die = {
				[DIR_LEFT]  = newAnimation(IMG_croco_die_left,  24, 24, 1, 10),
				[DIR_RIGHT] = newAnimation(IMG_croco_die_right, 24, 24, 1, 10)
			},
		}
	elseif n.skin == "cat" then
		n.animations = {
			stand = {
				[DIR_LEFT]  = newAnimation(IMG_cat_stand_left,  24, 24, 2, 10),
				[DIR_RIGHT] = newAnimation(IMG_cat_stand_right, 24, 24, 2, 10)
			},
			run = {
				[DIR_LEFT]  = newAnimation(IMG_cat_run_left,  24, 24, 1, 10),
				[DIR_RIGHT] = newAnimation(IMG_cat_run_right, 24, 24, 1, 10)
			},
			jump = {
				[DIR_LEFT]  = newAnimation(IMG_cat_jump_left,  24, 24, 1, 10),
				[DIR_RIGHT] = newAnimation(IMG_cat_jump_right, 24, 24, 1, 10)
			},
			fall = {
				[DIR_LEFT]  = newAnimation(IMG_cat_fall_left,  24, 24, 1, 10),
				[DIR_RIGHT] = newAnimation(IMG_cat_fall_right, 24, 24, 1, 10)
			},
			ko = {
				[DIR_LEFT]  = newAnimation(IMG_cat_ko_left,  16, 16, 1, 10),
				[DIR_RIGHT] = newAnimation(IMG_cat_ko_right, 16, 16, 1, 10)
			},
			die = {
				[DIR_LEFT]  = newAnimation(IMG_cat_die_left,  24, 24, 1, 10),
				[DIR_RIGHT] = newAnimation(IMG_cat_die_right, 24, 24, 1, 10)
			},
		}
	end

	n.anim = n.animations[n.stance][n.direction]

	return setmetatable(n, character)
end

function character:on_the_ground()
	return ground_at(self.x + 1, self.y + self.height)
		or ground_at(self.x + self.width - 1, self.y + self.height)
end

function character:on_a_bridge()
	return bridge_at(self.x + 1, self.y + self.height)
		or bridge_at(self.x + self.width - 1, self.y + self.height)
end

function character:die()
	self.dead = true
	self.dead_t = 240
	self.yspeed = -1
	self.stance = "die"
	love.audio.play(SFX_die)
	table.insert(ENTITIES, newGhost({x=self.x, y=self.y, pad=self.pad, skin=self.skin, direction=self.direction}))
end

function character:update(dt)
	if PHASE == "victory" then return end

	if self.dead_t > 0 then
		if self.dead_t < 180 then
			self.yspeed = self.yspeed + self.yaccel
			if (self.yspeed > 3) then self.yspeed = 3 end
			self.y = self.y + self.yspeed
		end
		self.anim = self.animations[self.stance][self.direction]
		self.anim:update(dt)
		if self.y > SCREEN_HEIGHT then entity_remove(self) end
		self.dead_t = self.dead_t - 1
		return
	end

	local otg = self:on_the_ground()
	local oab = self:on_a_bridge()

	local JOY_LEFT  = love.keyboard.isDown("left")
	local JOY_RIGHT = love.keyboard.isDown("right")
	local JOY_DOWN = love.keyboard.isDown("down")
	local JOY_B = love.keyboard.isDown("z")
	local JOY_A = love.keyboard.isDown("x")
	if lutro ~= nil then
		JOY_LEFT  = love.joystick.isDown(self.pad, RETRO_DEVICE_ID_JOYPAD_LEFT)
		JOY_RIGHT = love.joystick.isDown(self.pad, RETRO_DEVICE_ID_JOYPAD_RIGHT)
		JOY_DOWN = love.joystick.isDown(self.pad, RETRO_DEVICE_ID_JOYPAD_DOWN)
		JOY_B = love.joystick.isDown(self.pad, RETRO_DEVICE_ID_JOYPAD_B)
		JOY_A = love.joystick.isDown(self.pad, RETRO_DEVICE_ID_JOYPAD_A)
	end

	-- gravity
	self.yspeed = self.yspeed + self.yaccel
	if (self.yspeed > 3) then self.yspeed = 3 end
	if (otg or oab) and self.yspeed > 0 then self.yspeed = 0 end

	-- jumping
	if JOY_B then
		self.DO_JUMP = self.DO_JUMP + 1
	else
		self.DO_JUMP = 0
	end

	if otg or oab then
		self.ungrounded_time = 0
	else
		self.ungrounded_time = self.ungrounded_time + 1
	end

	if self.DO_JUMP == 1 and not JOY_DOWN then
		if self.ungrounded_time < JUMP_FORGIVENESS then
			self.y = self.y - 1
			self.yspeed = -3.75
			love.audio.play(SFX_jump)
		end
	end

	-- jumping down
	if self.DO_JUMP == 1 and JOY_DOWN then
		if oab then
			self.y = self.y + 3
			love.audio.play(SFX_jump)
		elseif otg then
			self.y = self.y - 1
			self.yspeed = -3.75
			love.audio.play(SFX_jump)
		end
	end

	-- attacking
	if JOY_A then
		self.DO_ATTACK = self.DO_ATTACK + 1
	else
		self.DO_ATTACK = 0
	end

	if self.DO_ATTACK == 1 then
		love.audio.play(SFX_bubble)
		if self.direction == DIR_LEFT then
			table.insert(ENTITIES, newBubble({uid=newUID(),x=self.x-16-4,y=self.y,direction=self.direction}))
		else
			table.insert(ENTITIES, newBubble({uid=newUID(),x=self.x+16+4,y=self.y,direction=self.direction}))
		end
	end

	-- moving
	if JOY_LEFT then
		self.xspeed = self.xspeed - self.xaccel
		if self.xspeed < -self.speedlimit then
			self.xspeed = -self.speedlimit
		end
		self.direction = DIR_LEFT
	end

	if JOY_RIGHT then
		self.xspeed = self.xspeed + self.xaccel
		if self.xspeed > self.speedlimit then
			self.xspeed = self.speedlimit
		end
		self.direction = DIR_RIGHT
	end

	-- apply speed
	self.x = self.x + self.xspeed
	self.y = self.y + self.yspeed

	-- screen wrapping
	self.x = self.x % SCREEN_WIDTH
	self.y = self.y % SCREEN_HEIGHT

	-- decelerating
	if  ((not JOY_RIGHT and self.xspeed > 0)
	or  (not JOY_LEFT  and self.xspeed < 0))
	and (otg or oab)
	then
		if self.xspeed > 0 then
			self.xspeed = self.xspeed - 10
			if self.xspeed < 0 then
				self.xspeed = 0
			end
		elseif self.xspeed < 0 then
			self.xspeed = self.xspeed + 10
			if self.xspeed > 0 then
				self.xspeed = 0
			end
		end
	end

	if self.ko > 0 then self.ko = self.ko - 1 end

	-- animations
	if self.ko > 0 then
		self.stance = "ko"
	elseif otg or oab then
		if self.xspeed == 0 then
			self.stance = "stand"
		else
			self.stance = "run"
		end
	else
		if self.yspeed < 0 then
			self.stance = "jump"
		else
			self.stance = "fall"
		end
	end

	local anim = self.animations[self.stance][self.direction]
	-- always animate from first frame
	if anim ~= self.anim then
		anim.timer = 0
	end
	self.anim = anim

	self.anim:update(dt)

	solid_collisions(self)
end

function character:draw()
	self.anim:draw(self.x-6, self.y-8)
	if not self.dead then
		self.anim:draw(self.x+SCREEN_WIDTH-6, self.y-8)
		self.anim:draw(self.x-SCREEN_WIDTH-6, self.y-8)
		self.anim:draw(self.x-6, self.y+SCREEN_HEIGHT-8)
		self.anim:draw(self.x-6, self.y-SCREEN_HEIGHT-8)
	end
end

function character:on_collide(e1, e2, dx, dy)

	if self.dead then return end

	if e2.type == ENT_GROUND then
		if math.abs(dy) < math.abs(dx) and ((dy < 0 and self.yspeed > 0) or (dy > 0 and self.yspeed < 0)) then
			self.yspeed = 0
			self.y = self.y + dy
		end
		if math.abs(dx) < math.abs(dy) and dx ~= 0 then
			self.xspeed = 0
			self.x = self.x + dx
		end
	elseif e2.type == ENT_BRIDGE then
		if math.abs(dy) < math.abs(dx) and dy ~= 0 and self.yspeed > 0 and self.y+self.height-3 < e2.y then
			self.yspeed = 0
			self.y = self.y + dy
		end
	elseif e2.type == ENT_BUBBLE and self.yspeed > 0 and self.y < e2.y then
		self.yspeed = -4
		e2:die()
	elseif e2.type == ENT_CHARACTER then
		if math.abs(dy) < math.abs(dx) and ((dy < 0 and self.yspeed > 0) or (dy > 0 and self.yspeed < 0)) then
			self.yspeed = -1
			self.y = self.y + dy
			love.audio.play(SFX_ko)
			e2.ko = 10
		end

		if math.abs(dx) < math.abs(dy) and dx ~= 0 then
			self.xspeed = 0
			self.x = self.x + dx/2
		end
	elseif e2.type == ENT_BOUNCER then
		if math.abs(dy) < math.abs(dx) and ((dy < 0 and self.yspeed > 0) or (dy > 0 and self.yspeed < 0)) then
			self.yspeed = -6
			self.y = self.y + dy
			love.audio.play(SFX_ko)
		end

		if math.abs(dx) < math.abs(dy) and dx ~= 0 then
			self.xspeed = 0
			self.x = self.x + dx/2
		end
	elseif e2.type == ENT_EYE and not e2.captured then
		self:die()
	elseif e2.type == ENT_HEADY and not e2.captured then
		self:die()
	elseif e2.type == ENT_SPIKES then
		if (e2.direction == DIR_DOWN and self.yspeed < 0)
		or (e2.direction == DIR_UP and self.yspeed > 0)
		or (e2.direction == DIR_RIGHT and self.xspeed < 0)
		or (e2.direction == DIR_LEFT and self.xspeed > 0) then
			self:die()
		end
	elseif e2.type == ENT_GEM then
		love.audio.play(SFX_gem)
		table.insert(EFFECTS, newNotif({uid=newUID(),x=e2.x, y=e2.y, text="200"}))
		entity_remove(e2)
	elseif e2.type == ENT_CROSS then
		love.audio.play(SFX_gem)
		table.insert(EFFECTS, newNotif({uid=newUID(),x=e2.x, y=e2.y, text="1000"}))
		entity_remove(e2)
	end
end

function character:serialize()
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
		ko = self.ko,
		dead_t = self.dead_t,
		ungrounded_time = self.ungrounded_time,
		skin = self.skin,
		dead = self.dead,
		stance = self.stance,
		DO_JUMP = self.DO_JUMP,
		DO_ATTACK = self.DO_ATTACK,
	}
end

function character:unserialize(n)
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
	self.ko = n.ko
	self.dead_t = n.dead_t
	self.ungrounded_time = n.ungrounded_time
	self.skin = n.skin
	self.dead = n.dead
	self.stance = n.stance
	self.DO_JUMP = n.DO_JUMP
	self.DO_ATTACK = n.DO_ATTACK
end
