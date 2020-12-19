local bouncer = {}
bouncer.__index = bouncer

function newBouncer(n)
	n.type = "bouncer"
	n.width = 16
	n.height = 16
	n.xspeed = 0
	n.yspeed = 0
	n.img = lutro.graphics.newImage("assets/bouncer.png")

	return setmetatable(n, bouncer)
end

function bouncer:update(dt)
	if self.y >= SCREEN_HEIGHT then self.y = 0 end
	if self.y < 0 then self.y = SCREEN_HEIGHT end
	if self.x > SCREEN_WIDTH then self.x = 0 end
	if self.x < 0 then self.x = SCREEN_WIDTH end

	solid_collisions(self)
end

function bouncer:draw()
	lutro.graphics.draw(self.img, self.x, self.y)
end

function bouncer:on_collide(e1, e2, dx, dy)
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
	elseif e2.type == "character" and e2.yspeed <= 0 then
		self.xaccel = 0
		self.yaccel = 0
		self.xspeed = 0
		self.yspeed = 0
		if dx ~= 0 then
			self.x = self.x + dx/2
		end
	end
end