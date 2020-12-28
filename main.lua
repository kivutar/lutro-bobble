require "global"
require "anim"
require "collisions"
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

	love.graphics.setBackgroundColor(0, 0, 0)
	math.randomseed(os.time())

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

	-- JOY_L = love.keyboard.isDown("q")
	JOY_L = love.joystick.isDown(1, RETRO_DEVICE_ID_JOYPAD_L)
	if JOY_L then L = L + 1 else L = 0 end
	if L == 1 then
		print('saving')
		serialize()
	end

	-- JOY_R = love.keyboard.isDown("w")
	JOY_R = love.joystick.isDown(1, RETRO_DEVICE_ID_JOYPAD_R)
	if JOY_R then R = R + 1 else R = 0 end
	if R == 1 then
		print('loading')
		unserialize()
	end
end

function love.draw()
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
		CHAR1 = table.deep_copy(CHAR1),
		CHAR2 = table.deep_copy(CHAR2),
		BGM = BGM,
		BGMplaying = BGM:isPlaying(),
		BGMsamples = BGM:tell("samples"),
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
	SHADOWS = {}
	SOLIDS = {}
	ENTITIES = {}
	EFFECTS = {}

	MAP = STATE.MAP
	PHASE = STATE.PHASE
	STAGE = STATE.STAGE
	BGM = STATE.BGM
	if STATE.BGMplaying then BGM:play() else BGM:stop() end
	BGM:seek(STATE.BGMsamples, "samples")

	for i=1, #STATE.SHADOWS do
		if STATE.SHADOWS[i].type == "shadow" then
			SHADOWS[i] = newShadow({})
		end
		SHADOWS[i]:unserialize(STATE.SHADOWS[i])
	end

	for i=1, #STATE.SOLIDS do
		if STATE.SOLIDS[i].type == "ground" then
			SOLIDS[i] = newGround(STATE.SOLIDS[i])
		elseif STATE.SOLIDS[i].type == "bridge" then
			SOLIDS[i] = newBridge({})
		end
		SOLIDS[i]:unserialize(STATE.SOLIDS[i])
	end

	for i=1, #STATE.ENTITIES do
		if STATE.ENTITIES[i].type == "title" then
			ENTITIES[i] = newTitle({})
		elseif STATE.ENTITIES[i].type == "inter" then
			ENTITIES[i] = newInter({})
		elseif STATE.ENTITIES[i].type == "gameover" then
			ENTITIES[i] = newGameOver({})
		elseif STATE.ENTITIES[i].type == "gem" then
			ENTITIES[i] = newGem({})
		elseif STATE.ENTITIES[i].type == "eye" then
			ENTITIES[i] = newEye({})
		elseif STATE.ENTITIES[i].type == "spikes" then
			ENTITIES[i] = newSpikes({})
		elseif STATE.ENTITIES[i].type == "bubble" then
			ENTITIES[i] = newBubble({})
		elseif STATE.ENTITIES[i].type == "cross" then
			ENTITIES[i] = newCross({})
		elseif STATE.ENTITIES[i].type == "bouncer" then
			ENTITIES[i] = newBouncer({})
		elseif STATE.ENTITIES[i].type == "character" then
			ENTITIES[i] = newCharacter({pad = STATE.ENTITIES[i].pad})
		elseif STATE.ENTITIES[i].type == "ghost" then
			ENTITIES[i] = newGhost({pad = STATE.ENTITIES[i].pad})
		end
		ENTITIES[i]:unserialize(STATE.ENTITIES[i])
	end

	for i=1, #STATE.EFFECTS do
		if STATE.EFFECTS[i].type == "notif" then
			EFFECTS[i] = newNotif({})
		elseif STATE.EFFECTS[i].type == "bubbleexp" then
			EFFECTS[i] = newBubbleexp({})
		elseif STATE.EFFECTS[i].type == "counter" then
			EFFECTS[i] = newCounter({})
		end
		EFFECTS[i]:unserialize(STATE.EFFECTS[i])
	end

	CHAR1 = STATE.CHAR1
	CHAR2 = STATE.CHAR2
end
