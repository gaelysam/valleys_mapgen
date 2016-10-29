-- Define parameters
local river_depth = vmg.define("river_depth", 3) + 1
local river_size = vmg.define("river_size", 5) / 100
local caves_size = vmg.define("caves_size", 7) / 100
local lava_depth = vmg.define("lava_depth", 2000)
local lava_max_height = vmg.define("lava_max_height", -1)
local altitude_chill = vmg.define("altitude_chill", 90)
local do_caves = vmg.define("caves", true)
local simple_caves = vmg.define("simple_caves", false)
local do_cave_stuff = vmg.define("cave_stuff", false)
local dry_rivers = vmg.define("dry_rivers", false)

local average_stone_level = vmg.define("average_stone_level", 180)
local dirt_reduction = math.sqrt(average_stone_level) / (vmg.noises[7].offset - 0.5) -- Calculate dirt_reduction such as v7 - sqrt(average_stone_level) / dirt_reduction = 0.5 on average. This means that, on average at y = average_stone_level, dirt_thickness = 0.5 (half of the surface is bare stone)
local average_snow_level = vmg.define("average_snow_level", 100)
local snow_threshold = vmg.noises[17].offset * 0.5 ^ (average_snow_level / altitude_chill)
local dry_dirt_threshold = vmg.define("dry_dirt_threshold", 0.6)

local clay_threshold = vmg.define("clay_threshold", 1)
local silt_threshold = vmg.define("silt_threshold", 1)
local sand_threshold = vmg.define("sand_threshold", 0.75)
local dirt_threshold = vmg.define("dirt_threshold", 0.5)

local water_level = vmg.define("water_level", 1)
local river_water = vmg.define("river_water", true)

