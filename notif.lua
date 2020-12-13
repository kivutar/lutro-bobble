require "collisions"

local notif = {}
notif.__index = notif

function newNotif(n)
	n.y = n.y - 16
	n.width = 0
	n.height = 0
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
	lutro.graphics.print(self.text, self.x, self.y)
end