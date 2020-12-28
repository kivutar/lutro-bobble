local title = {}
title.__index = title

function newTitle(n)
	n.type = "title"
	n.t = 0
	n.PRESSED = 0
	return setmetatable(n, title)
end

function title:update(dt)
	self.PRESSED = InputSystem:CurrentInputState(1).start_pressed
	if self.PRESSED then
		love.audio.play(SFX_ok)
		self.t = 60
	end

	if self.t > 0 then
		self.t = self.t - 1
		if self.t == 1 then
			ENTITIES = {}
			SOLIDS = {}
			EFFECTS = {}
			SHADOWS = {}
			MAP = {}

			load_map(STAGES[STAGE])

			CHAR1 = newCharacter({x=1*16,y=13*16,pad=1,direction="right"})
			CHAR2 = newCharacter({x=18*16,y=13*16,pad=2,direction="left"})
			table.insert(ENTITIES, CHAR1)
			table.insert(ENTITIES, CHAR2)
			-- table.insert(ENTITIES, newCharacter({x=3*16,y=7*16,pad=3}))

			love.audio.play(BGM)
		end
	end
end

function title:draw()
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
	love.graphics.setFont(FNT_letters)
	local w = FNT_letters:getWidth("PRESS START")
	love.graphics.setColor(1, 1, 1, 1)
	if self.t/2 % 2 == 0 then
		love.graphics.print("PRESS START", math.floor(SCREEN_WIDTH/2 - w/2), math.floor(SCREEN_HEIGHT/2 - 16/2))
	end
end

function title:serialize()
	return {
		type = self.type,
		t = self.t,
		PRESSED = self.PRESSED,
	}
end

function title:unserialize(n)
	self.type = n.type
	self.t = n.t
	self.PRESSED = n.PRESSED
end
