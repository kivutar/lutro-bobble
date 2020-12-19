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
		STAGE = STAGE + 1
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
