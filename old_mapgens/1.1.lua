-- Mapgen 1.1
-- Sunday March 8, 2015

vmg.noises = {

-- Noise 1 : Base Ground Height						2D
{offset = -10, scale = 50, seed = 5202, spread = {x = 1024, y = 1024, z = 1024}, octaves = 6, persist = 0.4},

-- Noise 2 : Valleys (River where around zero)				2D
{offset = 0, scale = 1, seed = -6050, spread = {x = 256, y = 256, z = 256}, octaves = 5, persist = 0.6},

-- Noise 3 : Valleys Depth						2D
{offset = 5, scale = 4, seed = -1914, spread = {x = 512, y = 512, z = 512}, octaves = 1, persist = 1},

-- Noise 4 : Valleys Profile (Higher values = Larger valleys)		2D
{offset = 0.5, scale = 0.5, seed = 777, spread = {x = 512, y = 512, z = 512}, octaves = 1, persist = 1},

-- Noise 5 : Inter-valleys slopes					2D
{offset = 0.5, scale = 0.5, seed = 746, spread = {x = 128, y = 128, z = 128}, octaves = 1, persist = 1},

-- Noise 6 : Inter-valleys filling					3D
{offset = 0, scale = 1, seed = 1993, spread = {x = 256, y = 512, z = 256}, octaves = 6, persist = 0.8},

-- Noise 7 : Dirt thickness						2D
{offset = 3, scale = 2, seed = 1605, spread = {x = 256, y = 256, z = 256}, octaves = 3, persist = 0.5},

-- Noise 8 : Caves I
{offset = 0, scale = 1, seed = -4640, spread = {x = 32, y = 32, z = 32}, octaves = 4, persist = 0.5},

-- Noise 9 : Caves II
{offset = 0, scale = 1, seed = 8804, spread = {x = 32, y = 32, z = 32}, octaves = 4, persist = 0.5},

-- Noise 10 : Caves III
{offset = 0, scale = 1, seed = -4780, spread = {x = 32, y = 32, z = 32}, octaves = 4, persist = 0.5},

-- Noise 11 : Caves IV
{offset = 0, scale = 1, seed = -9969, spread = {x = 32, y = 32, z = 32}, octaves = 4, persist = 0.5},

}

