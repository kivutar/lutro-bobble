require "global"
require "utils"
require "anim"
require "collisions"
require "entities"
require "character"
require "ground"
require "bubble"
require "bubbleexp"
require "eye"
require "spikes"
require "bouncer"
require "gem"
require "shadow"
require "notif"
require "bridge"
require "maps"
require "title"
require "counter"
require "inter"
require "gameover"
require "cross"
require "ghost"

function love.conf(t)
	t.width  = SCREEN_WIDTH
	t.height = SCREEN_HEIGHT
end

function love.load()
	love.graphics.setBackgroundColor(0, 0, 0)
	love.graphics.setDefaultFilter("nearest", "nearest")
	math.randomseed(os.time())

	IMG_ground = love.graphics.newImage("assets/ground.png")
	IMG_ground_top = love.graphics.newImage("assets/ground_top.png")
	IMG_bg = love.graphics.newImage("assets/bg.png")
	IMG_bouncer = love.graphics.newImage("assets/bouncer.png")
	IMG_bridge = love.graphics.newImage("assets/bridge.png")
	IMG_bubble = love.graphics.newImage("assets/bubble.png")
	IMG_bubbleexp = love.graphics.newImage("assets/bubble_explode.png")
	IMG_cross = love.graphics.newImage("assets/cross.png")
	IMG_gem = love.graphics.newImage("assets/gem.png")
	IMG_shadow = love.graphics.newImage("assets/shadow.png")

	IMG_frog_stand_left = love.graphics.newImage("assets/frog_stand_left.png")
	IMG_frog_stand_right = love.graphics.newImage("assets/frog_stand_right.png")
	IMG_frog_run_left = love.graphics.newImage("assets/frog_run_left.png")
	IMG_frog_run_right = love.graphics.newImage("assets/frog_run_right.png")
	IMG_frog_jump_left = love.graphics.newImage("assets/frog_jump_left.png")
	IMG_frog_jump_right = love.graphics.newImage("assets/frog_jump_right.png")
	IMG_frog_ko_left = love.graphics.newImage("assets/frog_ko_left.png")
	IMG_frog_ko_right = love.graphics.newImage("assets/frog_ko_right.png")
	IMG_frog_die_left = love.graphics.newImage("assets/frog_die_left.png")
	IMG_frog_die_right = love.graphics.newImage("assets/frog_die_right.png")
	IMG_frog_ghost_left = love.graphics.newImage("assets/frog_ghost_left.png")
	IMG_frog_ghost_right = love.graphics.newImage("assets/frog_ghost_right.png")

	IMG_fox_stand_left = love.graphics.newImage("assets/fox_stand_left.png")
	IMG_fox_stand_right = love.graphics.newImage("assets/fox_stand_right.png")
	IMG_fox_run_left = love.graphics.newImage("assets/fox_run_left.png")
	IMG_fox_run_right = love.graphics.newImage("assets/fox_run_right.png")
	IMG_fox_jump_left = love.graphics.newImage("assets/fox_jump_left.png")
	IMG_fox_jump_right = love.graphics.newImage("assets/fox_jump_right.png")
	IMG_fox_ko_left = love.graphics.newImage("assets/fox_ko_left.png")
	IMG_fox_ko_right = love.graphics.newImage("assets/fox_ko_right.png")
	IMG_fox_die_left = love.graphics.newImage("assets/fox_die_left.png")
	IMG_fox_die_right = love.graphics.newImage("assets/fox_die_right.png")
	IMG_fox_ghost_left = love.graphics.newImage("assets/fox_ghost_left.png")
	IMG_fox_ghost_right = love.graphics.newImage("assets/fox_ghost_right.png")

	IMG_bird_stand_left = love.graphics.newImage("assets/bird_stand_left.png")
	IMG_bird_stand_right = love.graphics.newImage("assets/bird_stand_right.png")
	IMG_bird_run_left = love.graphics.newImage("assets/bird_run_left.png")
	IMG_bird_run_right = love.graphics.newImage("assets/bird_run_right.png")
	IMG_bird_jump_left = love.graphics.newImage("assets/bird_jump_left.png")
	IMG_bird_jump_right = love.graphics.newImage("assets/bird_jump_right.png")
	IMG_bird_ko_left = love.graphics.newImage("assets/bird_ko_left.png")
	IMG_bird_ko_right = love.graphics.newImage("assets/bird_ko_right.png")
	IMG_bird_die_left = love.graphics.newImage("assets/bird_die_left.png")
	IMG_bird_die_right = love.graphics.newImage("assets/bird_die_right.png")
	IMG_bird_ghost_left = love.graphics.newImage("assets/bird_ghost_left.png")
	IMG_bird_ghost_right = love.graphics.newImage("assets/bird_ghost_right.png")

	IMG_eye_run_left = love.graphics.newImage("assets/eye_run_left.png")
	IMG_eye_run_right = love.graphics.newImage("assets/eye_run_right.png")
	IMG_eye_captured_left = love.graphics.newImage("assets/eye_captured_left.png")
	IMG_eye_captured_right = love.graphics.newImage("assets/eye_captured_right.png")
	IMG_eye_die_left = love.graphics.newImage("assets/eye_die_left.png")
	IMG_eye_die_right = love.graphics.newImage("assets/eye_die_right.png")

	IMG_spikes_up = love.graphics.newImage("assets/spikes_up.png")
	IMG_spikes_down = love.graphics.newImage("assets/spikes_down.png")
	IMG_spikes_left = love.graphics.newImage("assets/spikes_left.png")
	IMG_spikes_right = love.graphics.newImage("assets/spikes_right.png")

	BGM_bgm = love.audio.newSource("assets/bgm.wav", "static")

	SFX_jump = love.audio.newSource("assets/jump.wav", "static")
	SFX_bubble = love.audio.newSource("assets/bubble.wav", "static")
	SFX_explode = love.audio.newSource("assets/explode.wav", "static")
	SFX_ko = love.audio.newSource("assets/ko.wav", "static")
	SFX_enemy_die = love.audio.newSource("assets/enemy_die.wav", "static")
	SFX_die = love.audio.newSource("assets/die.wav", "static")
	SFX_gem = love.audio.newSource("assets/gem.wav", "static")
	SFX_ok = love.audio.newSource("assets/ok.wav", "static")
	SFX_cross = love.audio.newSource("assets/cross.wav", "static")
	SFX_revive = love.audio.newSource("assets/revive.wav", "static")

	FNT_points = love.graphics.newImageFont("assets/points.png", "0123456789")
	FNT_letters = love.graphics.newImageFont("assets/letters.png", "ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789.!?")

	BGM = BGM_bgm
	BGM:setLooping(true)

	table.insert(ENTITIES, newTitle({}))
