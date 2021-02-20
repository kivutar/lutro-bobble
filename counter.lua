local counter = {}
counter.__index = counter

function newCounter(n)
	n.type = ENT_COUNTER
	n.t = 0
	n.cross = false
	return setmetatable(n, counter)
end

function counter:update(dt)
	local gems = 0
	local chars = 0
	local enemies = 0

	for i=1, #ENTITIES do
		if ENTITIES[i].type == ENT_GEM then
			gems = gems + 1
		end
		if ENTITIES[i].type == ENT_CHARACTER then
			chars = chars + 1
		end
		if ENTITIES[i].type == ENT_EYE or ENTITIES[i].type == ENT_HEADY then
			enemies = enemies + 1
		end
	end

	if gems == 0 and self.t == 0 then
		self.t = 100
		BGM:stop()
		PHASE = "victory"
		STAGE = STAGE + 1
	end

	if chars == 0 and self.t == 0 then
		self.t = 100
		BGM:stop()
		PHASE = "gameover"
		STAGE = 0
		ENTITIES = {}
		SOLIDS = {}
		EFFECTS = {}
		SHADOWS = {}
		MAP = {}
		LAST_UID = 0
		table.insert(ENTITIES, newGameOver({}))
	end

	if enemies == 0 and not self.cross and self.t == 0 then
		self.cross = true
		table.insert(ENTITIES, newCross({x=16*10-8,y=16*5}))
		SFX_cross:play()
	end

	if self.t > 0 then
		self.t = self.t - 1
		if self.t == 1 then
			ENTITIES = {}
			SOLIDS = {}
			EFFECTS = {}
			SHADOWS = {}
			MAP = {}
			PHASE = "inter"
			table.insert(ENTITIES, newInter({}))
		end
	end
end

function counter:serialize()
	return {
		uid = self.uid,
		type = self.type,
		t = self.t,
		cross = self.cross
	}
end

function counter:unserialize(n)
	self.uid = n.uid
	self.type = n.type
	self.t = n.t
	self.cross = n.cross
end
