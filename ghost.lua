local ghost = {}
ghost.__index = ghost

JUMP_FORGIVENESS = 8

function newGhost(n)
	n.type = "ghost"
	n.width = 16
	n.height = 16
	n.xspeed = 0
	n.yspeed = 0
	if n.direction == nil then n.direction = "right" end
	n.stance = "ghost"
	n.speedlimit = 1.2
	n.t = 0

	n.skin = "frog"
	if n.pad == 2 then n.skin = "fox" end
	if n.pad == 3 then n.skin = "bird" end

	n.animations = {
		ghost = {
			left  = newAnimation(love.graphics.newImage("assets/"..n.skin.."_ghost_left.png"),  16, 16, 2, 10),
			right = newAnimation(love.graphics.newImage("assets/"..n.skin.."_ghost_right.png"), 16, 16, 2, 10)
		},
	}

	n.anim = n.animations[n.stance][n.direction]

	return setmetatable(n, ghost)
end

function ghost:update(dt)
	if PHASE == "victory" then return end

	self.t = self.t + 1

	local JOY_LEFT  = Input:CurrentInputState(self.pad).left
	local JOY_RIGHT = Input:CurrentInputState(self.pad).right
	local JOY_DOWN  = Input:CurrentInputState(self.pad).down
	local JOY_UP    = Input:CurrentInputState(self.pad).up

	-- moving
	if JOY_LEFT then
		self.xspeed = self.xspeed - 0.05
		if self.xspeed < -self.speedlimit then
			self.xspeed = -self.speedlimit
		end
		self.direction = "left"
	end

	if JOY_RIGHT then
		self.xspeed = self.xspeed + 0.05
		if self.xspeed > self.speedlimit then
			self.xspeed = self.speedlimit
		end
		self.direction = "right"
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
	self.x = self.x + self.xspeed
	self.y = self.y + self.yspeed

	-- screen wrapping
	if self.y >= SCREEN_HEIGHT then self.y = 0 end
	if self.y < 0 then self.y = SCREEN_HEIGHT end
	if self.x > SCREEN_WIDTH then self.x = 0 end
	if self.x < 0 then self.x = SCREEN_WIDTH end

	-- decelerating
	if  ((not JOY_RIGHT and self.xspeed > 0)
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
	self.anim:draw(self.x, self.y)
	self.anim:draw(self.x+SCREEN_WIDTH, self.y)
	self.anim:draw(self.x-SCREEN_WIDTH, self.y)
	self.anim:draw(self.x, self.y+SCREEN_HEIGHT)
	self.anim:draw(self.x, self.y-SCREEN_HEIGHT)
end

function ghost:on_collide(e1, e2, dx, dy)

	if e2.type == "cross" then
		love.audio.play(SFX_revive)
		entity_remove(e2)
		if self.pad == 1 then
			CHAR1 = newCharacter({x=self.x, y=self.y, pad=self.pad, skin=self.skin, direction=self.direction})
			table.insert(ENTITIES, CHAR1)
		elseif self.pad == 2 then
			CHAR2 = newCharacter({x=self.x, y=self.y, pad=self.pad, skin=self.skin, direction=self.direction})
			table.insert(ENTITIES, CHAR2)
		elseif self.pad == 3 then
			CHAR3 = newCharacter({x=self.x, y=self.y, pad=self.pad, skin=self.skin, direction=self.direction})
			table.insert(ENTITIES, CHAR3)
		end
		entity_remove(self)

	end
end

function ghost:serialize()
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
		skin = self.skin,
		stance = self.stance,
	}
end

function ghost:unserialize(n)
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