end

function love.update(dt)
	for i=1, #ENTITIES do
		if ENTITIES[i] and ENTITIES[i].update then
			ENTITIES[i]:update(dt)
		end
	end

	for i=1, #EFFECTS do
		if EFFECTS[i] and EFFECTS[i].update then
			EFFECTS[i]:update(dt)
		end
	end

	detect_collisions()

	JOY_L = love.keyboard.isDown("q")
	JOY_R = love.keyboard.isDown("w")
	if lutro ~= nil then
		JOY_L = love.joystick.isDown(1, RETRO_DEVICE_ID_JOYPAD_L)
		JOY_R = love.joystick.isDown(1, RETRO_DEVICE_ID_JOYPAD_R)
	end

	if JOY_L then L = L + 1 else L = 0 end
	if L == 1 then
		print('saving')
		serialize()
	end

	if JOY_R then R = R + 1 else R = 0 end
	if R == 1 then
		print('loading')
		unserialize()
	end
end

function love.draw()
	love.graphics.push()
	love.graphics.scale(3)

	love.graphics.draw(IMG_bg, 0, 0)

	for i=1, #SHADOWS do
		if SHADOWS[i].draw then
			SHADOWS[i]:draw()
		end
	end

	for i=1, #SOLIDS do
		if SOLIDS[i].draw then
			SOLIDS[i]:draw()
		end
	end

	for i=1, #ENTITIES do
		if ENTITIES[i].draw then
			ENTITIES[i]:draw()
		end
	end

	for i=1, #EFFECTS do
		if EFFECTS[i].draw then
			EFFECTS[i]:draw()
		end
	end

	love.graphics.pop()
end

function table.deep_copy(t)
	if not t then return nil end
	local t2 = {}
	for k,v in pairs(t) do
		if type(v) == "table" then
			t2[k] = table.deep_copy(v)
		else
			t2[k] = v
		end
	end
	return t2
end

