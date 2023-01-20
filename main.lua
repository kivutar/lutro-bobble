require "global"
require "utils"
require "anim"
require "slam"
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
require "heady"
Json = require "json"
Input = require "input"

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

	IMG_turnip_stand_left = love.graphics.newImage("assets/turnip_stand_left.png")
	IMG_turnip_stand_right = love.graphics.newImage("assets/turnip_stand_right.png")
	IMG_turnip_run_left = love.graphics.newImage("assets/turnip_run_left.png")
	IMG_turnip_run_right = love.graphics.newImage("assets/turnip_run_right.png")
	IMG_turnip_jump_left = love.graphics.newImage("assets/turnip_jump_left.png")
	IMG_turnip_jump_right = love.graphics.newImage("assets/turnip_jump_right.png")
	IMG_turnip_fall_left = love.graphics.newImage("assets/turnip_fall_left.png")
	IMG_turnip_fall_right = love.graphics.newImage("assets/turnip_fall_right.png")
	IMG_turnip_ko_left = love.graphics.newImage("assets/turnip_die_left.png")
	IMG_turnip_ko_right = love.graphics.newImage("assets/turnip_die_right.png")
	IMG_turnip_die_left = love.graphics.newImage("assets/turnip_die_left.png")
	IMG_turnip_die_right = love.graphics.newImage("assets/turnip_die_right.png")
	IMG_turnip_ghost_left = love.graphics.newImage("assets/turnip_ghost_left.png")
	IMG_turnip_ghost_right = love.graphics.newImage("assets/turnip_ghost_right.png")

	IMG_croco_stand_left = love.graphics.newImage("assets/croco_stand_left.png")
	IMG_croco_stand_right = love.graphics.newImage("assets/croco_stand_right.png")
	IMG_croco_run_left = love.graphics.newImage("assets/croco_run_left.png")
	IMG_croco_run_right = love.graphics.newImage("assets/croco_run_right.png")
	IMG_croco_jump_left = love.graphics.newImage("assets/croco_jump_left.png")
	IMG_croco_jump_right = love.graphics.newImage("assets/croco_jump_right.png")
	IMG_croco_fall_left = love.graphics.newImage("assets/croco_fall_left.png")
	IMG_croco_fall_right = love.graphics.newImage("assets/croco_fall_right.png")
	IMG_croco_ko_left = love.graphics.newImage("assets/croco_die_left.png")
	IMG_croco_ko_right = love.graphics.newImage("assets/croco_die_right.png")
	IMG_croco_die_left = love.graphics.newImage("assets/croco_die_left.png")
	IMG_croco_die_right = love.graphics.newImage("assets/croco_die_right.png")
	IMG_croco_ghost_left = love.graphics.newImage("assets/croco_ghost_left.png")
	IMG_croco_ghost_right = love.graphics.newImage("assets/croco_ghost_right.png")

	IMG_cat_stand_left = love.graphics.newImage("assets/cat_stand_left.png")
	IMG_cat_stand_right = love.graphics.newImage("assets/cat_stand_right.png")
	IMG_cat_run_left = love.graphics.newImage("assets/cat_run_left.png")
	IMG_cat_run_right = love.graphics.newImage("assets/cat_run_right.png")
	IMG_cat_jump_left = love.graphics.newImage("assets/cat_jump_left.png")
	IMG_cat_jump_right = love.graphics.newImage("assets/cat_jump_right.png")
	IMG_cat_fall_left = love.graphics.newImage("assets/cat_fall_left.png")
	IMG_cat_fall_right = love.graphics.newImage("assets/cat_fall_right.png")
	IMG_cat_ko_left = love.graphics.newImage("assets/cat_die_left.png")
	IMG_cat_ko_right = love.graphics.newImage("assets/cat_die_right.png")
	IMG_cat_die_left = love.graphics.newImage("assets/cat_die_left.png")
	IMG_cat_die_right = love.graphics.newImage("assets/cat_die_right.png")
	IMG_cat_ghost_left = love.graphics.newImage("assets/cat_ghost_left.png")
	IMG_cat_ghost_right = love.graphics.newImage("assets/cat_ghost_right.png")

	IMG_eye_run_left = love.graphics.newImage("assets/eye_run_left.png")
	IMG_eye_run_right = love.graphics.newImage("assets/eye_run_right.png")
	IMG_eye_captured_left = love.graphics.newImage("assets/eye_captured_left.png")
	IMG_eye_captured_right = love.graphics.newImage("assets/eye_captured_right.png")
	IMG_eye_die_left = love.graphics.newImage("assets/eye_die_left.png")
	IMG_eye_die_right = love.graphics.newImage("assets/eye_die_right.png")

	IMG_heady_run_left = love.graphics.newImage("assets/heady_run_left.png")
	IMG_heady_run_right = love.graphics.newImage("assets/heady_run_right.png")
	IMG_heady_captured_left = love.graphics.newImage("assets/heady_captured_left.png")
	IMG_heady_captured_right = love.graphics.newImage("assets/heady_captured_right.png")
	IMG_heady_die_left = love.graphics.newImage("assets/heady_die_left.png")
	IMG_heady_die_right = love.graphics.newImage("assets/heady_die_right.png")

	IMG_spikes_up = love.graphics.newImage("assets/spikes_up.png")
	IMG_spikes_down = love.graphics.newImage("assets/spikes_down.png")
	IMG_spikes_left = love.graphics.newImage("assets/spikes_left.png")
	IMG_spikes_right = love.graphics.newImage("assets/spikes_right.png")

	BGM_bgm = NewSource("assets/Troth.ogg", "stream")

	SFX_jump = NewSource("assets/jump.wav", "static")
	SFX_bubble = NewSource("assets/bubble.wav", "static")
	SFX_explode = NewSource("assets/explode.wav", "static")
	SFX_ko = NewSource("assets/ko.wav", "static")
	SFX_enemy_die = NewSource("assets/enemy_die.wav", "static")
	SFX_die = NewSource("assets/die.wav", "static")
	SFX_gem = NewSource("assets/gem.wav", "static")
	SFX_ok = NewSource("assets/ok.wav", "static")
	SFX_cross = NewSource("assets/cross.wav", "static")
	SFX_revive = NewSource("assets/revive.wav", "static")

	FNT_points = love.graphics.newImageFont("assets/points.png", "0123456789", 1)
	FNT_letters = love.graphics.newImageFont("assets/letters.png", "ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789.!?", 1)

	BGM = BGM_bgm
	BGM:setLooping(true)

	table.insert(ENTITIES, NewTitle({}))
