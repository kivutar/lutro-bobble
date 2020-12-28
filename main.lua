require "global"
require "utils"
require "input"
require "run_override"
require "network"
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
local Game = 
{
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

-- Resets the game.
function Game:Reset()
	Game.tick = 0
end

-- Stores the state of all rollbackable objects and systems in the game.
function Game:StoreState()
	-- print("storestate")
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
function Game:RestoreState()
	print("restaurestate")
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
function Game:Update()
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
	Input:Update()

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

	Input.game = Game

	-- Initialize player input command buffers
	Input:InitializeBuffer(1)
	Input:InitializeBuffer(2)

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
	FNT_default = love.graphics.newFont(12)

	BGM = BGM_bgm
	BGM:setLooping(true)

	table.insert(ENTITIES, newTitle({}))

	Game.network = Network

	Game:Reset()

	-- Store game state before the first update
	Game:StoreState()
end


-- Gets the sync data to confirm the client game states are in sync
function Game:GetSyncData()
	-- For now we will just compare the x coordinates of the both players
	return love.data.pack("string", "nn", 0, 0) --self.players[1].physics.x, self.players[2].physics.x)
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

	love.window.showMessageBox( "Alert", "Desync detected", "info", true )
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
	rollbackFrames = lastGameTick - Network.lastSyncedTick

	-- Update the graph indicating the number of rollback frames
	rollbackGraphTable[ 1 + (lastGameTick % 60) * 2 + 1  ] = -1 * rollbackFrames * GRAPH_UNIT_SCALE

	if lastGameTick >= 0 and lastGameTick > (Network.lastSyncedTick + 1) and Network.confirmedTick > Network.lastSyncedTick then

		-- Must revert back to the last known synced game frame.
		Game:RestoreState()

		for i=1,rollbackFrames do
			-- Get input from the input history buffer. The network system will predict input after the last confirmed tick (for the remote player).
			Input:SetInputState(Input.localPlayerIndex, Network:GetLocalInputState(Game.tick)) -- Offset of 1 ensure it's used for the next game update.
			Input:SetInputState(Input.remotePlayerIndex, Network:GetRemoteInputState(Game.tick))

			local lastRolledBackGameTick = Game.tick
			Game:Update()
			Game.tick = Game.tick + 1

			-- Confirm that we are indeed still synced
			if lastRolledBackGameTick <= Network.confirmedTick then
				-- Store the state since we know it's synced. We really only need to call this on the last synced frame. 
				-- Leaving in for demonstration purposes.
				Game:StoreState()
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
			local syncData = love.data.pack("string", "nn", Game.players[1].physics.y, Game.players[2].physics.y)

			Game:RestoreState()

			-- Prevent polling for input since we set it directly from the input history.
			for i=1,ROLLBACK_TEST_FRAMES do
				-- Get input from a input history buffer that we update below
				Input:SetInputState(Input.localPlayerIndex, Network:GetLocalInputState(Game.tick))
				Input:SetInputState(Input.remotePlayerIndex, Network:GetRemoteInputState(Game.tick))

				Game.tick = Game.tick + 1
				Game:Update()

				-- Store only the first updated state
				if i == 1 then
					Game:StoreState()
				end
			end

			-- Get the sync data after a rollback and check to see if it matches the data before the rollback.
			local postSyncData = love.data.pack("string", "nn", Game.players[1].physics.y, Game.players[2].physics.y)

			if syncData ~= postSyncData then
				love.window.showMessageBox( "Alert", "Rollback Desync Detected", "info", true )
				love.event.quit(0)
			end
		end
	end
end

-- Used for testing performance. 
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
		Input:PollInputs(updateCommandBuffers)

		-- Network manager will handle updating inputs.
		if Network.enabled then
			-- Update local input history
			local sendInput = Input:GetLatestInput(Input.localPlayerIndex)
			Network:SetLocalInput(sendInput, lastGameTick+Network.inputDelay)

			-- Set the input state fo[r the current tick for the remote player's character.
			Input:SetInputState(Input.localPlayerIndex, Network:GetLocalInputState(lastGameTick))
			Input:SetInputState(Input.remotePlayerIndex, Network:GetRemoteInputState(lastGameTick))

		end

		-- Increment the tick count only when the game actually updates.
		Game:Update()

		Game.tick = Game.tick + 1

		-- Save stage after an update if testing rollbacks
		if ROLLBACK_TEST_ENABLED then
			-- Save local input history for this game tick
			Network:SetLocalInput(Input:GetLatestInput(Input.localPlayerIndex), lastGameTick)
		end

		if Network.enabled then
			-- Check whether or not the game state is confirmed to be in sync.
			-- Since we previously rolled back, it's safe to set the lastSyncedTick here since we know any previous frames will be synced.
			if  (Network.lastSyncedTick + 1) == lastGameTick and lastGameTick <= Network.confirmedTick then

				-- Increment the synced tick number if we have inputs
				Network.lastSyncedTick = lastGameTick	

				-- Applied the remote player's input, so this game frame should synced.
				Game:StoreState()

				-- Confirm the game clients are in sync
				Game:SyncCheck()
			end

		end
	end


	-- Since our input is update in Game:Update() we want to send the input as soon as possible. 
	-- Previously this as happening before the Game:Update() and adding uneeded latency.  
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
	love.graphics.scale(2)

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

	-- Shown while the server is running but not connected to a client.
	if Network.isServer and not Network.connectedToClient then
		love.graphics.setColor(1, 0, 0, 1)
		love.graphics.setFont(FNT_default)
		love.graphics.print("Network: Waiting on client to connect", 10, 40)
	end

	love.graphics.setColor(1, 1, 1, 1)
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
	--BGM:seek(STATE.BGMsamples, "samples")

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
			EFFECTS[i] = newNotif({y=0})
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
