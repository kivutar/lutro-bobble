local inter = {}
inter.__index = inter

function newInter(n)
	n.type = "inter"
	n.t = 0
	n.PRESSED = 0
	return setmetatable(n, inter)
end

function inter:update(dt)
	local JOY_START  = love.joystick.isDown(1, RETRO_DEVICE_ID_JOYPAD_START)
	if JOY_START then
		self.PRESSED = self.PRESSED + 1
	end

	if self.PRESSED == 1 then
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
			PHASE = "game"

			load_map(MAP_classic)

			table.insert(ENTITIES, newCharacter({x=1*16,y=13*16,pad=1,direction="right"}))
			table.insert(ENTITIES, newCharacter({x=18*16,y=13*16,pad=2,direction="left"}))
			-- table.insert(ENTITIES, newCharacter({x=3*16,y=7*16,pad=3}))

			love.audio.play(BGM_bgm)
		end
	end
end

function inter:draw()
	love.graphics.setFont(FNT_letters)
	local w = FNT_letters:getWidth("STAGE "..STAGE.."! READY ?")
	lutro.graphics.print("STAGE "..STAGE.."! READY?", SCREEN_WIDTH/2 - w/2, SCREEN_HEIGHT/2 - 16/2)
end
