local inter = {}
inter.__index = inter

function newInter(n)
	n.type = ENT_INTER
	n.t = 100
	return setmetatable(n, inter)
end

function inter:update(dt)
	if self.t > 0 then
		self.t = self.t - 1
		if self.t == 1 then
			ENTITIES = {}
			SOLIDS = {}
			EFFECTS = {}
			SHADOWS = {}
			MAP = {}
			LAST_UID = 0
			PHASE = "game"

			load_map(STAGES[STAGE])

			if CHAR1.dead then
				table.insert(ENTITIES, newGhost({uid=newUID(),x=1*16,y=13*16,pad=1,direction=DIR_RIGHT}))
			else
				CHAR1 = newCharacter({uid=newUID(),x=1*16,y=13*16,pad=1,direction=DIR_RIGHT})
				table.insert(ENTITIES, CHAR1)
			end
			if CHAR2.dead then
				table.insert(ENTITIES, newGhost({uid=newUID(),x=18*16,y=13*16,pad=2,direction=DIR_LEFT}))
			else
				CHAR2 = newCharacter({uid=newUID(),x=18*16,y=13*16,pad=2,direction=DIR_LEFT})
				table.insert(ENTITIES, CHAR2)
			end
			-- table.insert(ENTITIES, newCharacter({x=3*16,y=7*16,pad=3}))

			love.audio.play(BGM)
		end
	end
end

function inter:draw()
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
	love.graphics.setFont(FNT_letters)
	local w = FNT_letters:getWidth("STAGE "..STAGE.."! READY ?")
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print("STAGE "..STAGE.."! READY?", SCREEN_WIDTH/2 - w/2, SCREEN_HEIGHT/2 - 16/2)
end

function inter:serialize()
	return {
		uid = self.uid,
		type = self.type,
		t = self.t,
	}
end

function inter:unserialize(n)
	self.uid = n.uid
	self.type = n.type
	self.t = n.t
end