end

function love.update(dt)
	Input.update(dt)

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

function love.serializeSize()
	return 200000
end

function love.serialize(size)
	local state = {
		MAP = table.deep_copy(MAP),
		PHASE = PHASE,
		STAGE = STAGE,
		CHAR1 = nil,
		CHAR2 = nil,
		BGMtarget = BGM.target,
		BGMplaying = BGM:isPlaying(),
		BGMsamples = BGM:tell("samples"),
		LAST_UID = LAST_UID,
	}

	state.SHADOWS = {}
	for i=1, #SHADOWS do
		if SHADOWS[i].serialize then
			state.SHADOWS[i] = SHADOWS[i]:serialize()
		end
	end

	state.SOLIDS = {}
	for i=1, #SOLIDS do
		if SOLIDS[i].serialize then
			state.SOLIDS[i] = SOLIDS[i]:serialize()
		end
	end

	state.ENTITIES = {}
	for i=1, #ENTITIES do
		if ENTITIES[i].serialize then
			state.ENTITIES[i] = ENTITIES[i]:serialize()
		end
	end

	state.EFFECTS = {}
	for i=1, #EFFECTS do
		if EFFECTS[i].serialize then
			state.EFFECTS[i] = EFFECTS[i]:serialize()
		end
	end

	return Json.stringify(state)
end

