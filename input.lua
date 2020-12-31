-- The input system is an abstraction layer between system input and commands used to control player objects.
Input = {
	maxFrames = 60,          -- The maximum number of input commands stored in the player controller ring buff.
	localPlayerPort = 1,     -- The player index for the player on the local client.
	remotePlayerPort = 2,    -- The player index for the player on the remote client.
	keyboardState = {},      -- System keyboard state. This is updated in love callbacks love.keypressed and love.keyreleased.
	polledInput = {{}, {}},  -- Latest polled inputs
	buffers = {{}, {}},      -- A ring buffer. Stores the on/off state for each basic input command.
	joysticks = {},          -- Available joysticks
}

function Input:index(offset)
	local tick = Game.tick
	if offset then
		tick = tick + offset
	end

	return 1 + ((Input.maxFrames + tick) % Input.maxFrames)
end

-- Used in the rollback system to make a copy of the input system state
function Input:serialize()
	local state = {}
	state.buffers = table.deep_copy(self.buffers)
	return state
end

-- Used in the rollback system to restore the old state of the input system
function Input:unserialize(state)
	self.buffers = table.deep_copy(state.buffers)
end

-- Get the entire input state for the current from a player's input command buffer.
function Input:state(port, tick)
	-- The 1 appearing here is because lua arrays used 1 based and not 0 based indexes.
	local inputFrame = 1 + ((Input.maxFrames + tick ) % Input.maxFrames)

	local state = self.buffers[port][inputFrame]
	if not state then
		return {}
	end
	return state
end

function Input:getLatest(port)
	return self.polledInput[port]
end

-- Get the current input state for a player
function Input:currentState(port)
	return self:state(port, Game.tick)
end

-- Directly set the input state or the player. This is used for a online match.
function Input:setState(playerIndex, state)
	local stateCopy = table.copy(state)
	self.buffers[playerIndex][self:index()] = stateCopy
end

-- Initialize the player input command ring buffer.
function Input:initializeBuffer(port)
	for i=1, Input.maxFrames do
		self.buffers[port][i] = {
			up = false,
			down = false,
			left = false,
			right = false,
			attack = false,
			jump = false,
			start = false
		}
	end
end

-- Record inputs the player pressed this frame.
function Input:updateInputChanges()
	local inputIndex = self:index()
	local previousindex = self:index(-1)

	for port=1, 2 do
		local state = self.buffers[port][inputIndex]
		local prevState = self.buffers[port][previousindex]

		state.up_pressed = state.up and not prevState.up
		state.down_pressed = state.down and not prevState.down
		state.left_pressed = state.left and not prevState.left
		state.right_pressed = state.right and not prevState.right
		state.attack_pressed = state.attack and not prevState.attack
		state.jump_pressed = state.jump and not prevState.jump
		state.start_pressed = state.start and not prevState.start
	end
end

function Input:poll(updateBuffers)
	-- Input polling from the system can be disabled for setting inputs from a buffer. Used in testing rollbacks.
	-- Update the local player's command buffer for the current frame.
	self.polledInput[self.localPlayerPort] = table.copy(self.keyboardState)

	-- Get buttons from first joysticks
	for port, joystick in pairs(self.joysticks) do
		if self.joysticks[1] and (not Network.enabled or (self.localPlayerPort == port) ) then

			local commandBuffer = self.polledInput[port]
			local axisX = joystick:getAxis(1)
			local axisY = joystick:getAxis(2)

			-- Reset the direction state for this frame.
			commandBuffer.left = false
			commandBuffer.right = false
			commandBuffer.up = false
			commandBuffer.down = false
			commandBuffer.attack = false
			commandBuffer.jump = false
			commandBuffer.start = false

			-- Indicates the neutral zone of the joystick
			local axisGap = 0.5

			if axisX > axisGap then
				commandBuffer.right = true
			elseif axisX < -axisGap then
				commandBuffer.left = true
			end

			if axisY > axisGap then
				commandBuffer.down = true
			elseif axisY < -axisGap then
				commandBuffer.up = true
			end

			if joystick:isDown(1) then
				commandBuffer.attack = true
			end

			if joystick:isDown(2) then
				commandBuffer.jump = true
			end

			if joystick:isDown(3) then
				commandBuffer.start = true
			end
		end
	end

	-- Updated the player input buffers from the polled inputs.  Set to false in network mode.
	if updateBuffers then
		local port = self:index()
		self.buffers[port] = self.polledInput[port]
	end
end

-- The update method syncs the keyboard and joystick input with the internal player input state. It also handles syncing the remote player's inputs.
function Input:update()
	-- Update input changes
	Input:updateInputChanges()
end

-- Set the internal keyboard state input to true on pressed.
function love.keypressed(key, scancode, isrepeat)
	if key == 'up'  then
		Input.keyboardState.up = true
	elseif key == 'down' then
		Input.keyboardState.down = true
	elseif key == 'left'  then
		Input.keyboardState.left = true
	elseif key == 'right' then
		Input.keyboardState.right = true
	elseif key == 'x' then
		Input.keyboardState.attack = true
	elseif key == 'z' then
		Input.keyboardState.jump = true
	elseif key == 'return' then
		Input.keyboardState.start = true
	end

	if key == 'f3' then
		Game.paused = not Game.paused
	elseif key == 'f2' then
		Game.frameStep = true
	elseif key == 'f1' then
		SHOW_DEBUG_INFO = not SHOW_DEBUG_INFO
	elseif key == "space" then
		Game.forcePause = true;
	-- Test controls for storing/restoring state.
	elseif key == 'f7' then
		Game:serialize()
	elseif key == 'f8' then
		Game:unserialize()
	elseif key == 'f9' then
		Network:StartConnection()
		Input.localPlayerPort = 2  -- Right now the client is always player 2.
		Input.remotePlayerPort = 1 -- Right now the server is always players 1.
	elseif key == 'f10' then
		Network:StartServer()
		Input.localPlayerPort = 1  -- Right now the server is always players 1.
		Input.remotePlayerPort = 2 -- Right now the client is always player 2.
	end
end

-- Set the internal keyboard state input to false on release.
function love.keyreleased(key, scancode, isrepeat)
	if key == 'up'  then
		Input.keyboardState.up = false
	elseif key == 'down' then
		Input.keyboardState.down = false
	elseif key == 'left'  then
		Input.keyboardState.left = false
	elseif key == 'right' then
		Input.keyboardState.right = false
	elseif key == 'x' then
		Input.keyboardState.attack = false
	elseif key == 'z' then
		Input.keyboardState.jump = false
	elseif key == "return" then
		Input.keyboardState.start = false;
	elseif key == "space" then
		Game.forcePause = false;
	end
end
