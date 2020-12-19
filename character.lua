local character = {}
character.__index = character

function newCharacter(n)
	n.type = "character"
	n.width = 16
	n.height = 16
	n.xspeed = 0
	n.yspeed = 0
	n.xaccel = 0.5
	n.yaccel = 0.17
	n.direction = "left"
	n.stance = "fall"
	n.DO_JUMP = 0
	n.DO_ATTACK = 0
	n.speedlimit = 1.5
	n.ko = 0
	n.dead = 0
	n.skin = "bird"
	if n.pad == 2 then n.skin = "fox" end
	if n.pad == 3 then n.skin = "frog" end

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
		fall = {
			left  = newAnimation(love.graphics.newImage("assets/"..n.skin.."_fall_left.png"),  16, 16, 1, 10),
			right = newAnimation(love.graphics.newImage("assets/"..n.skin.."_fall_right.png"), 16, 16, 1, 10)
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
	return solid_at(self.x + 1, self.y + 16, self)
		or solid_at(self.x + 15, self.y + 16, self)
end

function character:on_a_bridge()
	return bridge_at(self.x + 1, self.y + 16, self)
		or bridge_at(self.x + 15, self.y + 16, self)
end

function character:die()
	self.dead = 240
	self.yspeed = -1
	self.stance = "die"
	love.audio.play(SFX_die)
end

function character:update(dt)
	if self.dead > 0 then
		if self.dead < 180 then
			self.yspeed = self.yspeed + self.yaccel
			if (self.yspeed > 3) then self.yspeed = 3 end
			self.y = self.y + self.yspeed
		end
		self.anim = self.animations[self.stance][self.direction]
		self.anim:update(dt)
		if self.y > SCREEN_HEIGHT then entity_remove(self) end
		self.dead = self.dead - 1
		return
	end

	local otg = self:on_the_ground()
	local oab = self:on_a_bridge()

	local JOY_LEFT  = love.joystick.isDown(self.pad, RETRO_DEVICE_ID_JOYPAD_LEFT)
	local JOY_RIGHT = love.joystick.isDown(self.pad, RETRO_DEVICE_ID_JOYPAD_RIGHT)
	local JOY_UP = love.joystick.isDown(self.pad, RETRO_DEVICE_ID_JOYPAD_UP)
	local JOY_DOWN = love.joystick.isDown(self.pad, RETRO_DEVICE_ID_JOYPAD_DOWN)
	local JOY_B = love.joystick.isDown(self.pad, RETRO_DEVICE_ID_JOYPAD_B)
	local JOY_Y = love.joystick.isDown(self.pad, RETRO_DEVICE_ID_JOYPAD_Y)
	local JOY_A = love.joystick.isDown(self.pad, RETRO_DEVICE_ID_JOYPAD_A)

	-- gravity
	self.yspeed = self.yspeed + self.yaccel
	if (self.yspeed > 3) then self.yspeed = 3 end
	if otg then self.yspeed = 0 end

	-- jumping
	if JOY_B then
		self.DO_JUMP = self.DO_JUMP + 1
	else
		self.DO_JUMP = 0
	end

	if self.DO_JUMP == 1 and not JOY_DOWN then
		if otg then
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

	-- jumping
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

	if self.y >= SCREEN_HEIGHT then self.y = 0 end
	if self.y < 0 then self.y = SCREEN_HEIGHT end
	if self.x > SCREEN_WIDTH then self.x = 0 end
	if self.x < 0 then self.x = SCREEN_WIDTH end

	-- decelerating
	if  ((not JOY_RIGHT and self.xspeed > 0)
	or  (not JOY_LEFT  and self.xspeed < 0))
	and otg
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
	elseif otg then
		if self.xspeed == 0 then
			self.stance = "stand"
		else
			self.stance = "run"
		end
	else
		if self.yspeed > 0 then
			self.stance = "fall"
		else
			self.stance = "jump"
		end
	end

	local anim = self.animations[self.stance][self.direction]
	-- always animate from first frame 
	if anim ~= self.anim then
		anim.timer = 0
	end
	self.anim = anim

	self.anim:update(dt)

	-- camera
	new_camera_x = - self.x + SCREEN_WIDTH/2 - self.width/2
	new_camera_y = - self.y + SCREEN_HEIGHT/2 - self.height/2
	camera_x = camera_x + (new_camera_x-camera_x) / 10.0
	camera_y = camera_y + (new_camera_y-camera_y) / 10.0

	if camera_x > 0 then
		camera_x = 0
	end
	if camera_y > 0 then
		camera_y = 0
	end

	-- if camera_x < -(#map[1] * 16) + SCREEN_WIDTH then
	-- 	camera_x = -(#map[1] * 16) + SCREEN_WIDTH
	-- end
	
	-- if camera_y < -(#map * 16) + SCREEN_HEIGHT then
	-- 	camera_y = -(#map * 16) + SCREEN_HEIGHT
	-- end

	solid_collisions(self)
end

function character:draw()
	self.anim:draw(self.x, self.y)
	self.anim:draw(self.x+SCREEN_WIDTH, self.y)
	self.anim:draw(self.x-SCREEN_WIDTH, self.y)
	self.anim:draw(self.x, self.y+SCREEN_HEIGHT)
	self.anim:draw(self.x, self.y-SCREEN_HEIGHT)
end

function character:on_collide(e1, e2, dx, dy)

	if self.dead > 0 then return end

	if e2.type == "ground" then
		if math.abs(dy) < math.abs(dx) and ((dy < 0 and self.yspeed > 0) or (dy > 0 and self.yspeed < 0)) then
			self.yspeed = 0
			self.y = self.y + dy
		end

		if math.abs(dx) < math.abs(dy) and dx ~= 0 then
			self.xspeed = 0
			self.x = self.x + dx
		end
	elseif e2.type == "bridge" and self.yspeed > 0 and self.y+14 < e2.y then
		if math.abs(dy) < math.abs(dx) and dy ~= 0 then
			self.yspeed = 0
			self.y = self.y + dy
		end
	elseif e2.type == "bubble" and self.yspeed > 0 and self.y < e2.y then
		self.yspeed = -4
		if e2.child ~= nil then
			e2.child:die()
			table.insert(EFFECTS, newNotif({x=self.x, y=self.y, text="500"}))
		else
			table.insert(EFFECTS, newNotif({x=self.x, y=self.y, text="100"}))
			love.audio.play(SFX_explode)
		end
		table.insert(EFFECTS, newBubbleexp(e2))
		entity_remove(e2)
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
			self.yspeed = -5
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
		self:die()
	elseif e2.type == "gem" then
		love.audio.play(SFX_gem)
		table.insert(EFFECTS, newNotif({x=e2.x, y=e2.y, text="200"}))
		entity_remove(e2)
	end
end
