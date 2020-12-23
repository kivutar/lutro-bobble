local character = {}
character.__index = character

JUMP_FORGIVENESS = 8

function newCharacter(n)
	n.type = "character"
	n.width = 16
	n.height = 16
	n.xspeed = 0
	n.yspeed = 0
	n.xaccel = 0.5
	n.yaccel = 0.17
	if n.direction == nil then n.direction = "right" end
	n.stance = "jump"
	n.DO_JUMP = 0
	n.DO_ATTACK = 0
	n.speedlimit = 1.5
	n.ko = 0
	n.dead_t = 0
	n.dead = false
	n.ungrounded_time = 0

	n.skin = "frog"
	if n.pad == 2 then n.skin = "fox" end
	if n.pad == 3 then n.skin = "bird" end

	n.animations = {
		stand = {
			left  = newAnimation(love.graphics.newImage("assets/"..n.skin.."_stand_left.png"),  16, 16, 2, 10),
			right = newAnimation(love.graphics.newImage("assets/"..n.skin.."_stand_right.png"), 16, 16, 2, 10)
		},
		run = {
			left  = newAnimation(love.graphics.newImage("assets/"..n.skin.."_run_left.png"),  16, 16, 1, 10),
			right = newAnimation(love.graphics.newImage("assets/"..n.skin.."_run_right.png"), 16, 16, 1, 10)
		},
		jump = {
			left  = newAnimation(love.graphics.newImage("assets/"..n.skin.."_jump_left.png"),  16, 16, 1, 10),
			right = newAnimation(love.graphics.newImage("assets/"..n.skin.."_jump_right.png"), 16, 16, 1, 10)
		},
		ko = {
			left  = newAnimation(love.graphics.newImage("assets/"..n.skin.."_ko_left.png"),  16, 16, 1, 10),
			right = newAnimation(love.graphics.newImage("assets/"..n.skin.."_ko_right.png"), 16, 16, 1, 10)
		},
		die = {
			left  = newAnimation(love.graphics.newImage("assets/"..n.skin.."_die_left.png"),  16, 16, 1, 10),
			right = newAnimation(love.graphics.newImage("assets/"..n.skin.."_die_right.png"), 16, 16, 1, 10)
		},
	}

	n.anim = n.animations[n.stance][n.direction]

	return setmetatable(n, character)
end

function character:on_the_ground()
	return ground_at(self.x + 1, self.y + self.height)
		or ground_at(self.x + 15, self.y + self.height)
end

function character:on_a_bridge()
	return bridge_at(self.x + 1, self.y + self.height)
		or bridge_at(self.x + 15, self.y + self.height)
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

	local JOY_LEFT  = love.joystick.isDown(self.pad, RETRO_DEVICE_ID_JOYPAD_LEFT)
	local JOY_RIGHT = love.joystick.isDown(self.pad, RETRO_DEVICE_ID_JOYPAD_RIGHT)
	local JOY_DOWN = love.joystick.isDown(self.pad, RETRO_DEVICE_ID_JOYPAD_DOWN)
	local JOY_B = love.joystick.isDown(self.pad, RETRO_DEVICE_ID_JOYPAD_B)
	local JOY_A = love.joystick.isDown(self.pad, RETRO_DEVICE_ID_JOYPAD_A)

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
			self.yspeed = -4
			love.audio.play(SFX_jump)
		end
	end

	-- jumping down
	if self.DO_JUMP == 1 and JOY_DOWN then
		if oab then
			self.y = self.y + 16
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
		if self.direction == "left" then
			table.insert(ENTITIES, newBubble({x=self.x-16-4,y=self.y,direction=self.direction}))
		else
			table.insert(ENTITIES, newBubble({x=self.x+16+4,y=self.y,direction=self.direction}))
		end
	end

	-- moving
	if JOY_LEFT then
		self.xspeed = self.xspeed - self.xaccel
		if self.xspeed < -self.speedlimit then
			self.xspeed = -self.speedlimit
		end
		self.direction = "left"
	end

	if JOY_RIGHT then
		self.xspeed = self.xspeed + self.xaccel
		if self.xspeed > self.speedlimit then
			self.xspeed = self.speedlimit
		end
		self.direction = "right"
	end

	-- apply speed
	self.x = self.x + self.xspeed
	self.y = self.y + self.yspeed

	-- screen wrapping
	if self.y >= SCREEN_HEIGHT then self.y = 0 end
	if self.y < 0 then self.y = SCREEN_HEIGHT end
	if self.x > SCREEN_WIDTH then self.x = 0 end
	if self.x < 0 then self.x = SCREEN_WIDTH end

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
		self.stance = "jump"
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
	self.anim:draw(self.x, self.y)
	if self.dead then
		self.anim:draw(self.x+SCREEN_WIDTH, self.y)
		self.anim:draw(self.x-SCREEN_WIDTH, self.y)
		self.anim:draw(self.x, self.y+SCREEN_HEIGHT)
		self.anim:draw(self.x, self.y-SCREEN_HEIGHT)
	end
end

function character:on_collide(e1, e2, dx, dy)

	if self.dead then return end

	if e2.type == "ground" then
		if math.abs(dy) < math.abs(dx) and ((dy < 0 and self.yspeed > 0) or (dy > 0 and self.yspeed < 0)) then
			self.yspeed = 0
			self.y = self.y + dy
		end
		if math.abs(dx) < math.abs(dy) and dx ~= 0 then
			self.xspeed = 0
			self.x = self.x + dx
		end
	elseif e2.type == "bridge" then
		if math.abs(dy) < math.abs(dx) and dy ~= 0 and self.yspeed > 0 then
			self.yspeed = 0
			self.y = self.y + dy
		end
	elseif e2.type == "bubble" and self.yspeed > 0 and self.y < e2.y then
		self.yspeed = -4
		e2:die()
	elseif e2.type == "character" then
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
	elseif e2.type == "bouncer" then
		if math.abs(dy) < math.abs(dx) and ((dy < 0 and self.yspeed > 0) or (dy > 0 and self.yspeed < 0)) then
			self.yspeed = -6
			self.y = self.y + dy
			love.audio.play(SFX_ko)
		end

		if math.abs(dx) < math.abs(dy) and dx ~= 0 then
			self.xspeed = 0
			self.x = self.x + dx/2
		end
	elseif e2.type == "eye" and not e2.captured then
		self:die()
	elseif e2.type == "spikes" then
		if (e2.direction == "down" and self.yspeed < 0)
		or (e2.direction == "up" and self.yspeed > 0)
		or (e2.direction == "right" and self.xspeed < 0)
		or (e2.direction == "left" and self.xspeed > 0) then
			self:die()
		end
	elseif e2.type == "gem" then
		love.audio.play(SFX_gem)
		table.insert(EFFECTS, newNotif({x=e2.x, y=e2.y, text="200"}))
		entity_remove(e2)
	elseif e2.type == "cross" then
		love.audio.play(SFX_gem)
		table.insert(EFFECTS, newNotif({x=e2.x, y=e2.y, text="1000"}))
		entity_remove(e2)
	end
end

function character:serialize()
	return {
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
