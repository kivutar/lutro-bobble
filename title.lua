local title = {}
title.__index = title

function newTitle(n)
	n.type = "title"
	n.t = 0
	return setmetatable(n, title)
end

function title:update(dt)
	local JOY_START  = love.joystick.isDown(1, RETRO_DEVICE_ID_JOYPAD_START)
	if JOY_START then
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
	
			load_map(MAP_classic2)
	
			table.insert(ENTITIES, newCharacter({x=1*16,y=13*16,pad=1,direction="right"}))
			table.insert(ENTITIES, newCharacter({x=18*16,y=13*16,pad=2,direction="left"}))
			-- table.insert(ENTITIES, newCharacter({x=3*16,y=7*16,pad=3}))
	
			love.audio.play(BGM_bgm)
		end
	end
end

function title:draw()
	love.graphics.setFont(FNT_letters)
	local w = FNT_letters:getWidth("PRESS START")
	lutro.graphics.print("PRESS START", SCREEN_WIDTH/2 - w/2, SCREEN_HEIGHT/2 - 16/2)
end
