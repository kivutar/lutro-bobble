local socket = require("socket")
local json = require("json")

local netlogName = 'netlog-'.. os.time(os.date("!*t")) ..'.txt'
local packetLogName = 'packetLog-'.. os.time(os.date("!*t")) ..'.txt'

-- Create net log file
love.filesystem.write(netlogName, 'Network log start\r\n')
love.filesystem.write(packetLogName, 'Packet log start\r\n')

function NetLog(data)
	love.filesystem.append(netlogName, data  .. '\r\n')
	-- print(data)
end

function PacketLog(data)
	love.filesystem.append(packetLogName, data  .. '\r\n')
	-- print(data)
end

-- Network code indicating the type of message.
local MsgCode = {
	Handshake = 1,		-- Used when sending the hand shake.
	PlayerInput = 2,	-- Sends part of the player's input buffer.
	Ping = 3,			-- Used to tracking packet round trip time. Expect a "Pong" back.
	Pong = 4,			-- Sent in reply to a Ping message for testing round trip time.
	Sync = 5,			-- Used to pass sync data
}

-- Bit flags used to convert input state to a form suitable for network transmission.
local Btn = {
	Up 		= bit.lshift(1, 0),
	Down 	= bit.lshift(1, 1),
	Left 	= bit.lshift(1, 2),
	Right 	= bit.lshift(1, 3),
	Attack 	= bit.lshift(1, 4),
	Jump    = bit.lshift(1, 5),
	Start   = bit.lshift(1, 6),
}

-- Generates a string which is used to pack/unpack the data in a player input packet.
-- This format string is used by the love.data.pack() and love.data.unpack() functions.
local INPUT_FORMAT_STRING = string.format('Bjj%.' .. NET_SEND_HISTORY_SIZE .. 's', 'BBBBBBBBBBBBBBBBBB')

-- Packing string for sync data
local SYNC_DATA_FORMAT_STRING = "Bjs16"

-- This object will handle all network related functionality
Network = {
	enabled = false,				-- Set to true when the network is running.
	connectedToClient = false,		-- Indicates whether or not the game is connected to another client

	clientIP = "",					-- Detected network address for the non-server client
	clientPort = -1,				-- Detected port for the non-server client

	confirmedTick = 0,				-- The confirmed tick indicates up to what game frame we have the inputs for.

	inputHistory = {},				-- The input history for the local player. Stored as bit flag encoded input states.
	remoteInputHistory = {},		-- The input history for the local player. Stored as bit flag encoded input states.

	syncDataHistoryLocal = {},		-- Keeps track of the sync data for the local client
	syncDataHistoryRemote = {},		-- Keeps track of the sync data for the remote client

	syncDataTicks = {},				-- Keeps track of the tick for each sync data index

	latency = 0,					-- Keeps track of the latency.

	toSendPackets = {},				-- Packets that have been queued for sending later. Used to test network latency.

	lastSyncedTick =-1,				-- Indicates the last game tick that was confirmed to be in sync.

	localTickDelta = 0,				-- Stores the difference between the last local tick and the remote confirmed tick. Remote client.
	remoteTickDelta = 0,			-- Stores the difference between the last local tick and the remote confirmed tick sent from the remote client.

	tickOffset = 0.0,				-- Current difference between remote and local ticks
	tickSyncing = false,			-- Indicates whether or not the game is currently in time syncing mode.

	desyncCheckRate = 20,			-- The rate at which we check for state desyncs.
	localSyncData = nil,			-- Latest local data for state desync checking.
	remoteSyncData = nil,			-- Latest remote data for state desync checking.
	localSyncDataTick = -1,			-- Tick for the latest local desync data.
	remoteSyncDataTick = -1,		-- Tick for the latest remote desync data.

	isStateDesynced = false,		-- Set to true once a game state desync is detected.
}

-- Initialize History Buffer
function Network:InitializeInputHistoryBuffer()
	-- local emptySyncData = love.data.pack("string", "nn", 0, 0)
	for i=1, NET_INPUT_HISTORY_SIZE do
		self.inputHistory[i] = 0
		self.remoteInputHistory[i] = 0
		self.syncDataHistoryLocal[i] = nil
		self.syncDataHistoryRemote[i] = nil
		self.syncDataTicks[i] = nil
	end
