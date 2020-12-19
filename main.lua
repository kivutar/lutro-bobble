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
	camera_x = 0
	camera_y = 0
	love.graphics.setBackgroundColor(0, 0, 0)
	img_ground = love.graphics.newImage("assets/ground.png")
	img_ground_top = love.graphics.newImage("assets/ground_top.png")
	img_bg = love.graphics.newImage("assets/bg.png")
	bgm_bgm = love.audio.newSource("assets/bgm.wav", "static")
	sfx_jump = love.audio.newSource("assets/jump.wav", "static")
	sfx_bubble = love.audio.newSource("assets/bubble.wav", "static")
	sfx_explode = love.audio.newSource("assets/explode.wav", "static")
	sfx_ko = love.audio.newSource("assets/ko.wav", "static")
	sfx_enemy_die = love.audio.newSource("assets/enemy_die.wav", "static")
	sfx_die = love.audio.newSource("assets/die.wav", "static")
	sfx_gem = love.audio.newSource("assets/gem.wav", "static")

	font = love.graphics.newImageFont("assets/points.png", "0123456789")
	love.graphics.setFont(font)

	math.randomseed(os.time())

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

	map = mspikes

	for y = 1, #map, 1 do
		for x = 1, #map[y] do
			if map[y][x] == 1 then
				table.insert(solids, newGround({x=(x-1)*16,y=(y-1)*16}))
			elseif map[y][x] == 2 then
				table.insert(entities, newEye({x=(x-1)*16,y=(y-1)*16}))
			elseif map[y][x] == 3 then
				table.insert(entities, newSpikes({x=(x-1)*16,y=(y-1)*16}))
			elseif map[y][x] == 4 then
				table.insert(entities, newSpikes({x=(x-1)*16,y=(y-1)*16,direction="down"}))
			elseif map[y][x] == 5 then
				table.insert(entities, newSpikes({x=(x-1)*16,y=(y-1)*16,direction="right"}))
			elseif map[y][x] == 6 then
				table.insert(entities, newSpikes({x=(x-1)*16,y=(y-1)*16,direction="left"}))
			elseif map[y][x] == 7 then
				table.insert(entities, newBouncer({x=(x-1)*16,y=(y-1)*16}))
			elseif map[y][x] == 9 then
				table.insert(entities, newGem({x=(x-1)*16,y=(y-1)*16}))
			end
		end
	end

	table.insert(entities, newCharacter({x=1*16,y=7*16,pad=1}))
	-- table.insert(entities, newCharacter({x=2*16,y=7*16,pad=2}))
	-- table.insert(entities, newCharacter({x=3*16,y=7*16,pad=3}))

	love.audio.play(bgm_bgm)
end

function love.update(dt)
	for i=1, #entities do
		if entities[i] and entities[i].update then
			entities[i]:update(dt)
		end
	end

	for i=1, #effects do
		if effects[i] and effects[i].update then
			effects[i]:update(dt)
		end
	end

	detect_collisions()
end

function love.draw()
	love.graphics.draw(img_bg, 0, 0)

	for i=1, #solids do
		if solids[i].draw then
			solids[i]:draw()
		end
	end

	for i=1, #effects do
		if effects[i].draw then
			effects[i]:draw()
		end
	end

	for i=1, #entities do
		if entities[i].draw then
			entities[i]:draw()
		end
	end
end