function vmg.generate(minp, maxp, seed)
	if vmg.registered_on_first_mapgen then -- Run callbacks
		for _, f in ipairs(vmg.registered_on_first_mapgen) do
			f()
		end
		vmg.registered_on_first_mapgen = nil
		vmg.register_on_first_mapgen = nil
	end

	local minps, maxps = minetest.pos_to_string(minp), minetest.pos_to_string(maxp)
	if vmg.loglevel >= 2 then
		print("[Valleys Mapgen] Preparing to generate map from " .. minps .. " to " .. maxps .. " ...")
	elseif vmg.loglevel == 1 then
		print("[Valleys Mapgen] Generating map from " .. minps .. " to " .. maxps .. " ...")
	end
	local t0 = os.clock()

	local c_dirt = minetest.get_content_id("default:dirt")
	local c_stone = minetest.get_content_id("default:stone")
	local c_lawn = minetest.get_content_id("default:dirt_with_grass")
	local c_water = minetest.get_content_id("default:water_source")
	local c_air = minetest.get_content_id("air")

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local data = vm:get_data()
	local a = VoxelArea:new({MinEdge = emin, MaxEdge = emax})

	local chulens = vector.add(vector.subtract(maxp, minp), 1)
	local chulens_sup = {x = chulens.x, y = chulens.y + 6, z = chulens.z}
	local minp2d = pos2d(minp)

	local t1 = os.clock()
	if vmg.loglevel >= 2 then
		print("[Valleys Mapgen] Mapgen preparation finished in " .. displaytime(t1-t0))
		print("[Valleys Mapgen] Calculating noises ...")
	end

	local n1 = minetest.get_perlin_map(vmg.noises[1], chulens):get2dMap_flat(minp2d)
	local n2 = minetest.get_perlin_map(vmg.noises[2], chulens):get2dMap_flat(minp2d)
	local n3 = minetest.get_perlin_map(vmg.noises[3], chulens):get2dMap_flat(minp2d)
	local n4 = minetest.get_perlin_map(vmg.noises[4], chulens):get2dMap_flat(minp2d)
	local n5 = minetest.get_perlin_map(vmg.noises[5], chulens):get2dMap_flat(minp2d)
	local n6 = minetest.get_perlin_map(vmg.noises[6], chulens_sup):get3dMap_flat(minp)
	local n7 = minetest.get_perlin_map(vmg.noises[7], chulens):get2dMap_flat(minp2d)
	local n8 = minetest.get_perlin_map(vmg.noises[8], chulens):get3dMap_flat(minp)
	local n9 = minetest.get_perlin_map(vmg.noises[9], chulens):get3dMap_flat(minp)
	local n10 = minetest.get_perlin_map(vmg.noises[10], chulens):get3dMap_flat(minp)
	local n11 = minetest.get_perlin_map(vmg.noises[11], chulens):get3dMap_flat(minp)

	local t2 = os.clock()
	if vmg.loglevel >= 2 then
		print("[Valleys Mapgen] Noises calculation finished in " .. displaytime(t2-t1))
		print("[Valleys Mapgen] Collecting data ...")
	end

	local i2d = 1 -- index for 2D noises
	local i3d_a = 1 -- index for noise 6 which has a special size
	local i3d_b = 1 -- index for 3D noises
	for x = minp.x, maxp.x do -- for each east-west and bottom-top plane
		for z = minp.z, maxp.z do -- for each vertical row in this plane
			local v1, v2, v3, v4, v5, v7 = n1[i2d], n2[i2d], n3[i2d], n4[i2d], n5[i2d], n7[i2d] -- n for noise, v for value
			v3 = v3 ^ 2 -- v3 must be > 0 and by the square there are high mountains but the median valleys depth is small.
			local base_ground = v1 + v3 -- v3 is here because terrain is generally higher when valleys are deep (mountains)
			local river = math.abs(v2) < 0.05
			local valleys = v3 * (1 - math.exp(- (v2 / v4) ^ 2)) -- use the curve of the function 1−exp(−(x/a)²) to modelise valleys. Making "a" varying 0 < a ≤ 1 will change the shape of the valleys. v2 = x and v4 = a.
			local mountain_ground = base_ground + valleys
			local slopes = v5 * valleys
			if river then
				mountain_ground = math.min(math.max(base_ground - 3, -5), mountain_ground)
				slopes = 0
			end
			for y = minp.y, maxp.y do -- for each node in vertical row
				local ivm = a:index(x, y, z)
				local v6, v8, v9, v10, v11 = n6[i3d_a], n8[i3d_b], n9[i3d_b], n10[i3d_b], n11[i3d_b]
				local is_cave = v8 ^ 2 + v9 ^ 2 + v10 ^ 2 + v11 ^ 2 < 0.07
				if v6 * slopes > y - mountain_ground then -- if pos is in the ground
					if not is_cave then
						local above = math.ceil(v7 + math.random() - math.sqrt(math.abs(y)) / 3.5)
						if above <= 0 then
							data[ivm] = c_stone
						elseif y > 0 and n6[i3d_a+80] * slopes <= y + 1 - mountain_ground and not river then
							data[ivm] = c_lawn -- if node above is not in the ground, place lawn
						elseif n6[i3d_a+above*80] * slopes <= y + above - mountain_ground then
							data[ivm] = c_dirt
						else
							data[ivm] = c_stone
						end
					end
				elseif y <= 1 or river and y - 2 <= mountain_ground then
					data[ivm] = c_water
				end
				
				i3d_a = i3d_a + 80 -- increase i3d_a by one row
				i3d_b = i3d_b + 80 -- increase i3d_b by one row
			end
			i2d = i2d + 80 -- increase i2d by one row
			i3d_a = i3d_a + 480 -- avoid the 6 supplemental lines
		end
		i2d = i2d - 6399 -- i2d = 6401 after the first execution of this loop, it must be 2 before the second.
		i3d_a = i3d_a - 550399 -- i3d_a = 550401 after the first execution of this loop, it must be 2 before the second.
		i3d_b = i3d_b - 511999 -- i3d_b = 512001 after the first execution of this loop, it must be 2 before the second.
	end

	local t3 = os.clock()
	if vmg.loglevel >= 2 then
		print("[Valleys Mapgen] Data collecting finished in " .. displaytime(t3-t2))
		print("[Valleys Mapgen] Writing data ...")
	end

	-- execute voxelmanip boring stuff to write to the map
	vm:set_data(data)
	vm:set_lighting({day = 0, night = 0})
	vm:calc_lighting()
	vm:update_liquids()
	vm:write_to_map()

	vm = minetest.get_voxel_manip()
	vm:read_from_map(minp, maxp)
	minetest.generate_ores(vm) -- Thank you kwolekr ! I can generate the ores in 1 line ! And so it's compatible with moreores and other mods which add ores.
	vm:write_to_map()

	local t4 = os.clock()
	if vmg.loglevel >= 2 then
		print("[Valleys Mapgen] Data writing finished in " .. displaytime(t4-t3))
	end
	if vmg.loglevel >= 1 then
		print("[Valleys Mapgen] Mapgen finished in " .. displaytime(t4-t0)) 
	end
