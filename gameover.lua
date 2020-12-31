local gameover = {}
gameover.__index = gameover

function newGameOver(n)
	n.type = ENT_GAMEOVER
	n.t = 0
	n.PRESSED = 0
	return setmetatable(n, gameover)
end

function gameover:update(dt)
	BGM_bgm:stop()

	local JOY_START  = love.keyboard.isDown("return")
	if lutro ~= nil then
		JOY_START  = love.joystick.isDown(1, RETRO_DEVICE_ID_JOYPAD_START)
	end

	if JOY_START then
		self.PRESSED = self.PRESSED + 1
	end

	if self.PRESSED == 1 then
		self.t = 60
	end

	if self.t > 0 then
		self.t = self.t - 1
		if self.t == 1 then
			PHASE = "game"
			STAGE = 1
			ENTITIES = {}
			SOLIDS = {}
			EFFECTS = {}
			SHADOWS = {}
			MAP = {}
			LAST_UID = 0
			table.insert(ENTITIES, newTitle({}))
		end
	end
end

function gameover:draw()
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
	love.graphics.setFont(FNT_letters)
	local w = FNT_letters:getWidth("GAME OVER")
	love.graphics.setColor(1, 1, 1, 1)
	if self.t/2 % 2 == 0 then
		love.graphics.print("GAME OVER", SCREEN_WIDTH/2 - w/2, SCREEN_HEIGHT/2 - 16/2)
	end
end

function gameover:serialize()
	return {
		uid = self.uid,
		type = self.type,
		t = self.t,
		PRESSED = self.PRESSED,
	}
end

function gameover:unserialize(n)
	self.uid = n.uid
	self.type = n.type
	self.t = n.t
	self.PRESSED = n.PRESSED
end