STATE = {}
function serialize()
	STATE = {
		MAP = table.deep_copy(MAP),
		PHASE = PHASE,
		STAGE = STAGE,
		CHAR1 = nil,
		CHAR2 = nil,
		BGM = BGM,
		BGMplaying = BGM:isPlaying(),
		BGMsamples = BGM:tell("samples"),
		LAST_UID = LAST_UID,
	}

	STATE.SHADOWS = {}
	for i=1, #SHADOWS do
		if SHADOWS[i].serialize then
			STATE.SHADOWS[i] = SHADOWS[i]:serialize()
		end
	end

	STATE.SOLIDS = {}
	for i=1, #SOLIDS do
		if SOLIDS[i].serialize then
			STATE.SOLIDS[i] = SOLIDS[i]:serialize()
		end
	end

	STATE.ENTITIES = {}
	for i=1, #ENTITIES do
		if ENTITIES[i].serialize then
			STATE.ENTITIES[i] = ENTITIES[i]:serialize()
		end
	end

	STATE.EFFECTS = {}
	for i=1, #EFFECTS do
		if EFFECTS[i].serialize then
			STATE.EFFECTS[i] = EFFECTS[i]:serialize()
		end
	end
end

function unserialize()
	local redomap = STAGE ~= STATE.STAGE

	if redomap then
		SHADOWS = {}
		SOLIDS = {}
	end
	ENTITIES = {}
	EFFECTS = {}

	MAP = STATE.MAP
	PHASE = STATE.PHASE
	STAGE = STATE.STAGE
	BGM = STATE.BGM
	if STATE.BGMplaying then BGM:play() else BGM:stop() end
	BGM:seek(STATE.BGMsamples, "samples")
	LAST_UID = STATE.LAST_UID

	if redomap then
		for i=1, #STATE.SHADOWS do
			if STATE.SHADOWS[i].type == ENT_SHADOW then
				SHADOWS[i] = newShadow({})
			end
			SHADOWS[i]:unserialize(STATE.SHADOWS[i])
		end

		for i=1, #STATE.SOLIDS do
			if STATE.SOLIDS[i].type == ENT_GROUND then
				SOLIDS[i] = newGround(STATE.SOLIDS[i])
			elseif STATE.SOLIDS[i].type == ENT_BRIDGE then
				SOLIDS[i] = newBridge({})
			end
			SOLIDS[i]:unserialize(STATE.SOLIDS[i])
		end
	end

	for i=1, #STATE.ENTITIES do
		if STATE.ENTITIES[i].type == ENT_TITLE then
			ENTITIES[i] = newTitle({})
		elseif STATE.ENTITIES[i].type == ENT_INTER then
			ENTITIES[i] = newInter({})
		elseif STATE.ENTITIES[i].type == ENT_GAMEOVER then
			ENTITIES[i] = newGameOver({})
		elseif STATE.ENTITIES[i].type == ENT_GEM then
			ENTITIES[i] = newGem({})
		elseif STATE.ENTITIES[i].type == ENT_EYE then
			ENTITIES[i] = newEye({})
		elseif STATE.ENTITIES[i].type == ENT_SPIKES then
			ENTITIES[i] = newSpikes({})
		elseif STATE.ENTITIES[i].type == ENT_BUBBLE then
			ENTITIES[i] = newBubble({})
		elseif STATE.ENTITIES[i].type == ENT_CROSS then
			ENTITIES[i] = newCross({})
		elseif STATE.ENTITIES[i].type == ENT_BOUNCER then
			ENTITIES[i] = newBouncer({})
		elseif STATE.ENTITIES[i].type == ENT_CHARACTER then
			if STATE.ENTITIES[i].pad == 1 then
				CHAR1 = newCharacter({pad = 1})
				ENTITIES[i] = CHAR1
			elseif STATE.ENTITIES[i].pad == 2 then
				CHAR2 = newCharacter({pad = 2})
				ENTITIES[i] = CHAR2
			end
		elseif STATE.ENTITIES[i].type == ENT_GHOST then
			ENTITIES[i] = newGhost({pad = STATE.ENTITIES[i].pad})
		end
		ENTITIES[i]:unserialize(STATE.ENTITIES[i])
	end

	-- hack to relink eyes to bubbles
	for i=1, #ENTITIES do
		if ENTITIES[i].type == ENT_BUBBLE and ENTITIES[i].childuid ~= nil then
			for j=1, #ENTITIES do
				if ENTITIES[j].type == ENT_EYE and ENTITIES[j].uid == ENTITIES[i].childuid then
					ENTITIES[i].child = ENTITIES[j]
				end
			end
		end
	end

	for i=1, #STATE.EFFECTS do
		if STATE.EFFECTS[i].type == ENT_NOTIF then
			EFFECTS[i] = newNotif({y=0})
		elseif STATE.EFFECTS[i].type == ENT_BUBBLEEXP then
			EFFECTS[i] = newBubbleexp({})
		elseif STATE.EFFECTS[i].type == ENT_COUNTER then
			EFFECTS[i] = newCounter({})
		end
		EFFECTS[i]:unserialize(STATE.EFFECTS[i])
	end
end
