-- entity types
ENT_CHARACTER = 1
ENT_GROUND = 2
ENT_BUBBLE = 3
ENT_BUBBLEEXP = 4
ENT_EYE = 5
ENT_SPIKES = 6
ENT_BOUNCER = 7
ENT_GEM = 8
ENT_SHADOW = 9
ENT_NOTIF = 10
ENT_BRIDGE = 11
ENT_TITLE = 12
ENT_COUNTER = 13
ENT_INTER = 14
ENT_GAMEOVER = 15
ENT_CROSS = 16
ENT_GHOST = 17

function effect_remove(e)
	for i=1, #EFFECTS do
		if EFFECTS[i] == e then
			table.remove(EFFECTS, i)
		end
	end
end

function entity_remove(e)
	for i=1, #ENTITIES do
		if ENTITIES[i] == e then
			table.remove(ENTITIES, i)
		end
	end
end