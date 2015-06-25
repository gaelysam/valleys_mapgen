-- Mapgen 2.0
-- Sunday May 31, 2015

vmg.noises = {

-- Noise 1 : Base Ground Height						2D
{offset = -10, scale = 50, seed = 5202, spread = {x = 1024, y = 1024, z = 1024}, octaves = 6, persist = 0.4, lacunarity = 2},

-- Noise 2 : Valleys (River where around zero)				2D
{offset = 0, scale = 1, seed = -6050, spread = {x = 256, y = 256, z = 256}, octaves = 5, persist = 0.6, lacunarity = 2},

-- Noise 3 : Valleys Depth						2D
{offset = 5, scale = 4, seed = -1914, spread = {x = 512, y = 512, z = 512}, octaves = 1, persist = 1, lacunarity = 2},

-- Noise 4 : Valleys Profile (Higher values = Larger valleys)		2D
{offset = 0.6, scale = 0.5, seed = 777, spread = {x = 512, y = 512, z = 512}, octaves = 1, persist = 1, lacunarity = 2},

-- Noise 5 : Inter-valleys slopes					2D
{offset = 0.5, scale = 0.5, seed = 746, spread = {x = 128, y = 128, z = 128}, octaves = 1, persist = 1, lacunarity = 2},

-- Noise 6 : Inter-valleys filling					3D
{offset = 0, scale = 1, seed = 1993, spread = {x = 256, y = 512, z = 256}, octaves = 6, persist = 0.8, lacunarity = 2},

-- Noise 7 : Dirt thickness						2D
{offset = 3, scale = 1.75, seed = 1605, spread = {x = 256, y = 256, z = 256}, octaves = 3, persist = 0.5, lacunarity = 2},

-- Noise 8 : Caves I							3D
{offset = 0, scale = 1, seed = -4640, spread = {x = 32, y = 32, z = 32}, octaves = 4, persist = 0.5, lacunarity = 2},

-- Noise 9 : Caves II							3D
{offset = 0, scale = 1, seed = 8804, spread = {x = 32, y = 32, z = 32}, octaves = 4, persist = 0.5, lacunarity = 2},

-- Noise 10 : Caves III							3D
{offset = 0, scale = 1, seed = -4780, spread = {x = 32, y = 32, z = 32}, octaves = 4, persist = 0.5, lacunarity = 2},

-- Noise 11 : Caves IV and Lava I					3D
{offset = 0, scale = 1, seed = -9969, spread = {x = 32, y = 32, z = 32}, octaves = 4, persist = 0.5, lacunarity = 2},

-- Noise 12 : Lava II (Geologic heat)					3D
{offset = 0, scale = 1, seed = 3314, spread = {x = 64, y = 64, z = 64}, octaves = 4, persist = 0.5, lacunarity = 2},

-- Noise 13 : Clayey dirt noise						2D
{offset = 0, scale = 1, seed = 2835, spread = {x = 256, y = 256, z = 256}, octaves = 5, persist = 0.5, lacunarity = 4},

-- Noise 14 : Silty dirt noise						2D
{offset = 0, scale = 1, seed = 6674, spread = {x = 256, y = 256, z = 256}, octaves = 5, persist = 0.5, lacunarity = 4},

-- Noise 15 : Sandy dirt noise						2D
{offset = 0, scale = 1, seed = 6940, spread = {x = 256, y = 256, z = 256}, octaves = 5, persist = 0.5, lacunarity = 4},

-- Noise 16 : Beaches							2D
{offset = 2, scale = 8, seed = 2349, spread = {x = 256, y = 256, z = 256}, octaves = 3, persist = 0.5, lacunarity = 2},

-- Noise 17 : Temperature (not in maps)					3D
{offset = 2, scale = 1, seed = -1805, spread = {x = 768, y = 256, z = 768}, octaves = 4, persist = 0.5, lacunarity = 4},

-- Noise 18 : Humidity							2D
{offset = 0, scale = 1, seed = -5787, spread = {x = 243, y = 243, z = 243}, octaves = 4, persist = 0.5, lacunarity = 3},

}

