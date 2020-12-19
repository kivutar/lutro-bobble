local counter = {}
counter.__index = counter

function newCounter(n)
	n.type = "counter"
	n.t = 0
	return setmetatable(n, counter)
end

function counter:update(dt)
	local gems = 0
	for i=1, #ENTITIES do
		if ENTITIES[i].type == "gem" then
			gems = gems + 1
		end
	end

	if gems == 0 and self.t == 0 then
		self.t = 100
		BGM_bgm:stop()
		PHASE = "victory"
	end

	if self.t > 0 then
		self.t = self.t - 1
		if self.t == 1 then
			ENTITIES = {}
			SOLIDS = {}
			EFFECTS = {}
			SHADOWS = {}
			MAP = {}
	
			load_map(MAP_classic)
	
			table.insert(ENTITIES, newCharacter({x=1*16,y=13*16,pad=1,direction="right"}))
			table.insert(ENTITIES, newCharacter({x=18*16,y=13*16,pad=2,direction="left"}))
			-- table.insert(ENTITIES, newCharacter({x=3*16,y=7*16,pad=3}))
	
			love.audio.play(BGM_bgm)
			PHASE = "game"
		end
	end
end
