require "global"
require "utils"
require "input"
require "run_override"
require "network"
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

-- This table stores time sync data that will be used for drawing the sync graph.
local timeSyncGraphTable = {}

for i=0,60-1 do
	timeSyncGraphTable[1+i*2] = i*10
	timeSyncGraphTable[1+(i*2 + 1)] = 0
end

-- Table for storing graph data for monitoring the number of rollbacked frames
local rollbackGraphTable = {}

for i=0,60-1 do
	rollbackGraphTable[1+i*2] = i*10
	rollbackGraphTable[1+(i*2 + 1)] = 0
end

-- Manages the game state
Game = {
	-- Enabled when the game is paused
	paused = false,

	-- Enabled when game needs to update for a single frame.
	frameStep = false,

	-- Number of ticks since the start of the game.
	tick = 0,

	-- The confirmed tick checked the last frame
	lastConfirmedTick = -1,

	-- Indicates that sync occurred last update
	syncedLastUpdate = false,

	-- Used to force dropped frames to test network syncing code
	forcePause = false
}

-- Stores the state of all rollbackable objects and systems in the game.
function Game:serialize()
	-- print("serialize")
	self.storedState = {}

	-- -- All rollbackable objects and systems will have a CopyState() method.
	-- self.storedState.world = World:CopyState()
	self.storedState.input = Input:serialize()
	-- self.storedState.matchSystem = MatchSystem:CopyState()
	-- self.storedState.players = {self.players[1]:CopyState(), self.players[2]:CopyState()}

	serialize()

	self.storedState.tick  = self.tick
end

-- Restores the state of all rollbackable objects and systems in the game.
function Game:unserialize()
	print("unserialize")
	-- Can't restore the state if has not been saved yet.
	if not self.storedState then
		return
	end

	-- -- All rollbackable objects and systems will have a SetState() method.
	-- World:SetState(self.storedState.world)
	Input:unserialize(self.storedState.input)
	-- MatchSystem:SetState(self.storedState.matchSystem)
	-- self.players[1]:SetState(self.storedState.players[1])
	-- self.players[2]:SetState(self.storedState.players[2])

	unserialize()

	self.tick = self.storedState.tick
end

-- Top level update for the game state.
function Game:update()
	local dt = 1 / 60

	-- Pause and frame step control
	if Game.paused then
		if Game.frameStep then
			Game.frameStep = false
		else
			-- Do not update the game when paused.
			return
		end
	end

	-- Update the input system
	Input:update()

	-- When the world state is paused, don't update any of the players
	--if not World.stop then
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
	--end
end

function love.conf(t)
	t.width  = SCREEN_WIDTH
	t.height = SCREEN_HEIGHT
end

function love.load()
	Input.joysticks = love.joystick.getJoysticks()
	for _, stick in pairs(Input.joysticks) do
		print("Found Gamepad: " .. stick:getName())
	end

	love.keyboard.setKeyRepeat(false)

	-- Initialize player input command buffers
	Input:initializeBuffer(1)
	Input:initializeBuffer(2)

	love.graphics.setBackgroundColor(0, 0, 0)
	love.graphics.setDefaultFilter("nearest", "nearest")
	-- math.randomseed(os.time())

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

	Game.tick = 0

	-- Store game state before the first update
	Game:serialize()
end

-- Gets the sync data to confirm the client game states are in sync
function Game:GetSyncData()
	-- For now we will just compare the x coordinates of the both players
	if CHAR1 and CHAR2 then
		return love.data.pack("string", "nnnn", math.floor(CHAR1.x), math.floor(CHAR1.y), math.floor(CHAR2.x), math.floor(CHAR2.y))
	end
	return love.data.pack("string", "nnnn", 0, 0, 0, 0)
end

