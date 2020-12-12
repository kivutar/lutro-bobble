require "global"
require "anim"
require "collisions"
require "character"
require "ground"
require "bubble"
require "bubbleexp"

function love.conf(t)
	t.width  = SCREEN_WIDTH
	t.height = SCREEN_HEIGHT
end

function love.load()
	camera_x = 0
	camera_y = 0
	love.graphics.setBackgroundColor(0, 10, 10)
	img_ground = love.graphics.newImage("assets/ground.png")
	img_ground_top = love.graphics.newImage("assets/ground_top.png")
	img_bg = love.graphics.newImage("assets/bg.png")
	sfx_jump = love.audio.newSource("assets/jump.wav", "static")
	sfx_bubble = love.audio.newSource("assets/bubble.wav", "static")
	sfx_explode = love.audio.newSource("assets/explode.wav", "static")

	math.randomseed(os.time())

	map = {
		{1,1,1,1,1,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
		{0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,},
		{0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,},
		{0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,},
		{0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,},
		{1,1,1,1,1,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,},
	}

	for y = 1, #map, 1 do
		for x = 1, #map[y] do
			if map[y][x] == 1 then
				table.insert(solids, newGround({x=(x-1)*16,y=(y-1)*16}))
			end
		end
	end

	table.insert(entities, newCharacter({x=32,y=32,pad=1}))
	table.insert(entities, newCharacter({x=64,y=32,pad=2}))
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