local function mapgen_algorithm(minp, maxp, data, a, c)
	local ystride = a.ystride -- Tip : the ystride of a VoxelArea is the number to add to the array index to get the index of the position above. It's faster because it avoids to completely recalculate the index.

	local chulens = vector.add(vector.subtract(maxp, minp), 1) -- Size of the generated area, used by noisemaps
	local chulens_sup = {x = chulens.x, y = chulens.y + 6, z = chulens.z} -- for the noise #6 that needs extra values
	local minp2d = pos2d(minp)

	-- Mapgen preparation is now finished. Check the timer to know the elapsed time.
	local t1 = os.clock()
	if vmg.loglevel >= 2 then
		print("[Valleys Mapgen] Mapgen preparation finished in " .. displaytime(t1-t0))
		print("[Valleys Mapgen] Calculating noises ...")
	end

	-- Calculate the noise values
	local n1 = vmg.noisemap(1, minp2d, chulens)
	local n2 = vmg.noisemap(2, minp2d, chulens)
	local n3 = vmg.noisemap(3, minp2d, chulens)
	local n4 = vmg.noisemap(4, minp2d, chulens)
	local n5 = vmg.noisemap(5, minp2d, chulens)
	local n6 = vmg.noisemap(6, minp, chulens_sup)
	local n7 = vmg.noisemap(7, minp2d, chulens)
	local n8
	local n9
	local n10
	local n11
	local n12
	local n19  -- It's more convenient to put these here with the other caves.
	local n20
	if do_caves then
		if simple_caves then
			n19 = vmg.noisemap(19, minp, chulens)
			n20 = vmg.noisemap(20, minp, chulens)
		else
			n8 = vmg.noisemap(8, minp, chulens)
			n9 = vmg.noisemap(9, minp, chulens)
			n10 = vmg.noisemap(10, minp, chulens)
			n11 = vmg.noisemap(11, minp, chulens)
			n12 = vmg.noisemap(12, minp, chulens)
		end
	end
	local n13 = vmg.noisemap(13, minp2d, chulens)
	local n14 = vmg.noisemap(14, minp2d, chulens)
	local n15 = vmg.noisemap(15, minp2d, chulens)
	local n16 = vmg.noisemap(16, minp2d, chulens)
	-- Noise #17 is not used this way
	local n18 = vmg.noisemap(18, minp2d, chulens)

	-- After noise calculation, check the timer
	local t2 = os.clock()
	if vmg.loglevel >= 2 then
		print("[Valleys Mapgen] Noises calculation finished in " .. displaytime(t2-t1))
		print("[Valleys Mapgen] Collecting data ...")
	end



	-- THE CORE OF THE MOD: THE MAPGEN ALGORITHM ITSELF

	-- indexes for noise arrays
	local i2d = 1 -- index for 2D noises
	local i3d_sup = 1 -- index for noise #6 which has a special size
	local i3d = 1 -- index for 3D noises

	-- Calculate increments
	local i2d_incrZ = chulens.z
	local i2d_decrX = chulens.x * chulens.z - 1
	local i3d_incrY = chulens.y
	local i3d_sup_incrZ = 6 * chulens.y
	local i3d_decrX = chulens.x * chulens.y * chulens.z - 1
	local i3d_sup_decrX = chulens.x * (chulens.y + 6) * chulens.z - 1

	local last_cave_block = {nil,nil,nil}

	for x = minp.x, maxp.x do -- for each YZ plane
		for z = minp.z, maxp.z do -- for each vertical line in this plane
			local v1, v2, v3, v4, v5, v7, v13, v14, v15, v16, v18 = n1[i2d], n2[i2d], n3[i2d], n4[i2d], n5[i2d], n7[i2d], n13[i2d], n14[i2d], n15[i2d], n16[i2d], n18[i2d] -- take the noise values for 2D noises
			v3 = v3 ^ 2 -- The square function changes the behaviour of this noise : very often small, and sometimes very high.
			local base_ground = v1 + v3 -- v3 is here because terrain is generally higher where valleys are deep (mountains). base_ground represents the height of the rivers, most of the surface is above.
			v2 = math.abs(v2) - river_size -- v2 represents the distance from the river, in arbitrary units.
			local river = v2 < 0 -- the rivers are placed where v2 is negative, so where the original v2 value is close to zero.
			local valleys = v3 * (1 - math.exp(- (v2 / v4) ^ 2)) -- use the curve of the function 1−exp(−(x/a)²) to modelise valleys. Making "a" varying 0 < a ≤ 1 changes the shape of the valleys. Try it with a geometry software ! (here x = v2 and a = v4). This variable represents the height of the terrain, from the rivers.
			local mountain_ground = base_ground + valleys -- approximate height of the terrain at this point (could be slightly modified by the 3D noise #6)
			local slopes = v5 * valleys -- This variable represents the maximal influence of the noise #6 on the elevation. v5 is the rate of the height from rivers (variable "valleys") that is concerned.

			if river then
				local depth = river_depth * math.sqrt(1 - (v2 / river_size + 1) ^ 2) -- use the curve of the function −sqrt(1−x²) which models a circle.
				mountain_ground = math.min(math.max(base_ground - depth, water_level - 6), mountain_ground)
					-- base_ground - depth : height of the bottom of the river
					-- water_level - 6 : don't make rivers below 6 nodes under the surface
				slopes = 0 -- noise #6 has not any influence on rivers
			end

			-- Choose biome, by default normal dirt
			local dirt = c.dirt
			local lawn = c.lawn
			local dry = c.dry
			local snow = c.snow
			local max = math.max(v13, v14, v15) -- the biome is the maximal of these 3 values.
			if max > dirt_threshold then -- if one of these values is bigger than dirt_threshold, make clayey, silty or sandy dirt, depending on the case. If none of clay, silt or sand is predominant, make normal dirt.
				if v13 == max then
					if v13 > clay_threshold then
						dirt = c.clay
						lawn = c.clay
						dry = c.clay
						snow = c.clay
					else
						dirt = c.dirt_clay
						lawn = c.lawn_clay
						dry = c.dry_clay
						snow = c.snow_clay
					end
				elseif v14 == max then
					if v14 > silt_threshold then
						dirt = c.silt
						lawn = c.silt
						dry = c.silt
						snow = c.silt
					else
						dirt = c.dirt_silt
						lawn = c.lawn_silt
						dry = c.dry_silt
						snow = c.snow_silt
					end
				else
					if v15 > sand_threshold then
						dirt = c.desert_sand
						lawn = c.desert_sand
						dry = c.desert_sand
						snow = c.desert_sand
					else
						dirt = c.dirt_sand
						lawn = c.lawn_sand
						dry = c.dry_sand
						snow = c.snow_sand
					end
				end
			end
			local is_beach = v15 > 0 and v16 > 0 -- 2 conditions must been met to make possible the beach.
			local beach = v15 * v16 + water_level -- the y coordinate below which dirt is replaced by beach sand. So if the terrain is higher, there is no beach.

			-- raw humidity, see below at vmg.get_humidity
			local hraw = 2 ^ (v13 - v15 + v18 * 2)

			-- After base_ground is used for terrain, modify it by humidity
			-- to make rivers dry up in deserts.
			if dry_rivers and hraw < 1 then  -- average humidity?
				base_ground = base_ground + (hraw - 1) * river_depth
			end

			for y = minp.y, maxp.y do -- for each node in vertical line
				local ivm = a:index(x, y, z) -- index of the data array, matching the position {x, y, z}
				local v6, v8, v9, v10, v11, v12 = n6[i3d_sup], -1, -1, -1, -1, -1 -- take the noise values for 3D noises
				local is_cave = false
				local sr, v19, v20
				if do_caves then
					if simple_caves then
						v19, v20 = n19[i3d], n20[i3d] -- take the noise values for 3D noises
						local n1 = (math.abs(v19) < 0.07)
						local n2 = (math.abs(v20) < 0.07)
						is_cave = n1 and n2
						sr = math.floor((v19 + v20) * 100000) % 1000
					else
						v8, v9, v10, v11, v12 = n8[i3d], n9[i3d], n10[i3d], n11[i3d], n12[i3d] -- take the noise values for 3D noises
						is_cave = v8 ^ 2 + v9 ^ 2 + v10 ^ 2 + v11 ^ 2 < caves_size -- The 4 cave noises must be close to zero to produce a cave. The square is used for 2 reasons : we need positive values, and, for mathematical reasons, it results in more circular caves.
					end
				end

				if v6 * slopes > y - mountain_ground then -- if pos is in the ground
					if not is_cave then -- if pos is not inside a cave
						local thickness = v7 - math.sqrt(math.abs(y)) / dirt_reduction -- Calculate dirt thickness, according to noise #7, dirt reduction parameter, and elevation (y coordinate)
						local above = math.floor(thickness + math.random()) -- The following code will look for air at this many nodes up. If any, make dirt, else, make stone. So, it's the dirt layer thickness. An "above" of zero = bare stone.
						above = math.max(above, 0) -- must be positive

						if y >= water_level and n6[i3d_sup+i3d_incrY] * slopes <= y + 1 - mountain_ground and not river then -- If node above is in the ground
							if is_beach and y < beach then -- if beach, make sand
								data[ivm] = c.sand
							else -- place lawn

								-- calculate humidity, see below at vmg.get_humidity
								local soil_humidity = hraw * (1 - math.exp(-thickness - 0.5))

								local sea_water = 0.5 ^ math.max((y - water_level) / 6, 0)
								local river_water = 0.5 ^ math.max((y - base_ground) / 3, 0)
								local water = sea_water + (1 - sea_water) * river_water
								local humidity = soil_humidity * (1 + water)

								local ivm2 = ivm + ystride -- index of the node above
								y = y + 1
								local pos = {x = x, y = y, z = z}

								local v17 = vmg.get_noise(pos, 17) -- Noise #17 is used this way : that's a 3D noise, so a noisemap would be heavy, and less than 2% would be used, contrary to other 3D noises. So it's faster to calculate it node per node, only when needed.
								local temp -- calculate_temperature for node above, see below at vmg.get_temperature
								if y > 0 then
									temp = v17 * 0.5 ^ (y / altitude_chill) -- Divide temperature noise by 2 by climbing altitude_chill
								else
									temp = v17 * 0.5 ^ (-y / altitude_chill) + 20 * (v12 + 1) * (1 - 2 ^ (y / lava_depth))
								end

								if temp > snow_threshold then -- If temperature is too high for snow
									if above > 0 then
										if humidity <= dry_dirt_threshold then
											data[ivm] = dry
										else
											data[ivm] = lawn
										end
									else
										data[ivm] = c.stone
									end
								else -- Snow
									if above > 0 then
										data[ivm] = snow -- dirt with snow
									else
										data[ivm] = c.stone
									end
									data[ivm2] = c.snow_layer -- set node above to snow
								end

								if above > 0 then
									local conditions = { -- pack it in a table, for plants API
										v1 = v1,
										v2 = v2,
										v3 = v3,
										v4 = v4,
										v5 = v5,
										v6 = v6,
										v7 = v7,
										v8 = v8,
										v9 = v9,
										v10 = v10,
										v11 = v11,
										v12 = v12,
										v13 = v13,
										v14 = v14,
										v15 = v15,
										v16 = v16,
										v17 = v17,
										v18 = v18,
										v19 = v19,
										v20 = v20,
										temp = temp,
										humidity = humidity,
										sea_water = sea_water,
										river_water = river_water,
										water = water,
										thickness = thickness
									}

									vmg.choose_generate_plant(conditions, pos, data, a, ivm2)
								end

								y = y - 1
							end
						elseif n6[i3d_sup+above*i3d_incrY] * slopes <= y + above - mountain_ground then -- if node at "above" nodes up is not in the ground, make dirt
							if is_beach and y < beach then
								data[ivm] = c.sand
							else
								data[ivm] = dirt
							end
						else
							if do_cave_stuff and x == last_cave_block[1] and z == last_cave_block[3] and y == last_cave_block[2] + 1 and math.random() < 0.13 then
								if data[ivm - ystride] == c.air and math.random() < 0.75 then
									data[ivm] = c.stone
									data[ivm - ystride] = c.stalactite
								else
									local temp = vmg.get_temperature({x=x, y=y, z=z})
									if temp > 1.2 and temp < 1.6 then
										data[ivm] = c.glowing_fungal_stone
									end
								end
							else
								data[ivm] = c.stone
							end
						end
					elseif simple_caves and y <= lava_max_height and sr < math.ceil(-y/10000) and y > minp.y and data[ivm - ystride] == c.stone then
						data[ivm] = c.lava
					elseif (not simple_caves) and v11 + v12 > 2 ^ (y / lava_depth) and y <= lava_max_height then
						data[ivm] = c.lava
					elseif do_cave_stuff then
						-- mushrooms and water in caves -- djr
						last_cave_block = {x,y,z}

						-- check how much air we have til we reach stone
						local air_to_stone = -1
						for i = 1,3 do
							local d = data[ivm - (ystride * i)]
							if d ~= c.air then
								if d == c.stone then
									air_to_stone = i
								end
								break
							end
						end

						local temp = vmg.get_temperature({x=x, y=y, z=z})
						if air_to_stone == 1 and math.random() < 0.18 then
							local r = math.random()
							if r < 0.01 then
								data[ivm] = c.riverwater
							elseif r < 0.04 then
								-- reserved
							elseif r < 0.13 and temp > 1.2 and temp < 1.6 then
								data[ivm - ystride] = c.dirt
								data[ivm] = c.mushroom_fertile_red
							elseif r < 0.22 and temp > 1.2 and temp < 1.6 then
								data[ivm - ystride] = c.dirt
								data[ivm] = c.mushroom_fertile_brown
							elseif r < 0.44 then  -- leave some extra dirt, for appearances sake
								data[ivm - ystride] = c.dirt
							else
								data[ivm] = c.stalagmite
							end
						elseif air_to_stone == 2 and temp > 1.2 and temp < 1.6 and math.random() < 0.01 then
							data[ivm] = c.huge_mushroom_cap
							data[ivm - ystride] = c.giant_mushroom_stem
							data[ivm - (ystride * 2)] = c.dirt
						elseif air_to_stone == 3 and temp > 1.2 and temp < 1.6 and math.random() < 0.005 then
							data[ivm] = c.giant_mushroom_cap
							data[ivm - ystride] = c.giant_mushroom_stem
							data[ivm - (ystride * 2)] = c.giant_mushroom_stem
							data[ivm - (ystride * 3)] = c.dirt
						end
					end
				elseif y <= water_level then -- if pos is not in the ground, and below water_level, it's an ocean
					data[ivm] = c.water
				elseif river and y + 1 < base_ground then
					if river_water then
						data[ivm] = c.riverwater
					else
						data[ivm] = c.water
					end
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

	return t1, t2
end

local round = math.round

local function get_elevation(pos)
	local v1 = vmg.get_noise(pos, 1) -- base ground
	local v2 = math.abs(vmg.get_noise(pos, 2)) - river_size -- valleys
	local v3 = vmg.get_noise(pos, 3) ^ 2 -- valleys depth
	local base_ground = v1 + v3
	if v2 < 0 then -- river
		return math.ceil(base_ground), true
	end
	local v4 = vmg.get_noise(pos, 4) -- valleys profile
	local v5 = vmg.get_noise(pos, 5) -- inter-valleys slopes
	-- Same calculation than in vmg.generate
	local base_ground = v1 + v3
	local valleys = v3 * (1 - math.exp(- (v2 / v4) ^ 2))
	local mountain_ground = base_ground + valleys
	local pos = pos3d(pos, round(mountain_ground)) -- For now we don't know the elevation. We will test some y values. Set the position to montain_ground which is the most probable value.
	local slopes = v5 * valleys
	if vmg.get_noise(pos, 6) * slopes > pos.y - mountain_ground then -- Position is in the ground, so look for air higher
		pos.y = pos.y + 1
		while vmg.get_noise(pos, 6) * slopes > pos.y - mountain_ground do
			pos.y = pos.y + 1
		end -- End of the loop when there is air
		return pos.y, false -- Return position of the first air node, and false because that's not a river
	else -- Position is not in the ground, so look for dirt lower
		pos.y = pos.y - 1
		while vmg.get_noise(pos, 6) * slopes <= pos.y - mountain_ground do
			pos.y = pos.y - 1
		end -- End of the loop when there is dirt (or any ground)
		pos.y = pos.y + 1 -- We have the latest dirt node and we want the first air node that is just above
		return pos.y, false -- Return position of the first air node, and false because that's not a river
	end
end

local function get_humidity_raw(pos)
	local v13 = vmg.get_noise(pos, 13) -- Clayey soil : wetter
	local v15 = vmg.get_noise(pos, 15) -- Sandy soil : drier
	local v18 = vmg.get_noise(pos, 18) -- Humidity noise
	return 2 ^ (v13 - v15 + v18 * 2) -- Make sure that humidity is positive. Humidity is between 0.25 and 16.
end

local function get_humidity(pos)
	local y = pos.y
	local flatpos = pos2d(pos)
	local hraw = vmg.get_humidity_raw(flatpos)

	-- Another influence on humidity: Dirt thickness, because when the dirt layer is very thin, the soil is drained.
	local v7 = vmg.get_noise(flatpos, 7)
	local thickness = math.max(v7 - math.sqrt(math.abs(y)) / dirt_reduction, 0) -- Positive
	local soil_humidity = hraw * (1 - math.exp(-thickness - 0.5)) -- Yes I love exponential-like functions. You can model whatever you want with exponentials !!!

	-- Get base ground level to know the river level that influences humidity
	local v1 = vmg.get_noise(flatpos, 1)
	local v3 = vmg.get_noise(flatpos, 3) ^ 2
	local base_ground = v1 + v3
	local sea_water = 0.5 ^ math.max((y - water_level) / 6, 0) -- At the sea level, sea_water is 1. Every 6 nodes height divide it by 2.
	local river_water = 0.5 ^ math.max((y - base_ground) / 3, 0) -- At the river level, river_water is 1. Every 3 nodes height divide it by 2.
	local water = sea_water + (1 - sea_water) * river_water -- A simple sum is not satisfactory, because it may be bigger than 1.
	return soil_humidity * (1 + water)
end

local function get_temperature(pos)
	local v12 = vmg.get_noise(pos, 12) + 1 -- Lava noise for underground
	local v17 = vmg.get_noise(pos, 17) -- Climate noise
	local y = pos.y
	if y > 0 then
		return v17 * 0.5 ^ (y / altitude_chill) -- Divide v17 by 2 by climbing "altitude_chill" nodes
	else
		return v17 * 0.5 ^ (-y / altitude_chill) + 20 * v12 * (1 - 2 ^ (y / lava_depth)) -- Underground, v17 less and less matter. So, gradually replace it by another calculation method, based on lava. Sorry: I don't remember the sense of this code :/
	end
end

return mapgen_algorithm, get_elevation, get_humidity, get_temperature