-- Checks whether or not a game state desync has occurred between the local and remote clients.
function Game:SyncCheck()
	if not NET_DETECT_DESYNCS then
		return
	end

	if Network.lastSyncedTick < 0 then
		return
	end

	-- Check desyncs at a fixed rate.
	if (Network.lastSyncedTick % Network.desyncCheckRate) ~= 0 then
		return
	end

	-- Generate the data we'll send to the other player for testing that their game state is in sync.
	Network:SetLocalSyncData(Network.lastSyncedTick, Game:GetSyncData())

	-- Send sync data everytime we've applied from the remote player to a game frame.
	Network:SendSyncData()

	local desynced, desyncFrame = Network:DesyncCheck()
	if not desynced then
		return
	end

	-- Detect when the sync data doesn't match then halt the game
	NetLog("Desync detected at tick: " .. desyncFrame)

	love.window.showMessageBox("Alert", "Desync detected", "info", true)
	-- the log afterward is pretty useless so exiting here. It also helps to know when a desync occurred.
	love.event.quit(0)
end

-- Rollback if needed.
function HandleRollbacks()
	local lastGameTick = Game.tick - 1
	-- The input needed to resync state is available so rollback.
	-- Network.lastSyncedTick keeps track of the lastest synced game tick.
	-- When the tick count for the inputs we have is more than the number of synced ticks it's possible to rerun those game updates
	-- with a rollback.

	-- The number of frames that's elasped since the game has been out of sync.
	-- Rerun rollbackFrames number of updates.
	local rollbackFrames = lastGameTick - Network.lastSyncedTick

	-- Update the graph indicating the number of rollback frames
	rollbackGraphTable[ 1 + (lastGameTick % 60) * 2 + 1  ] = -1 * rollbackFrames * GRAPH_UNIT_SCALE

	if lastGameTick >= 0 and lastGameTick > (Network.lastSyncedTick + 1) and Network.confirmedTick > Network.lastSyncedTick then

		-- Must revert back to the last known synced game frame.
		Game:unserialize()

		for i=1,rollbackFrames do
			-- Get input from the input history buffer. The network system will predict input after the last confirmed tick (for the remote player).
			Input:setState(Input.localPlayerIndex, Network:GetLocalInputState(Game.tick)) -- Offset of 1 ensure it's used for the next game update.
			Input:setState(Input.remotePlayerIndex, Network:GetRemoteInputState(Game.tick))

			local lastRolledBackGameTick = Game.tick
			Game:update()
			Game.tick = Game.tick + 1

			-- Confirm that we are indeed still synced
			if lastRolledBackGameTick <= Network.confirmedTick then
				-- Store the state since we know it's synced. We really only need to call this on the last synced frame.
				-- Leaving in for demonstration purposes.
				Game:serialize()
				Network.lastSyncedTick = lastRolledBackGameTick

				-- Confirm the game clients are in sync
				Game:SyncCheck()
			end
		end
	end

end

-- Handles testing rollbacks offline.
function TestRollbacks()
	if ROLLBACK_TEST_ENABLED then
		if Game.tick >= ROLLBACK_TEST_FRAMES then

			-- Get sync data that we'll test after the rollback
			local syncData = Game:GetSyncData()

			Game:unserialize()

			-- Prevent polling for input since we set it directly from the input history
			for i=1,ROLLBACK_TEST_FRAMES do
				-- Get input from a input history buffer that we update below
				Input:setState(Input.localPlayerIndex, Network:GetLocalInputState(Game.tick))
				Input:setState(Input.remotePlayerIndex, Network:GetRemoteInputState(Game.tick))

				Game.tick = Game.tick + 1
				Game:update()

				-- Store only the first updated state
				if i == 1 then
					Game:serialize()
				end
			end

			-- Get the sync data after a rollback and check to see if it matches the data before the rollback.
			local postSyncData = Game:GetSyncData()

			if syncData ~= postSyncData then
				love.window.showMessageBox("Alert", "Rollback Desync Detected", "info", true)
				love.event.quit(0)
			end
		end
	end
end