function vmg.noisemap(i, minp, chulens)
	local obj = minetest.get_perlin_map(vmg.noises[i], chulens)
	if minp.z then
		return obj:get3dMap_flat(minp)
	else
		return obj:get2dMap_flat(minp)
	end
end

for i, n in ipairs(vmg.noises) do
	vmg.noises[i] = vmg.define("noise_" .. i, n)
end

vmg.after_mapgen = {}

function vmg.register_after_mapgen(f, ...)
	table.insert(vmg.after_mapgen, {f = f, ...})
end

function vmg.execute_after_mapgen()
	for i, params in ipairs(vmg.after_mapgen) do
		params.f(unpack(params))
	end
	vmg.after_mapgen = {}
end	

local river_size = vmg.define("river_size", 5) / 100
local caves_size = vmg.define("caves_size", 7) / 100
local lava_depth = vmg.define("lava_depth", 2000)
local lava_max_height = vmg.define("lava_max_height", -1)
local altitude_chill = vmg.define("altitude_chill", 90)

local average_stone_level = vmg.define("average_stone_level", 180)
local dirt_thickness = math.sqrt(average_stone_level) / (vmg.noises[7].offset + 0.5)
local average_snow_level = vmg.define("average_snow_level", 100)
local snow_threshold = vmg.noises[17].offset * 0.5 ^ (average_snow_level / altitude_chill)

local player_max_distance = vmg.define("player_max_distance", 450)

local clay_threshold = vmg.define("clay_threshold", 1)
local silt_threshold = vmg.define("silt_threshold", 1)
local sand_threshold = vmg.define("sand_threshold", 0.75)
local dirt_threshold = vmg.define("dirt_threshold", 0.5)

local tree_density = vmg.define("tree_density", 5) / 100
local trees = vmg.define("trees", true)
local plant_density = vmg.define("plant_density", 32) / 100
local plants = vmg.define("plants", true)

local water_level = vmg.define("water_level", 1)

