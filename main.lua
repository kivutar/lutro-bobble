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

function love.conf(t)
	t.width  = SCREEN_WIDTH
	t.height = SCREEN_HEIGHT
end

function love.load()
	IMG_ground = love.graphics.newImage("assets/ground.png")
	IMG_ground_top = love.graphics.newImage("assets/ground_top.png")
	IMG_bg = love.graphics.newImage("assets/bg.png")
	BGM_bgm = love.audio.newSource("assets/bgm.wav", "static")
	BGM_bgm:setLooping(true)
	SFX_jump = love.audio.newSource("assets/jump.wav", "static")
	SFX_bubble = love.audio.newSource("assets/bubble.wav", "static")
	SFX_explode = love.audio.newSource("assets/explode.wav", "static")
	SFX_ko = love.audio.newSource("assets/ko.wav", "static")
	SFX_enemy_die = love.audio.newSource("assets/enemy_die.wav", "static")
	SFX_die = love.audio.newSource("assets/die.wav", "static")
	SFX_gem = love.audio.newSource("assets/gem.wav", "static")
	FNT_points = love.graphics.newImageFont("assets/points.png", "0123456789")
	FNT_letters = love.graphics.newImageFont("assets/letters.png", "ABCDEFGHIJKLMNOPQRSTUVWXYZ ")

	MAP = MAP_classic2

	for y = 1, #MAP, 1 do
		for x = 1, #MAP[y] do
			if MAP[y][x] == 1 then
				table.insert(SHADOWS, newShadow({x=(x-1)*16+8,y=(y-1)*16+8}))
				table.insert(SOLIDS, newGround({x=(x-1)*16,y=(y-1)*16}))
			elseif MAP[y][x] == 2 then
				table.insert(ENTITIES, newEye({x=(x-1)*16,y=(y-1)*16}))
			elseif MAP[y][x] == 3 then
				table.insert(ENTITIES, newSpikes({x=(x-1)*16,y=(y-1)*16,direction="up"}))
			elseif MAP[y][x] == 4 then
				table.insert(ENTITIES, newSpikes({x=(x-1)*16,y=(y-1)*16,direction="down"}))
			elseif MAP[y][x] == 5 then
				table.insert(ENTITIES, newSpikes({x=(x-1)*16,y=(y-1)*16,direction="right"}))
			elseif MAP[y][x] == 6 then
				table.insert(ENTITIES, newSpikes({x=(x-1)*16,y=(y-1)*16,direction="left"}))
			elseif MAP[y][x] == 7 then
				table.insert(ENTITIES, newBouncer({x=(x-1)*16,y=(y-1)*16}))
			elseif MAP[y][x] == 8 then
				table.insert(SHADOWS, newShadow({x=(x-1)*16,y=(y-1)*16}))
				table.insert(SOLIDS, newBridge({x=(x-1)*16,y=(y-1)*16}))
			elseif MAP[y][x] == 9 then
				table.insert(ENTITIES, newGem({x=(x-1)*16,y=(y-1)*16}))
			end
		end
	end

	table.insert(ENTITIES, newCharacter({x=1*16,y=13*16,pad=1}))
	table.insert(ENTITIES, newCharacter({x=18*16,y=13*16,pad=2}))
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