-- Used for testing performance
local lastTime = love.timer.getTime()

function love.update(dt)
	local lastGameTick = Game.tick

	local updateGame = false

	if ROLLBACK_TEST_ENABLED then
		updateGame = true
	end

	-- The network is update first
	if Network.enabled then
		-- Setup the local input delay to match the network input delay.
		-- If this isn't done, the two game clients will be out of sync with each other as the local player's input will be applied on the current frame,
		-- while the opponent's will be applied to a frame inputDelay frames in the input buffer.
		Input.inputDelay = Network.inputDelay

		-- First get any data that has been sent from the other client
		Network:ReceiveData()

		-- Send any packets that have been queued
		Network:ProcessDelayedPackets()

		if Network.connectedToClient then

			-- First we assume that the game can be updated, sync checks below can halt updates
			updateGame = true

			if Game.forcePause then
				updateGame = false
			end

			-- Run any rollbacks that can be processed before the next game update
			HandleRollbacks()

			-- Calculate the difference between remote game tick and the local. This will be used for syncing.
			-- We don't use the latest local tick, but the tick for the latest input sent to the remote client.
			Network.localTickDelta = lastGameTick - Network.confirmedTick

			timeSyncGraphTable[ 1 + (lastGameTick % 60) * 2 + 1  ] = -1 * (Network.localTickDelta - Network.remoteTickDelta) * GRAPH_UNIT_SCALE

			-- Only do time sync check when the previous confirmed tick from the remote client hasn't been used yet.
			if Network.confirmedTick > Game.lastConfirmedTick then

				Game.lastConfirmedTick = Network.confirmedTick

				-- Prevent updating the game when the tick difference is greater on this end.
				-- This allows the game deltas to be off by 2 frames. Our timing is only accurate to one frame so any slight increase in network latency
				-- would cause the game to constantly hold. You could increase this tolerance, but this would increase the advantage for one player over the other.

				-- Only calculate time sync frames when we are not currently time syncing.
				if Network.tickSyncing == false then
					-- Calculate tick offset using the clock synchronization algorithm.
					-- See https://en.wikipedia.org/wiki/Network_Time_Protocol#Clock_synchronization_algorithm
					Network.tickOffset = (Network.localTickDelta - Network.remoteTickDelta) / 2.0

					-- Only sync when the tick difference is more than one frame.
					if Network.tickOffset >= 1 then
						Network.tickSyncing = true
					end
				end

				if Network.tickSyncing and Game.syncedLastUpdate == false then
					updateGame = false
					Game.syncedLastUpdate = true

					Network.tickOffset = Network.tickOffset - 1

					-- Stop time syncing when the tick difference is less than 1 so we don't overshoot
					if Network.tickOffset < 1 then
						Network.tickSyncing = false
					end
				else
					Game.syncedLastUpdate = false
				end

			end

			-- Only halt the game update based on exceeding the rollback window when the game updated hasn't previously been stopped by time sync code
			if updateGame then
				-- We allow the game to run for NET_ROLLBACK_MAX_FRAMES updates without having input for the current frame.
				-- Once the game can no longer update, it will wait until the other player's client can catch up.
				if lastGameTick <= (Network.confirmedTick + NET_ROLLBACK_MAX_FRAMES) then
					updateGame = true
				else
					updateGame = false
				end
			end
		end
	end

	if updateGame then
		-- Test rollbacks
		TestRollbacks()

		-- Poll inputs for this frame. In network mode the network manager will handle updating player command buffers.
		local updateCommandBuffers = not Network.enabled
		Input:poll(updateCommandBuffers)

		-- Network manager will handle updating inputs.
		if Network.enabled then
			-- Update local input history
			local sendInput = Input:getLatest(Input.localPlayerIndex)
			Network:SetLocalInput(sendInput, lastGameTick+Network.inputDelay)

			-- Set the input state fo[r the current tick for the remote player's character.
			Input:setState(Input.localPlayerIndex, Network:GetLocalInputState(lastGameTick))
			Input:setState(Input.remotePlayerIndex, Network:GetRemoteInputState(lastGameTick))
		end

		-- Increment the tick count only when the game actually updates.
		Game:update()

		Game.tick = Game.tick + 1

		-- Save stage after an update if testing rollbacks
		if ROLLBACK_TEST_ENABLED then
			-- Save local input history for this game tick
			Network:SetLocalInput(Input:getLatest(Input.localPlayerIndex), lastGameTick)
		end

		if Network.enabled then
			-- Check whether or not the game state is confirmed to be in sync.
			-- Since we previously rolled back, it's safe to set the lastSyncedTick here since we know any previous frames will be synced.
			if  (Network.lastSyncedTick + 1) == lastGameTick and lastGameTick <= Network.confirmedTick then
				-- Increment the synced tick number if we have inputs
				Network.lastSyncedTick = lastGameTick

				-- Applied the remote player's input, so this game frame should synced.
				Game:serialize()

				-- Confirm the game clients are in sync
				Game:SyncCheck()
			end

		end
	end

	-- Since our input is update in Game:update() we want to send the input as soon as possible.
	-- Previously this as happening before the Game:update() and adding uneeded latency.
	if Network.enabled and Network.connectedToClient  then
		-- if updateGame then
		-- 	PacketLog("Sending Input: " .. Network:GetLocalInputEncoded(lastGameTick + Network.inputDelay) .. ' @ ' .. lastGameTick + Network.inputDelay  )
		-- end

		-- Send this player's input state. We when Network.inputDelay frames ahead.
		-- Note: This input comes from the last game update, so we subtract 1 to set the correct tick.
		Network:SendInputData(Game.tick - 1 + Network.inputDelay)

		-- Send ping so we can test network latency.
		Network:SendPingMessage()
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

	-- Shown while the server is running but not connected to a client.
	if Network.isServer and not Network.connectedToClient then
		love.graphics.setColor(1, 0, 0, 1)
		love.graphics.setFont(FNT_letters)
		love.graphics.print("WAITING ON CLIENT TO CONNECT", 12, 12)
	end
	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.pop()
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
	-- BGM:seek(STATE.BGMsamples, "samples")

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
			ENTITIES[i] = newSpikes({y = STATE.ENTITIES[i].y, direction = STATE.ENTITIES[i].direction})
		elseif STATE.ENTITIES[i].type == ENT_BUBBLE then
			ENTITIES[i] = newBubble({})
		elseif STATE.ENTITIES[i].type == ENT_CROSS then
			ENTITIES[i] = newCross({})
		elseif STATE.ENTITIES[i].type == ENT_BOUNCER then
			ENTITIES[i] = newBouncer({})
		elseif STATE.ENTITIES[i].type == ENT_CHARACTER then
			if STATE.ENTITIES[i].pad == 1 then
				CHAR1 = newCharacter({pad = 1, direction = STATE.ENTITIES[i].direction})
				ENTITIES[i] = CHAR1
			elseif STATE.ENTITIES[i].pad == 2 then
				CHAR2 = newCharacter({pad = 2, direction = STATE.ENTITIES[i].direction})
				ENTITIES[i] = CHAR2
			end
		elseif STATE.ENTITIES[i].type == ENT_GHOST then
			ENTITIES[i] = newGhost({pad = STATE.ENTITIES[i].pad})
		end
		ENTITIES[i]:unserialize(STATE.ENTITIES[i])
	end

	-- hack to relink eyes to bubbles
	for i=1, #ENTITIES do
		if ENTITIES[i].type == ENT_BUBBLE and ENTITIES[i].haschild then
			for j=1, #ENTITIES do
				if ENTITIES[j].type == ENT_EYE and ENTITIES[j].x == ENTITIES[i].x and ENTITIES[j].y == ENTITIES[i].y then
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
