local notif = {}
notif.__index = notif

function newNotif(n)
	n.y = n.y - 16
	n.yspeed = -2
	n.yaccel = 0.1

	return setmetatable(n, notif)
end

function notif:update(dt)
	self.yspeed = self.yspeed + self.yaccel
	self.y = self.y + self.yspeed

	if self.yspeed >= 0 then
		effect_remove(self)
	end
end

function notif:draw()
	love.graphics.setFont(FNT_points)
	love.graphics.print(self.text, math.floor(self.x), math.floor(self.y))
end

function notif:serialize()
	return {
		type = self.type,
		text = self.text,
		x = self.x,
		y = self.y,
		yspeed = self.yspeed,
		yaccel = self.yaccel,
	}
end

function notif:unserialize(n)
	self.type = n.type
	self.text = n.text
	self.x = n.x
	self.y = n.y
	self.yspeed = n.yspeed
	self.yaccel = n.yaccel
end