function love.unserialize(data, size)
	if data == nil then return end

	local state = Json.parse(data)

	local redomap = true -- STAGE ~= state.STAGE

	if redomap then
		SHADOWS = {}
		SOLIDS = {}
	end
	ENTITIES = {}
	EFFECTS = {}

	MAP = state.MAP
	PHASE = state.PHASE
	STAGE = state.STAGE
	if BGM then BGM:stop() end
	if state.BGMtarget ~= BGM.target then BGM = NewSource(state.BGMtarget, "stream") end
	if state.BGMplaying then BGM:play() else BGM:stop() end
	BGM:seek(state.BGMsamples, "samples")
	LAST_UID = state.LAST_UID

	if redomap then
		for i=1, #state.SHADOWS do
			if state.SHADOWS[i].type == ENT_SHADOW then
				SHADOWS[i] = NewShadow({})
			end
			SHADOWS[i]:unserialize(state.SHADOWS[i])
		end

		for i=1, #state.SOLIDS do
			if state.SOLIDS[i].type == ENT_GROUND then
				SOLIDS[i] = NewGround(state.SOLIDS[i])
			elseif state.SOLIDS[i].type == ENT_BRIDGE then
				SOLIDS[i] = NewBridge({})
			end
			SOLIDS[i]:unserialize(state.SOLIDS[i])
		end
	end

	for i=1, #state.ENTITIES do
		if state.ENTITIES[i].type == ENT_TITLE then
			ENTITIES[i] = NewTitle({})
		elseif state.ENTITIES[i].type == ENT_INTER then
			ENTITIES[i] = NewInter({})
		elseif state.ENTITIES[i].type == ENT_GAMEOVER then
			ENTITIES[i] = NewGameOver({})
		elseif state.ENTITIES[i].type == ENT_GEM then
			ENTITIES[i] = NewGem({})
		elseif state.ENTITIES[i].type == ENT_EYE then
			ENTITIES[i] = NewEye({})
		elseif state.ENTITIES[i].type == ENT_HEADY then
			ENTITIES[i] = NewHeady({})
		elseif state.ENTITIES[i].type == ENT_SPIKES then
			ENTITIES[i] = NewSpikes({})
		elseif state.ENTITIES[i].type == ENT_BUBBLE then
			ENTITIES[i] = NewBubble({})
		elseif state.ENTITIES[i].type == ENT_CROSS then
			ENTITIES[i] = NewCross({})
		elseif state.ENTITIES[i].type == ENT_BOUNCER then
			ENTITIES[i] = NewBouncer({})
		elseif state.ENTITIES[i].type == ENT_CHARACTER then
			if state.ENTITIES[i].pad == 1 then
				CHAR1 = NewCharacter({pad = 1})
				ENTITIES[i] = CHAR1
			elseif state.ENTITIES[i].pad == 2 then
				CHAR2 = NewCharacter({pad = 2})
				ENTITIES[i] = CHAR2
			end
		elseif state.ENTITIES[i].type == ENT_GHOST then
			ENTITIES[i] = NewGhost({pad = state.ENTITIES[i].pad})
		end
		ENTITIES[i]:unserialize(state.ENTITIES[i])
	end

	-- hack to relink eyes to bubbles
	for i=1, #ENTITIES do
		if ENTITIES[i].type == ENT_BUBBLE and ENTITIES[i].childuid ~= nil then
			for j=1, #ENTITIES do
				if (ENTITIES[j].type == ENT_EYE or ENTITIES[j].type == ENT_HEADY) and ENTITIES[j].uid == ENTITIES[i].childuid then
					ENTITIES[i].child = ENTITIES[j]
					print('attach enemy '..ENTITIES[j].uid..' with x='..ENTITIES[j].x..' to bubble '..ENTITIES[i].uid..' with x='..ENTITIES[i].x)
				end
			end
		end
	end

	for i=1, #state.EFFECTS do
		if state.EFFECTS[i].type == ENT_NOTIF then
			EFFECTS[i] = NewNotif({y=0})
		elseif state.EFFECTS[i].type == ENT_BUBBLEEXP then
			EFFECTS[i] = NewBubbleexp({})
		elseif state.EFFECTS[i].type == ENT_COUNTER then
			EFFECTS[i] = NewCounter({})
		end
		EFFECTS[i]:unserialize(state.EFFECTS[i])
	end
end

function love.reset()
	SHADOWS = {}
	SOLIDS = {}
	ENTITIES = {}
	EFFECTS = {}
	PHASE = nil
	STAGE = 1
	CHAR1 = nil
	CHAR2 = nil
	BGM = nil
	LAST_UID = 0

	love.load()
end
