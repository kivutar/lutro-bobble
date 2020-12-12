require "global"

function detect_collisions()
	for i = 1, #entities do
		for j = 1, #entities do
			if j ~= i then
				local e1 = entities[i]
				local e2 = entities[j]

				if e1 and e2
				and	e1.on_collide
				and e1.x < e2.x + e2.width
				and e1.x + e1.width > e2.x
				and e1.y < e2.y + e2.height
				and e1.height + e1.y > e2.y

				then
					local e1cx = e1.x + e1.width / 2.0
					local e2cx = e2.x + e2.width / 2.0
					local dx
					if e1cx < e2cx then
						dx = e2.x - (e1.x + e1.width)
					else
						dx =(e2.x + e2.width) - e1.x
					end

					local e1cy = e1.y + e1.height / 2.0
					local e2cy = e2.y + e2.height / 2.0
					local dy
					if e1cy < e2cy then
						dy = e2.y - (e1.y + e1.height)
					else
						dy = (e2.y + e2.height) - e1.y
					end

					e1:on_collide(e1, e2, dx, dy)
				end
			end
		end
	end
end

function solid_collisions(e1)
	for j = 1, #solids do
		local e2 = solids[j]

		if e1 and e2
		and	e1.on_collide
		and e1.x < e2.x + e2.width
		and e1.x + e1.width > e2.x
		and e1.y < e2.y + e2.height
		and e1.height + e1.y > e2.y

		then
			local e1cx = e1.x + e1.width / 2.0
			local e2cx = e2.x + e2.width / 2.0
			local dx
			if e1cx < e2cx then
				dx = e2.x - (e1.x + e1.width)
			else
				dx =(e2.x + e2.width) - e1.x
			end

			local e1cy = e1.y + e1.height / 2.0
			local e2cy = e2.y + e2.height / 2.0
			local dy
			if e1cy < e2cy then
				dy = e2.y - (e1.y + e1.height)
			else
				dy = (e2.y + e2.height) - e1.y
			end

			e1:on_collide(e1, e2, dx, dy)
		end
	end
end

function solid_at(x, y, exclude)
	for i = 1, #solids do
		local e = solids[i];

		if (e.type == "ground" or e.type == "bridge" or e.type == "fatknight" and e.hp > 0)
		and e ~= exclude
		and x >= e.x and x < e.x + e.width
		and y >= e.y and y < e.y + e.height
		then
			return true;
		end
	end
	return false;
end

function ground_at(x, y, exclude)
	for i = 1, #solids do
		local e = solids[i];

		if (e.type == "ground")
		and e ~= exclude
		and x >= e.x and x < e.x + e.width
		and y >= e.y and y < e.y + e.height
		then
			return true;
		end
	end
	return false;
end

function bridge_at(x, y, exclude)
	for i = 1, #solids do
		local e = solids[i];

		if (e.type == "bridge")
		and e ~= exclude
		and x >= e.x and x < e.x + e.width
		and y >= e.y and y < e.y + e.height
		then
			return true;
		end
	end
	return false;
end

function object_collide(entity, type)
	for i = 1, #entities do
		for j = 1, #entities do
			if j ~= i then
				local e1 = entities[i]
				local e2 = entities[j]

				if e1 == entity
				and e2.type == type
				and e1.x < e2.x + e2.width
				and e1.x + e1.width > e2.x
				and e1.y < e2.y + e2.height
				and e1.height + e1.y > e2.y

				then
					return e2
				end
			end
		end
	end
	return false
end