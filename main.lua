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
require "notif"

function love.conf(t)
	t.width  = SCREEN_WIDTH
	t.height = SCREEN_HEIGHT
end

function love.load()
	IMG_ground = love.graphics.newImage("assets/ground.png")
	IMG_ground_top = love.graphics.newImage("assets/ground_top.png")
	IMG_bg = love.graphics.newImage("assets/bg.png")
	BGM_bgm = love.audio.newSource("assets/bgm.wav", "static")
	SFX_jump = love.audio.newSource("assets/jump.wav", "static")
	SFX_bubble = love.audio.newSource("assets/bubble.wav", "static")
	SFX_explode = love.audio.newSource("assets/explode.wav", "static")
	SFX_ko = love.audio.newSource("assets/ko.wav", "static")
	SFX_enemy_die = love.audio.newSource("assets/enemy_die.wav", "static")
	SFX_die = love.audio.newSource("assets/die.wav", "static")
	SFX_gem = love.audio.newSource("assets/gem.wav", "static")
	FNT_points = love.graphics.newImageFont("assets/points.png", "0123456789")

	local m3p = {
		{1,1,1,1,1,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
		{0,0,6,1,1,1,1,1,1,1,5,0,0,0,0,0,0,0,0,0,},
		{0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,},
		{0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,},
		{0,7,2,0,0,0,1,0,0,0,2,0,0,0,0,0,0,0,0,0,},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,},
		{1,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,},
		{1,0,2,0,0,0,0,0,3,3,3,3,3,1,1,1,1,1,1,1,},
		{1,1,1,1,1,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,},
	}

	local mspikes = {
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,},
		{1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,},
		{1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,},
		{1,0,0,0,0,9,9,9,9,9,9,9,9,9,9,0,0,0,0,1,},
		{0,0,0,0,0,9,9,9,9,9,9,9,9,9,9,0,0,0,0,0,},
		{0,0,0,0,0,9,9,9,9,9,9,9,9,9,9,0,0,0,0,0,},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
		{1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,},
		{1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,},
		{1,1,1,1,3,3,3,3,3,3,3,3,3,3,3,3,1,1,1,1,},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,},
	}

	MAP = mspikes

	for y = 1, #MAP, 1 do
		for x = 1, #MAP[y] do
			if MAP[y][x] == 1 then
				table.insert(SOLIDS, newGround({x=(x-1)*16,y=(y-1)*16}))
			elseif MAP[y][x] == 2 then
				table.insert(ENTITIES, newEye({x=(x-1)*16,y=(y-1)*16}))
			elseif MAP[y][x] == 3 then
				table.insert(ENTITIES, newSpikes({x=(x-1)*16,y=(y-1)*16}))
			elseif MAP[y][x] == 4 then
				table.insert(ENTITIES, newSpikes({x=(x-1)*16,y=(y-1)*16,direction="down"}))
			elseif MAP[y][x] == 5 then
				table.insert(ENTITIES, newSpikes({x=(x-1)*16,y=(y-1)*16,direction="right"}))
			elseif MAP[y][x] == 6 then
				table.insert(ENTITIES, newSpikes({x=(x-1)*16,y=(y-1)*16,direction="left"}))
			elseif MAP[y][x] == 7 then
				table.insert(ENTITIES, newBouncer({x=(x-1)*16,y=(y-1)*16}))
			elseif MAP[y][x] == 9 then
				table.insert(ENTITIES, newGem({x=(x-1)*16,y=(y-1)*16}))
			end
		end
	end

	table.insert(ENTITIES, newCharacter({x=1*16,y=7*16,pad=1}))
	-- table.insert(ENTITIES, newCharacter({x=2*16,y=7*16,pad=2}))
	-- table.insert(ENTITIES, newCharacter({x=3*16,y=7*16,pad=3}))

	love.graphics.setBackgroundColor(0, 0, 0)
	love.graphics.setFont(FNT_points)
	love.audio.play(BGM_bgm)
	math.randomseed(os.time())
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
end

function love.draw()
	love.graphics.draw(IMG_bg, 0, 0)

	for i=1, #SOLIDS do
		if SOLIDS[i].draw then
			SOLIDS[i]:draw()
		end
	end

	for i=1, #EFFECTS do
		if EFFECTS[i].draw then
			EFFECTS[i]:draw()
		end
	end

	for i=1, #ENTITIES do
		if ENTITIES[i].draw then
			ENTITIES[i]:draw()
		end
	end
end