function vmg.generate(minp, maxp, seed)
	local minps, maxps = minetest.pos_to_string(minp), minetest.pos_to_string(maxp)
	if vmg.loglevel >= 2 then
		print("[Valleys Mapgen] Preparing to generate map from " .. minps .. " to " .. maxps .. " ...")
	elseif vmg.loglevel == 1 then
		print("[Valleys Mapgen] Generating map from " .. minps .. " to " .. maxps .. " ...")
	end
	local t0 = os.clock()

	local c_stone = minetest.get_content_id("default:stone")
	local c_dirt = minetest.get_content_id("default:dirt")
	local c_lawn = minetest.get_content_id("default:dirt_with_grass")
	local c_snow = minetest.get_content_id("default:dirt_with_snow")
	local c_dirt_clay = minetest.get_content_id("valleys_mapgen:dirt_clayey")
	local c_lawn_clay = minetest.get_content_id("valleys_mapgen:dirt_clayey_with_grass")
	local c_snow_clay = minetest.get_content_id("valleys_mapgen:dirt_clayey_with_snow")
	local c_dirt_silt = minetest.get_content_id("valleys_mapgen:dirt_silty")
	local c_lawn_silt = minetest.get_content_id("valleys_mapgen:dirt_silty_with_grass")
	local c_snow_silt = minetest.get_content_id("valleys_mapgen:dirt_silty_with_snow")
	local c_dirt_sand = minetest.get_content_id("valleys_mapgen:dirt_sandy")
	local c_lawn_sand = minetest.get_content_id("valleys_mapgen:dirt_sandy_with_grass")
	local c_snow_sand = minetest.get_content_id("valleys_mapgen:dirt_sandy_with_snow")
	local c_desert_sand = minetest.get_content_id("default:desert_sand")
	local c_sand = minetest.get_content_id("default:sand")
	local c_gravel = minetest.get_content_id("default:gravel")
	local c_silt = minetest.get_content_id("valleys_mapgen:silt")
	local c_clay = minetest.get_content_id("valleys_mapgen:red_clay")
	local c_water = minetest.get_content_id("default:water_source")
	local c_lava = minetest.get_content_id("default:lava_source")
	local c_snow_layer = minetest.get_content_id("default:snow")

	local c_tree = minetest.get_content_id("default:tree")
	local c_leaves = minetest.get_content_id("default:leaves")
	local c_apple = minetest.get_content_id("default:apple")
	local c_jungletree = minetest.get_content_id("default:jungletree")
	local c_jungleleaves = minetest.get_content_id("default:jungleleaves")
	local c_pinetree = minetest.get_content_id("default:pinetree")
	local c_pineleaves = minetest.get_content_id("default:pine_needles")

	local c_grass = {
		minetest.get_content_id("default:grass_1"),
		minetest.get_content_id("default:grass_2"),
		minetest.get_content_id("default:grass_3"),
		minetest.get_content_id("default:grass_4"),
		minetest.get_content_id("default:grass_5"),
	}
	local c_junglegrass = minetest.get_content_id("default:junglegrass")
	local c_dryshrub = minetest.get_content_id("default:dry_shrub")
	local c_cactus = minetest.get_content_id("default:cactus")
	local c_papyrus = minetest.get_content_id("default:papyrus")

	local c_air = minetest.get_content_id("air")
	local c_ignore = minetest.get_content_id("ignore")

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local data = vm:get_data()
	local a = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local ystride = a.ystride

	local chulens = vector.add(vector.subtract(maxp, minp), 1)
	local chulens_sup = {x = chulens.x, y = chulens.y + 6, z = chulens.z}
	local minp2d = pos2d(minp)

	local t1 = os.clock()
	if vmg.loglevel >= 2 then
		print("[Valleys Mapgen] Mapgen preparation finished in " .. displaytime(t1-t0))
		print("[Valleys Mapgen] Calculating noises ...")
	end

	local n1 = vmg.noisemap(1, minp2d, chulens)
	local n2 = vmg.noisemap(2, minp2d, chulens)
	local n3 = vmg.noisemap(3, minp2d, chulens)
	local n4 = vmg.noisemap(4, minp2d, chulens)
	local n5 = vmg.noisemap(5, minp2d, chulens)
	local n6 = vmg.noisemap(6, minp, chulens_sup)
	local n7 = vmg.noisemap(7, minp2d, chulens)
	local n8 = vmg.noisemap(8, minp, chulens)
	local n9 = vmg.noisemap(9, minp, chulens)
	local n10 = vmg.noisemap(10, minp, chulens)
	local n11 = vmg.noisemap(11, minp, chulens)
	local n12 = vmg.noisemap(12, minp, chulens)
	local n13 = vmg.noisemap(13, minp2d, chulens)
	local n14 = vmg.noisemap(14, minp2d, chulens)
	local n15 = vmg.noisemap(15, minp2d, chulens)
	local n16 = vmg.noisemap(16, minp2d, chulens)
	local n18 = vmg.noisemap(18, minp2d, chulens)

	local t2 = os.clock()
	if vmg.loglevel >= 2 then
		print("[Valleys Mapgen] Noises calculation finished in " .. displaytime(t2-t1))
		print("[Valleys Mapgen] Collecting data ...")
	end

	local i2d = 1 -- index for 2D noises
	local i3d_sup = 1 -- index for noise 6 which has a special size
	local i3d = 1 -- index for 3D noises

	-- Calculate increments
	local i2d_incrZ = chulens.z
	local i2d_decrX = chulens.x * chulens.z - 1
	local i3d_incrY = chulens.y
	local i3d_sup_incrZ = 6 * chulens.y
	local i3d_decrX = chulens.x * chulens.y * chulens.z - 1
	local i3d_sup_decrX = chulens.x * (chulens.y + 6) * chulens.z - 1

	for x = minp.x, maxp.x do -- for each YZ plane
		for z = minp.z, maxp.z do -- for each vertical line in this plane
			local v1, v2, v3, v4, v5, v7, v13, v14, v15, v16, v18 = n1[i2d], n2[i2d], n3[i2d], n4[i2d], n5[i2d], n7[i2d], n13[i2d], n14[i2d], n15[i2d], n16[i2d], n18[i2d] -- n for noise, v for value
			v3 = v3 ^ 2 -- v3 must be > 0 and by the square there are high mountains but the median valleys depth is small.
			local base_ground = v1 + v3 -- v3 is here because terrain is generally higher when valleys are deep (mountains)
			local river = math.abs(v2) < river_size
			local valleys = v3 * (1 - math.exp(- (v2 / v4) ^ 2)) -- use the curve of the function 1−exp(−(x/a)²) to modelise valleys. Making "a" varying 0 < a ≤ 1 will change the shape of the valleys. Try it with a geometry software ! (here x = v2 and a = v4)
			local mountain_ground = base_ground + valleys
			local slopes = v5 * valleys

			if river then
				mountain_ground = math.min(math.max(base_ground - 3, water_level - 6), mountain_ground)
				slopes = 0
			end

			-- Choose biome
			local dirt = c_dirt
			local lawn = c_lawn
			local snow = c_snow
			local max = math.max(v13, v14, v15) -- the biome is the maximal of these 3 values, if bigger than 0.5. Else, make normal dirt.
			if max > dirt_threshold then
				if v13 == max then
					if v13 > clay_threshold then
						dirt = c_clay
						lawn = c_clay
						snow = c_clay
					else
						dirt = c_dirt_clay
						lawn = c_lawn_clay
						snow = c_snow_clay
					end
				elseif v14 == max then
					if v14 > silt_threshold then
						dirt = c_silt
						lawn = c_silt
						snow = c_silt
					else
						dirt = c_dirt_silt
						lawn = c_lawn_silt
						snow = c_snow_silt
					end
				else
					if v15 > sand_threshold then
						dirt = c_desert_sand
						lawn = c_desert_sand
						snow = c_desert_sand
					else
						dirt = c_dirt_sand
						lawn = c_lawn_sand
						snow = c_snow_sand
					end
				end
			end
			local is_beach = v15 > 0 and v16 > 0
			local beach = v15 * v16 + water_level -- the y coordinate below which dirt is replaced by beach sand

			-- raw humidity
			local hraw = 2 ^ (v13 - v15 + v18 * 2)

			for y = minp.y, maxp.y do -- for each node in vertical line
				local ivm = a:index(x, y, z)
				local v6, v8, v9, v10, v11, v12 = n6[i3d_sup], n8[i3d], n9[i3d], n10[i3d], n11[i3d], n12[i3d]
				local is_cave = v8 ^ 2 + v9 ^ 2 + v10 ^ 2 + v11 ^ 2 < caves_size
				if v6 * slopes > y - mountain_ground then -- if pos is in the ground
					if not is_cave then
						local above = math.ceil(
							v7 + math.random() - math.sqrt(math.abs(y)) / dirt_thickness -- The following code will look for air at this many nodes up. If any, make dirt, else, make stone. So, it's the dirt layer thickness.
						)
						if y >= water_level and n6[i3d_sup+i3d_incrY] * slopes <= y + 1 - mountain_ground and not river then
							if is_beach and y < beach then
								data[ivm] = c_sand
							else -- if node above is not in the ground, place lawn

								-- calculate humidity
								local sea_water = 0.5 ^ math.max((y - water_level) / 6, 0)
								local river_water = 0.5 ^ math.max((y - base_ground) / 3, 0)
								local water = sea_water + (1 - sea_water) * river_water
								local humidity = hraw + water

								local ivm2 = ivm + ystride
								y = y + 1
								local pos = {x = x, y = y, z = z}

								local v17 = vmg.get_noise(pos, 17)
								local temp -- calculate_temperature for node above
								if y > 0 then
									temp = v17 * 0.5 ^ (y / altitude_chill)
								else
									temp = v17 * 0.5 ^ (-y / altitude_chill) + 20 * (v12 + 1) * (1 - 2 ^ (y / lava_depth))
								end

								if temp > snow_threshold then
									if above > 0 then
										data[ivm] = lawn
									else
										data[ivm] = c_stone
									end
								else
									if above > 0 then
										data[ivm] = snow
									else
										data[ivm] = c_stone
									end
									data[ivm2] = c_snow_layer -- set node above to snow
								end

								if trees and math.random() < tree_density and above > 0 then -- make a tree

									-- choose a tree from climatic and geological conditions
									if v15 < 0.6 and temp >= 0.85 and temp < 2.3 and humidity < 3 and v16 < 2 and v14 > -0.5 and v13 < 0.8 then -- Apple Tree
										local rand = math.random()
										local height = math.floor(4 + 2.5 * rand)
										local radius = 3 + rand
										if math.random(1, 4) == 1 then
											vmg.grow_apple_tree(pos, data, a, height, radius, c_tree, c_leaves, c_apple, c_air, c_ignore)
										else
											vmg.grow_tree(pos, data, a, height, radius, c_tree, c_leaves, c_air, c_ignore)
										end
									elseif v15 < 0.7 and temp >= 1.9 and humidity > 2 and v16 > 2 then -- Jungle Tree
										local rand = math.random()
										local height = math.floor(8 + 4 * rand)
										local radius = 5 + 3 * rand
										vmg.grow_jungle_tree(pos, data, a, height, radius, c_jungletree, c_jungleleaves, c_air, c_ignore)
									elseif temp > 0.38 and temp < 1 and humidity > 0.9 and v15 > 0 and v15 < 0.55 then -- Pine Tree (or Fir Tree)
										local rand = math.random()
										local height = math.floor(9 + 6 * rand)
										local radius = 4 + 2 * rand
										vmg.grow_pine_tree(pos, data, a, height, radius, c_pinetree, c_pineleaves, c_air, c_ignore)
									end
								elseif plants and math.random() < plant_density and above > 0 then -- make a plant
									if temp > 1 and temp < 1.8 and water > 0.7 and humidity > 3 and v13 > -0.4 and math.random() < 0.04 then -- Papyrus
										for i = 1, 4 do
											data[ivm+i*ystride] = c_papyrus
										end
									elseif v15 < 0.65 and temp >= 0.65 and temp < 1.5 and humidity < 2.6 and v16 < 1.5 and v13 < 0.8 and math.random() < 0.7 then -- Grass
										data[ivm2] = c_grass[math.random(1, 5)]
									elseif v15 > -0.6 and temp >= 1.8 and humidity > 2.2 and v16 > 1.8 then -- Jungle Grass
										data[ivm2] = c_junglegrass
									elseif v15 > 0.6 and v15 < 0.9 and humidity < 0.5 and temp > 1.8 and math.random() < 0.2 then
										if v16 < 0 and math.random() < 0.12 then -- Cactus
											for i = 1, 4 do
												data[ivm+i*ystride] = c_cactus
											end
										else -- Dry Shrub
											data[ivm2] = c_dryshrub
										end
									end
								end
								y = y - 1
							end
						elseif above <= 0 then
							data[ivm] = c_stone
						elseif n6[i3d_sup+above*i3d_incrY] * slopes <= y + above - mountain_ground then -- if node at "above" nodes up is not in the ground, make dirt
							if is_beach and y < beach then
								data[ivm] = c_sand
							else
								data[ivm] = dirt
							end
						else
							data[ivm] = c_stone
						end
					elseif v11 + v12 > 2 ^ (y / lava_depth) and y <= lava_max_height then
						data[ivm] = c_lava
					end
				elseif y <= water_level or river and y - 2 <= mountain_ground then -- if pos is not in the ground, and below water_level, it's an ocean
					data[ivm] = c_water
				end
				
				i3d = i3d + i3d_incrY -- increment i3d by one line
				i3d_sup = i3d_sup + i3d_incrY -- idem
			end
			i2d = i2d + i2d_incrZ -- increment i2d by one Z
			-- useless to increment i3d, because increment would be 0 !
			i3d_sup = i3d_sup + i3d_sup_incrZ -- for i3d_sup, just avoid the 6 supplemental lines
		end
		i2d = i2d - i2d_decrX -- decrement the Z line previously incremented and increment by one X (1)
		i3d = i3d - i3d_decrX -- decrement the YZ plane previously incremented and increment by one X (1)
		i3d_sup = i3d_sup - i3d_sup_decrX -- idem, including the supplemental lines
	end
	vmg.execute_after_mapgen() -- needed for jungletree roots

	local t3 = os.clock()
	if vmg.loglevel >= 2 then
		print("[Valleys Mapgen] Data collecting finished in " .. displaytime(t3-t2))
		print("[Valleys Mapgen] Writing data ...")
	end

	-- execute voxelmanip boring stuff to write to the map
	vm:set_data(data)
	minetest.generate_ores(vm, minp, maxp)
	vm:set_lighting({day = 0, night = 0})
	vm:calc_lighting()
	vm:update_liquids()
	vm:write_to_map()

	local t4 = os.clock()
	if vmg.loglevel >= 2 then
		print("[Valleys Mapgen] Data writing finished in " .. displaytime(t4-t3))
	end
	if vmg.loglevel >= 1 then
		print("[Valleys Mapgen] Mapgen finished in " .. displaytime(t4-t0)) 
	end
