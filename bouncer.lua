local bouncer = {}
bouncer.__index = bouncer

function NewBouncer(n)
	n.type = ENT_BOUNCER
	n.width = 16
	n.height = 16
	n.xspeed = 0
	n.yspeed = 0
	n.img = IMG_bouncer

	return setmetatable(n, bouncer)
end

function bouncer:update(dt)
	-- screen wrapping
	self.x = self.x % SCREEN_WIDTH
	self.y = self.y % SCREEN_HEIGHT

	solid_collisions(self)
end

function bouncer:draw()
	love.graphics.draw(self.img, self.x, self.y)
end

function bouncer:on_collide(e1, e2, dx, dy)
	if e2.type == ENT_GROUND then
		self.xspeed = 0
		self.yspeed = 0
		self.x = self.x + dx
	elseif e2.type == ENT_BUBBLE then
		self.xspeed = self.xspeed/2
		self.yspeed = 0
		self.x = self.x + dx/2
	elseif e2.type == ENT_CHARACTER and e2.yspeed <= 0 then
		self.xspeed = 0
		self.yspeed = 0
		if dx ~= 0 then
			self.x = self.x + dx/2
		end
	end
end

function bouncer:serialize()
	return {
		uid = self.uid,
		type = self.type,
		x = self.x,
		y = self.y,
		xspeed = self.xspeed,
		yspeed = self.yspeed,
	}
end

function bouncer:unserialize(n)
	self.uid = n.uid
	self.type = n.type
	self.x = n.x
	self.y = n.y
	self.xspeed = n.xspeed
	self.yspeed = n.yspeed
end
