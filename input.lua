-- The input system is an abstraction layer between system input and commands used to control player objects.
Input = {
	MAX_INPUT_FRAMES = 60,			-- The maximum number of input commands stored in the player controller ring buff.
	localPlayerIndex 	= 1,		-- The player index for the player on the local client.
	remotePlayerIndex 	= 2,		-- The player index for the player on the remote client.
	keyboardState = {}, 			-- System keyboard state. This is updated in love callbacks love.keypressed and love.keyreleased.
	remotePlayerState = {},			-- Store the input state for the remote player.
	polledInput = {{}, {}},			-- Latest polled inputs
	playerCommandBuffer = {{}, {}},	-- A ring buffer. Stores the on/off state for each basic input command.
	inputDelay = 0,					-- Specify how many frames the player's inputs will be delayed by. Used in networking. Increase this value to test delay!
	joysticks = {},					-- Available joysticks
}

function Input:InputIndex(offset)
	local tick = self.game.tick
	if offset then
		tick = tick + offset
	end

	return 1 + ((Input.MAX_INPUT_FRAMES + tick) % Input.MAX_INPUT_FRAMES)
end

-- Used in the rollback system to make a copy of the input system state
function Input:serialize()
	local state = {}
	state.playerCommandBuffer = table.deep_copy(self.playerCommandBuffer)
	return state
end

-- Used in the rollback system to restore the old state of the input system
function Input:unserialize(state)
	self.playerCommandBuffer = table.deep_copy(state.playerCommandBuffer)
end

-- Get the entire input state for the current from a player's input command buffer.
function Input:GetInputState(bufferIndex, tick)
	-- The 1 appearing here is because lua arrays used 1 based and not 0 based indexes.
	local inputFrame = 1 + ((Input.MAX_INPUT_FRAMES + tick ) % Input.MAX_INPUT_FRAMES)

	local state = self.playerCommandBuffer[bufferIndex][inputFrame]
	if not state then
		return {}
	end
	return state
end

function Input:GetLatestInput(bufferIndex)
	return self.polledInput[bufferIndex]
end

-- Get the current input state for a player
function Input:CurrentInputState(bufferIndex)
	return self:GetInputState(bufferIndex, self.game.tick)
end

-- Directly set the input state or the player. This is used for a online match.
function Input:SetInputState(playerIndex, state)
	local stateCopy = table.copy(state)
	self.playerCommandBuffer[playerIndex][self:InputIndex()] = stateCopy
end

-- Initialize the player input command ring buffer.
function Input:InitializeBuffer(bufferIndex)
	for i=1,Input.MAX_INPUT_FRAMES do
		self.playerCommandBuffer[bufferIndex][i] = {
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
function Input:UpdateInputChanges()
	local inputIndex = self:InputIndex()
	local previousInputIndex = self:InputIndex(-1)

	for i=1,2 do
		local state = self.playerCommandBuffer[i][inputIndex]
		local previousState = self.playerCommandBuffer[i][previousInputIndex]

		state.up_pressed = state.up and not previousState.up
		state.down_pressed = state.down and not previousState.down
		state.left_pressed = state.left and not previousState.left
		state.right_pressed = state.right and not previousState.right
		state.attack_pressed = state.attack and not previousState.attack
		state.jump_pressed = state.jump and not previousState.jump
		state.start_pressed = state.start and not previousState.start
	end
end

function Input:PollInputs(updateBuffers)
	-- Input polling from the system can be disabled for setting inputs from a buffer. Used in testing rollbacks.
	-- Update the local player's command buffer for the current frame.
	self.polledInput[self.localPlayerIndex] = table.copy(self.keyboardState)

	-- Update the remote player's command buffer.
	--self.playerCommandBuffer[self.remotePlayerIndex][delayedIndex] = table.copy(self.remotePlayerState)

	-- Get buttons from first joysticks
	for index, joystick in pairs(self.joysticks) do
		if self.joysticks[1] and (not self.game.network.enabled or (self.localPlayerIndex == index) ) then

			local commandBuffer = self.polledInput[index]
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
		local bufferIndex = self:InputIndex()
		for i=1,2 do
			self.playerCommandBuffer[bufferIndex] = self.polledInput[bufferIndex]
		end
	end

end

-- The update method syncs the keyboard and joystick input with the internal player input state. It also handles syncing the remote player's inputs.
function Input:Update()
	-- Update input changes
	Input:UpdateInputChanges()
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

	if key == 'f5' then
		Input.game:Reset()
	elseif key == 'f3' then
		Input.game.paused = not Input.game.paused
	elseif key == 'f2' then
		Input.game.frameStep = true
	elseif key == 'f1' then
		SHOW_DEBUG_INFO = not SHOW_DEBUG_INFO
	elseif key == "space" then
		Input.game.forcePause = true;
	-- Test controls for storing/restoring state.
	elseif key == 'f7' then
		Input.game:StoreState()
	elseif key == 'f8' then
		Input.game:RestoreState()
	elseif key == 'f9' then
		Input.game.network:StartConnection()
		Input.localPlayerIndex = 2	-- Right now the client is always player 2.
		Input.remotePlayerIndex = 1 	-- Right now the server is always players 1.
	elseif key == 'f10' then
		Input.game.network:StartServer()
		Input.localPlayerIndex = 1 	-- Right now the server is always players 1.
		Input.remotePlayerIndex = 2	-- Right now the client is always player 2.
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
		Input.game.forcePause = false;
	end
end