end

-- Probably will move this call to some initialization function.
Network:InitializeInputHistoryBuffer()

function Network:HolePunch()
	local rdv = socket.udp4()
	rdv:setpeername(RDV_IP, RDV_PORT)

	rdv:send("hi")
	local data = assert(rdv:receive())
	local my = json.parse(data)
	print("I am", my.ip, my.port)

	local data = assert(rdv:receive())
	local peer = json.parse(data)
	print("I see", peer.ip, peer.port)
	self.clientIP = peer.ip
	self.clientPort = peer.port

	assert(rdv:close())

	local p2p = assert(socket.udp4())
	assert(p2p:settimeout(0))
	assert(p2p:setsockname('*', my.port))

	print("sending hello")
	assert(p2p:sendto("hello", peer.ip, peer.port))

	while true do
		local data = p2p:receive()
		if data then
			print("received", data)
			if data == "hohai" then break end
			assert(p2p:sendto("hohai", peer.ip, peer.port))
		end
	end

	self.clientIP = peer.ip
	self.clientPort = peer.port
	self.enabled = true

	return p2p
end

function Network:Start()
	print("Starting Network")

	self.udp = self:HolePunch()
end

-- Get input from the remote player for the passed in game tick.
function Network:GetRemoteInputState(tick)
	if tick > self.confirmedTick then
		-- Repeat the last confirmed input when we don't have a confirmed tick
		tick = self.confirmedTick
	end
	return self:DecodeInput(self.remoteInputHistory[1+((NET_INPUT_HISTORY_SIZE + tick) % NET_INPUT_HISTORY_SIZE)]) -- First index is 1 not 0.
end

-- Get input state for the local client
function Network:GetLocalInputState(tick)
	return self:DecodeInput(self.inputHistory[1+((NET_INPUT_HISTORY_SIZE + tick) % NET_INPUT_HISTORY_SIZE)]) -- First index is 1 not 0.
end

function Network:GetLocalInputEncoded(tick)
	return self.inputHistory[1+((NET_INPUT_HISTORY_SIZE + tick) % NET_INPUT_HISTORY_SIZE)] -- First index is 1 not 0.
end

-- Get the sync data which is used to check for game state desync between the clients.
function Network:GetSyncDataLocal(tick)
	local index = 1+( (NET_INPUT_HISTORY_SIZE + tick) % NET_INPUT_HISTORY_SIZE)
	return self.syncDataHistoryLocal[index] -- First index is 1 not 0.
end

-- Get sync data from the remote client.
function Network:GetSyncDataRemote(tick)
	local index = 1+( (NET_INPUT_HISTORY_SIZE + tick) % NET_INPUT_HISTORY_SIZE)

	return self.syncDataHistoryRemote[index] -- First index is 1 not 0.
end

-- Set sync data for a game tick
function Network:SetLocalSyncData(tick, syncData)
	if not self.isStateDesynced then
		self.localSyncData = syncData
		self.localSyncDataTick = tick
	end
end

-- Check for a desync.
function Network:DesyncCheck()
	if self.localSyncDataTick < 0 then
		return
	end

	-- When the local sync data does not match the remote data indicate a desync has occurred.
	if self.isStateDesynced or self.localSyncDataTick == self.remoteSyncDataTick then
		-- print("Desync Check at: " .. self.localSyncDataTick)

		if self.localSyncData ~= self.remoteSyncData then
			self.isStateDesynced = true
			return true, self.localSyncDataTick
		end
	end

	return false
end

-- Connects to the other player who is hosting as the server.d
function Network:ConnectToServer()
	-- This most be called to connect with the server.
	self:SendPacket(self:MakeHandshakePacket(), 5)
end

-- Send the inputState for the local player to the remote player for the given game tick.
function Network:SendInputData(tick)

	-- Don't send input data when not connect to another player's game client.
	if not (self.enabled and self.connectedToClient) then
		return
	end

	self:SendPacket(self:MakeInputPacket(tick), 1)
end

