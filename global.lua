SCREEN_WIDTH = 320
SCREEN_HEIGHT = 240

ENTITIES = {}
SOLIDS = {}
EFFECTS = {}
SHADOWS = {}

MAP = {}

RETRO_DEVICE_ID_JOYPAD_B        = 1
RETRO_DEVICE_ID_JOYPAD_Y        = 2
RETRO_DEVICE_ID_JOYPAD_SELECT   = 3
RETRO_DEVICE_ID_JOYPAD_START    = 4
RETRO_DEVICE_ID_JOYPAD_UP       = 5
RETRO_DEVICE_ID_JOYPAD_DOWN     = 6
RETRO_DEVICE_ID_JOYPAD_LEFT     = 7
RETRO_DEVICE_ID_JOYPAD_RIGHT    = 8
RETRO_DEVICE_ID_JOYPAD_A        = 9
RETRO_DEVICE_ID_JOYPAD_X        = 10
RETRO_DEVICE_ID_JOYPAD_L        = 11
RETRO_DEVICE_ID_JOYPAD_R        = 12
RETRO_DEVICE_ID_JOYPAD_L2       = 13
RETRO_DEVICE_ID_JOYPAD_R2       = 14
RETRO_DEVICE_ID_JOYPAD_L3       = 15
RETRO_DEVICE_ID_JOYPAD_R3       = 16

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
