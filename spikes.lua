require "collisions"

local spikes = {}
spikes.__index = spikes

function newSpikes(n)
	n.type = "spikes"
	n.y = n.y + 8
	n.width = 16
	n.height = 8
	n.img = lutro.graphics.newImage("assets/spikes.png")

	return setmetatable(n, spikes)
end

function spikes:update(dt)
end

function spikes:draw()
	lutro.graphics.draw(self.img, self.x, self.y-8)
end