function Network:SetLocalInput(inputState, tick)
	local encodedInput = self:EncodeInput(inputState)
	self.inputHistory[1+((NET_INPUT_HISTORY_SIZE + tick) % NET_INPUT_HISTORY_SIZE)] = encodedInput -- 1 base indexing.
end

function Network:SetRemoteEncodedInput(encodedInput, tick)
	self.remoteInputHistory[1+((NET_INPUT_HISTORY_SIZE + tick) % NET_INPUT_HISTORY_SIZE)] = encodedInput -- 1 base indexing.
end

-- Handles sending packets to the other client. Set duplicates to something > 0 to send more than once.
function Network:SendPacket(packet, duplicates)
	if not duplicates then
		duplicates = 1
	end

	for i=1, duplicates do
		if NET_SEND_DELAY_FRAMES > 0 then
			self:SendPacketWithDelay(packet)
		else
			self:SendPacketRaw(packet)
		end
	end
end

-- Queues a packet to be sent later
function Network:SendPacketWithDelay(packet)
	local delayedPacket = {packet=packet, time=love.timer.getTime()}
	table.insert(self.toSendPackets, delayedPacket)
end

-- Send all packets which have been queued and who's delay time as elapsed.
function Network:ProcessDelayedPackets()
	local newPacketList = {}	-- List of packets that haven't been sent yet.
	local timeInterval = (NET_SEND_DELAY_FRAMES/60) -- How much time must pass (converting from frames into seconds)

	for _,data in pairs(self.toSendPackets) do
		if (love.timer.getTime() - data.time) > timeInterval then
			self:SendPacketRaw(data.packet)		-- Send packet when enough time as passed.
		else
			table.insert(newPacketList, data)	-- Keep the packet if the not enough time as passed.
		end
	end
	self.toSendPackets = newPacketList
end

-- Send a packet immediately
function Network:SendPacketRaw(packet)
	self.udp:sendto(packet, self.clientIP, self.clientPort)
end

-- Handles receiving packets from the other client.
function Network:ReceivePacket(packet)
	local data = nil
	local msg = nil
	local ip_or_msg = nil
	local port = nil

	data, ip_or_msg, port = self.udp:receivefrom()

	if not data then
		msg = ip_or_msg
	end

	return data, msg, ip_or_msg, port
end

-- Checks the queue for any incoming packets and process them.
function Network:ReceiveData()
	if not self.enabled then
		return
	end

	-- For now we'll process all packets every frame.
	repeat
		local data,msg,ip,port = self:ReceivePacket()

		if data then
			local code = love.data.unpack("B", data, 1)

			-- Handshake code must be received by both game instances before a match can begin.
			if code == MsgCode.Handshake then
				if not self.connectedToClient then
					self.connectedToClient = true

					print("Received Handshake. Address: " .. self.clientIP .. ".   Port: " .. self.clientPort)
					-- Send handshake to client.
					self:SendPacket(self:MakeHandshakePacket(), 5)
				end

			elseif code == MsgCode.PlayerInput then
				-- Break apart the packet into its parts.
				local results = { love.data.unpack(INPUT_FORMAT_STRING, data, 1) } -- Final parameter is the start position

				local tickDelta = results[2]
				local receivedTick = results[3]

				-- We only care about the latest tick delta, so make sure the confirmed frame is atleast the same or newer.
				-- This would work better if we added a packet count.
				if receivedTick >= self.confirmedTick then
					self.remoteTickDelta = tickDelta
				end

				if receivedTick > self.confirmedTick then
					if receivedTick - self.confirmedTick > NET_INPUT_DELAY then
						NetLog("Received packet with a tick too far ahead. Last: " .. self.confirmedTick .. "     Current: " .. receivedTick )
					end

					self.confirmedTick = receivedTick

					-- PacketLog("Received Input: " .. results[3+NET_SEND_HISTORY_SIZE] .. " @ " ..  receivedTick)

					for offset=0, NET_SEND_HISTORY_SIZE-1 do
						-- Save the input history sent in the packet.
						self:SetRemoteEncodedInput(results[3+NET_SEND_HISTORY_SIZE-offset] , receivedTick-offset)
					end
				end

				-- NetLog("Received Tick: " .. receivedTick .. ",  Input: " .. self.remoteInputHistory[(self.confirmedTick % NET_INPUT_HISTORY_SIZE)+1])
			elseif code == MsgCode.Ping then
				local pingTime = love.data.unpack("n", data, 2)
				self:SendPacket(self:MakePongPacket(pingTime))
			elseif code == MsgCode.Pong then
				local pongTime = love.data.unpack("n", data, 2)
				self.latency = love.timer.getTime() - pongTime
				--print("Got pong message: " .. self.latency)
			elseif code == MsgCode.Sync then
				local _, tick, syncData =  love.data.unpack(SYNC_DATA_FORMAT_STRING, data, 1)
				-- Ignore any tick that isn't more recent than the last sync data
				if not self.isStateDesynced and tick > self.remoteSyncDataTick then
					self.remoteSyncDataTick = tick
					self.remoteSyncData = syncData

					-- Check for a desync
					self:DesyncCheck()
				end

			end
		elseif msg and msg ~= 'timeout' then
			error("Network error: " .. tostring(msg))
		end
	-- When we no longer have data we're done processing packets for this frame.
	until data == nil