end

dofile(vmg.path .. "/old_mapgens/2.0-trees.lua")

function vmg.get_humidity_raw(pos)
	local v13 = vmg.get_noise(pos, 13)
	local v15 = vmg.get_noise(pos, 15)
	local v18 = vmg.get_noise(pos, 18)
	return 2 ^ (v13 - v15 + v18 * 2)
end

function vmg.get_humidity(pos)
	local y = pos.y
	local flatpos = pos2d(pos)
	local hraw = vmg.get_humidity_raw(flatpos)

	local v1 = vmg.get_noise(flatpos, 1)
	local v3 = vmg.get_noise(flatpos, 3) ^ 2
	local base_ground = v1 + v3
	local sea_water = 0.5 ^ math.max((y - water_level) / 6, 0)
	local river_water = 0.5 ^ math.max((y - base_ground) / 3, 0)
	local water = sea_water + (1 - sea_water) * river_water
	return hraw + water
end

function vmg.get_temperature(pos)
	local v12 = vmg.get_noise(pos, 12) + 1
	local v17 = vmg.get_noise(pos, 17)
	local y = pos.y
	if y > 0 then
		return v17 * 0.5 ^ (y / altitude_chill)
	else
		return v17 * 0.5 ^ (-y / altitude_chill) + 20 * v12 * (1 - 2 ^ (y / lava_depth))
	end
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
	local angle = math.random() * math.pi * 2
	local distance = math.random() * player_max_distance
	local p_angle = {x = math.cos(angle), y = math.sin(angle)}
	local pos = {x = -p_angle.x * distance, y = -p_angle.y * distance}
	local elevation = vmg.get_elevation(pos)
	while elevation < water_level + 2 or math.abs(vmg.get_noise(pos, 2)) < river_size do
		pos.x = pos.x + p_angle.x
		pos.y = pos.y + p_angle.y
		elevation = vmg.get_elevation({x = round(pos.x), y = round(pos.y)})
	end
	pos = {x = round(pos.x), y = round(elevation + 1), z = round(pos.y)}
	player:setpos(pos)
	return true
end