end

vmg.noises_obj = {}

for i, n in ipairs(vmg.noises) do
	vmg.noises_obj[i] = minetest.get_perlin(n.seed, n.octaves, n.persist, 1)
end

function vmg.get_noise(pos, i)
	local n = vmg.noises[i]
	local noise = minetest.get_perlin(n.seed, n.octaves, n.persist, 1)
	if not pos.z then
		return noise:get2d({x = pos.x / n.spread.x, y = pos.y / n.spread.y}) * n.scale + n.offset
	else
		return noise:get3d({x = pos.x / n.spread.x, y = pos.y / n.spread.y, z = pos.z / n.spread.z}) * n.scale + n.offset
	end
end

local function round(n)
	return math.floor(n + 0.5)
end

function vmg.get_elevation(pos)
	local v1 = vmg.get_noise(pos, 1)
	local v2 = vmg.get_noise(pos, 2)
	local v3 = vmg.get_noise(pos, 3) ^ 2
	local v4 = vmg.get_noise(pos, 4)
	local v5 = vmg.get_noise(pos, 5)
	local base_ground = v1 + v3
	local valleys = v3 * (1 - math.exp(- (v2 / v4) ^ 2))
	local mountain_ground = base_ground + valleys
	local pos = pos3d(pos, round(mountain_ground))
	local slopes = v5 * valleys
	if vmg.get_noise(pos, 6) * slopes > pos.y - mountain_ground then
		pos.y = pos.y + 1
		while vmg.get_noise(pos, 6) * slopes > pos.y - mountain_ground do
			pos.y = pos.y + 1
		end
		return pos.y
	else
		pos.y = pos.y - 1
		while vmg.get_noise(pos, 6) * slopes <= pos.y - mountain_ground do
			pos.y = pos.y - 1
		end
		return pos.y
	end
end

function vmg.spawnplayer(player)
	local pos = {x = 0, y = 0}
	local angle = math.random() * math.pi * 2
	local p_angle = {x = math.cos(angle), y = math.sin(angle)}
	local elevation = vmg.get_elevation(pos)
	while elevation < 2 do
		pos.x = pos.x + p_angle.x
		pos.y = pos.y + p_angle.y
		elevation = vmg.get_elevation({x = round(pos.x), y = round(pos.y)})
	end
	pos = {x = round(pos.x), y = round(elevation + 1), z = round(pos.y)}
	player:setpos(pos)
	return true
end