end

-- Generate a packet containing information about player input.
function Network:MakeInputPacket(tick)
	local historyIndexStart = tick - NET_SEND_HISTORY_SIZE + 1
	local history = {}
	for i=0, NET_SEND_HISTORY_SIZE-1 do
		history[i+1] = self.inputHistory[((NET_INPUT_HISTORY_SIZE + historyIndexStart + i) % NET_INPUT_HISTORY_SIZE) + 1] -- +1 here because lua indices start at 1 and not 0.
	end

	--NetLog('[Packet] tick: ' .. tick .. '      input: ' .. history[NET_SEND_HISTORY_SIZE])
	local data = love.data.pack("string", INPUT_FORMAT_STRING, MsgCode.PlayerInput, self.localTickDelta, tick, unpack(history))
	return data
end

-- Send a ping message in order to test network latency
function Network:SendPingMessage()
	self:SendPacket(self:MakePingPacket(love.timer.getTime()))
end

-- Make a ping packet
function Network:MakePingPacket(time)
	return love.data.pack("string", "Bn", MsgCode.Ping, time)
end

-- Make pong packet
function Network:MakePongPacket(time)
	return love.data.pack("string", "Bn", MsgCode.Pong, time)
end

-- Sends sync data
function Network:SendSyncData()
	self:SendPacket(self:MakeSyncDataPacket(self.localSyncDataTick, self.localSyncData), 5)
end

-- Make a sync data packet
function Network:MakeSyncDataPacket(tick, syncData)
	return love.data.pack("string", SYNC_DATA_FORMAT_STRING, MsgCode.Sync, tick, syncData)
end

-- Generate handshake packet for connecting with another client.
function Network:MakeHandshakePacket()
	return love.data.pack("string", "B", MsgCode.Handshake)
end

-- Encodes the player input state into a compact form for network transmission.
function Network:EncodeInput(state)
	local data = 0

	if state.up then
		data = bit.bor(data, Btn.Up)
	end

	if state.down then
		data = bit.bor(data, Btn.Down)
	end

	if state.left then
		data = bit.bor(data, Btn.Left)
	end

	if state.right then
		data = bit.bor(data, Btn.Right)
	end

	if state.attack then
		data = bit.bor(data, Btn.Attack)
	end

	if state.jump then
		data = bit.bor(data, Btn.Jump)
	end

	if state.start then
		data = bit.bor(data, Btn.Start)
	end

	return data
end

-- Decodes the input from a packet generated by EncodeInput().
function Network:DecodeInput(data)
	local state = {}

	state.up        = bit.band(data, Btn.Up) > 0
	state.down      = bit.band(data, Btn.Down) > 0
	state.left      = bit.band(data, Btn.Left) > 0
	state.right     = bit.band(data, Btn.Right) > 0
	state.attack    = bit.band(data, Btn.Attack) > 0
	state.jump      = bit.band(data, Btn.Jump) > 0
	state.start     = bit.band(data, Btn.Start) > 0

	return state
end