-- Mapgen 3.0
-- Friday September 21, 2018

-- Define perlin noises used in this mapgen by default
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
{offset = 4, scale = 1.75, seed = 1605, spread = {x = 256, y = 256, z = 256}, octaves = 3, persist = 0.5, lacunarity = 2},

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

-- Noise 19 : Simple Caves 1							3D
{offset = 0, scale = 1, seed = -8402, spread = {x = 64, y = 64, z = 64}, octaves = 3, persist = 0.5, lacunarity = 2},

-- Noise 20 : Simple Caves 2							3D
{offset = 0, scale = 1, seed = 3944, spread = {x = 64, y = 64, z = 64}, octaves = 3, persist = 0.5, lacunarity = 2},

}

-- function to get noisemaps
function vmg.noisemap(i, minp, chulens)
	local obj = minetest.get_perlin_map(vmg.noises[i], chulens)
	if minp.z then
		return obj:get3dMap_flat(minp)
	else
		return obj:get2dMap_flat(minp)
	end
end

-- If the noises are already defined in settings, use it instead of the noise parameters above.
for i, n in ipairs(vmg.noises) do
	vmg.noises[i] = vmg.define("noise_" .. i, n)
end

-- List of functions to run at the end of the mapgen procedure, used especially by jungle tree roots
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

-- Mapgen time stats
local mapgen_times = {
	preparation = {},
	noises = {},
	collecting = {},
	writing = {},
	total = {},
}

-- Define parameters
local use_3d_rivers = vmg.define("3d_rivers", false)
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

local player_max_distance = vmg.define("player_max_distance", 450)

local clay_threshold = vmg.define("clay_threshold", 1)
local silt_threshold = vmg.define("silt_threshold", 1)
local sand_threshold = vmg.define("sand_threshold", 0.75)
local dirt_threshold = vmg.define("dirt_threshold", 0.5)

local water_level = vmg.define("water_level", 1)
local river_water = vmg.define("river_water", true)

local ores = vmg.define("ores", true)

-- Register ores
-- We need more types of stone than just gray. Fortunately, there are
--  two available already. Sandstone forms in layers. Desert stone...
--  doesn't exist, but let's assume it's another sedementary rock
--  and place it similarly. -- djr
if vmg.define("stone_ores", true) then
	minetest.register_ore({ore_type="sheet", ore="default:sandstone", wherein="default:stone", clust_num_ores=250, clust_scarcity=60, clust_size=10, y_min=-1000, y_max=31000, noise_threshhold=0.1, noise_params={offset=0, scale=1, spread={x=256, y=256, z=256}, seed=4130293965, octaves=5, persist=0.60}, random_factor=1.0})
	minetest.register_ore({ore_type="sheet", ore="default:desert_stone", wherein="default:stone", clust_num_ores=250, clust_scarcity=60, clust_size=10, y_min=-1000, y_max=31000, noise_threshhold=0.1, noise_params={offset=0, scale=1, spread={x=256, y=256, z=256}, seed=163281090, octaves=5, persist=0.60}, random_factor=1.0})
end

-- TERRAIN SHAPE ACCORDING TO NOISE VALUES
-- Reurns 3 parameters:
--   mountain_ground: Height of the mountains where v5 = 0. v5 makes the ground level vary around this value.
--   slopes: Intensity of the variations around mountain_ground, basically how chaotic the terrain will be.
--   river: whether there is a river here
-- This function is executed for every vertical row in the case of 2D noise rivers, and for every node for 3D noise rivers. It allows 
local function calculate_terrain_at_point(base_ground, v2, v3, v4, v5)
	v2 = math.abs(v2) - river_size -- v2 is distance from a river, so I'd like a positive value.
	local river = v2 < 0 -- the rivers are placed where v2 is negative, so where the original v2 value is close to zero.
	if river then
		local depth = river_depth * math.sqrt(1 - (v2 / river_size + 1) ^ 2) -- use the curve of the function −sqrt(1−x²) which modelizes a circle.
		local mountain_ground = math.min(math.max(base_ground - depth, water_level - 6), base_ground)
			-- base_ground - depth : height of the bottom of the river
			-- water_level - 6 : don't make rivers below 6 nodes under the surface
		return mountain_ground, 0, river, v2 -- slopes = 0 because noise #6 has not any influence on rivers
	end

	local valleys = v3 * (1 - math.exp(- (v2 / v4) ^ 2)) -- use the curve of the function 1−exp(−(x/a)²) to modelise valleys. Making "a" varying 0 < a ≤ 1 changes the shape of the valleys. Try it with a geometry software ! (here x = v2 and a = v4). This variable represents the height of the terrain, from the rivers.
	local mountain_ground = base_ground + valleys -- approximate height of the terrain at this point (could be slightly modified by the 3D noise #6)
	local slopes = v5 * valleys -- This variable represents the maximal influence of the noise #6 on the elevation. v5 is the rate of the height from rivers (variable "valleys") that is concerned.
	return mountain_ground, slopes, river, v2
end

local data = {}


-- THE MAPGEN FUNCTION
function vmg.generate(minp, maxp, seed)
	if vmg.registered_on_first_mapgen then -- Run callbacks
		for _, f in ipairs(vmg.registered_on_first_mapgen) do
			f()
		end
		vmg.registered_on_first_mapgen = nil
		vmg.register_on_first_mapgen = nil
	end

	-- minp and maxp strings, used by logs
	local minps, maxps = minetest.pos_to_string(minp), minetest.pos_to_string(maxp)
	if vmg.loglevel >= 2 then
		print("[Valleys Mapgen] Preparing to generate map from " .. minps .. " to " .. maxps .. " ...")
	elseif vmg.loglevel == 1 then
		print("[Valleys Mapgen] Generating map from " .. minps .. " to " .. maxps .. " ...")
	end
	-- start the timer
	local t0 = os.clock()

	-- Define content IDs
	-- A content ID is a number that represents a node in the core of Minetest.
	-- Every nodename has its ID.
	-- The VoxelManipulator uses content IDs instead of nodenames.

	-- Ground nodes
	local c_stone = minetest.get_content_id("default:stone")
	local c_dirt = minetest.get_content_id("default:dirt")
	local c_lawn = minetest.get_content_id("default:dirt_with_grass")
	local c_dry = minetest.get_content_id("default:dirt_with_dry_grass")
	local c_snow = minetest.get_content_id("default:dirt_with_snow")
	local c_dirt_clay = minetest.get_content_id("valleys_mapgen:dirt_clayey")
	local c_lawn_clay = minetest.get_content_id("valleys_mapgen:dirt_clayey_with_grass")
	local c_dry_clay = minetest.get_content_id("valleys_mapgen:dirt_clayey_with_dry_grass")
	local c_snow_clay = minetest.get_content_id("valleys_mapgen:dirt_clayey_with_snow")
	local c_dirt_silt = minetest.get_content_id("valleys_mapgen:dirt_silty")
	local c_lawn_silt = minetest.get_content_id("valleys_mapgen:dirt_silty_with_grass")
	local c_dry_silt = minetest.get_content_id("valleys_mapgen:dirt_silty_with_dry_grass")
	local c_snow_silt = minetest.get_content_id("valleys_mapgen:dirt_silty_with_snow")
	local c_dirt_sand = minetest.get_content_id("valleys_mapgen:dirt_sandy")
	local c_lawn_sand = minetest.get_content_id("valleys_mapgen:dirt_sandy_with_grass")
	local c_dry_sand = minetest.get_content_id("valleys_mapgen:dirt_sandy_with_dry_grass")
	local c_snow_sand = minetest.get_content_id("valleys_mapgen:dirt_sandy_with_snow")
	local c_desert_sand = minetest.get_content_id("default:desert_sand")
	local c_sand = minetest.get_content_id("default:sand")
	local c_gravel = minetest.get_content_id("default:gravel")
	local c_silt = minetest.get_content_id("valleys_mapgen:silt")
	local c_clay = minetest.get_content_id("valleys_mapgen:red_clay")
	local c_water = minetest.get_content_id("default:water_source")
	local c_riverwater = minetest.get_content_id("default:river_water_source")
	local c_lava = minetest.get_content_id("default:lava_source")
	local c_snow_layer = minetest.get_content_id("default:snow")
	local c_glowing_fungal_stone = minetest.get_content_id("valleys_mapgen:glowing_fungal_stone")
	local c_stalactite = minetest.get_content_id("valleys_mapgen:stalactite")
	local c_stalagmite = minetest.get_content_id("valleys_mapgen:stalagmite")

	-- Mushrooms
	local c_huge_mushroom_cap = minetest.get_content_id("valleys_mapgen:huge_mushroom_cap")
	local c_giant_mushroom_cap = minetest.get_content_id("valleys_mapgen:giant_mushroom_cap")
	local c_giant_mushroom_stem = minetest.get_content_id("valleys_mapgen:giant_mushroom_stem")
	local c_mushroom_fertile_red = minetest.get_content_id("flowers:mushroom_fertile_red")
	local c_mushroom_fertile_brown = minetest.get_content_id("flowers:mushroom_fertile_brown")

	-- Air and Ignore
	local c_air = minetest.get_content_id("air")
	local c_ignore = minetest.get_content_id("ignore")

	-- The VoxelManipulator, a complicated but speedy method to set many nodes at the same time
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	vm:get_data(data) -- data is the original array of content IDs (solely or mostly air)
	-- Be careful: emin ≠ minp and emax ≠ maxp !
	-- The data array is not limited by minp and maxp. It exceeds it by 16 nodes in the 6 directions.
	-- The real limits of data array are emin and emax.
	-- The VoxelArea is used to convert a position into an index for the array.
	local a = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
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
	local n2 = use_3d_rivers and vmg.noisemap(2, minp, chulens_sup) or vmg.noisemap(2, minp2d, chulens) -- Select parameters according to 3d_rivers
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
	local i3d_sup = 1 + chulens.x * (chulens.y+5) -- index for noise #2 and #6 which have a special size
	local i3d = 1 + chulens.x * (chulens.y-1) -- index for other 3D noises

	-- Calculate increments
	local i2d_incrZ = chulens.x
	local i2d_incrX = 1 - chulens.x * chulens.z
	local i3d_incrY = - chulens.x
	local i3d_incrZ = 2 * chulens.x * chulens.y
	local i3d_sup_incrZ = 2 * chulens.x * (chulens.y+6)
	local i3d_incrX = 1 - chulens.x * chulens.y * chulens.z
	local i3d_sup_incrX = 1 - chulens.x * (chulens.y + 6) * chulens.z

	local last_cave_block = {nil,nil,nil}

	for x = minp.x, maxp.x do -- for each YZ plane
		for z = minp.z, maxp.z do -- for each vertical line in this plane
			local v1, v3, v4, v5, v7, v13, v14, v15, v16, v18 = n1[i2d], n3[i2d], n4[i2d], n5[i2d], n7[i2d], n13[i2d], n14[i2d], n15[i2d], n16[i2d], n18[i2d] -- take the noise values for 2D noises
			v3 = v3 ^ 2 -- The square function changes the behaviour of this noise : very often small, and sometimes very high.
			local base_ground = v1 + v3 -- v3 is here because terrain is generally higher where valleys are deep (mountains). base_ground represents the height of the rivers, most of the surface is above.

			local v2, mountain_ground, slopes, river
			if not use_3d_rivers then
				v2 = n2[i2d]
				mountain_ground, slopes, river, v2 = calculate_terrain_at_point(base_ground, v2, v3, v4, v5)
			end

			-- Choose biome, by default normal dirt
			local dirt = c_dirt
			local lawn = c_lawn
			local dry = c_dry
			local snow = c_snow
			local max = math.max(v13, v14, v15) -- the biome is the maximal of these 3 values.
			if max > dirt_threshold then -- if one of these values is bigger than dirt_threshold, make clayey, silty or sandy dirt, depending on the case. If none of clay, silt or sand is predominant, make normal dirt.
				if v13 == max then
					if v13 > clay_threshold then
						dirt = c_clay
						lawn = c_clay
						dry = c_clay
						snow = c_clay
					else
						dirt = c_dirt_clay
						lawn = c_lawn_clay
						dry = c_dry_clay
						snow = c_snow_clay
					end
				elseif v14 == max then
					if v14 > silt_threshold then
						dirt = c_silt
						lawn = c_silt
						dry = c_silt
						snow = c_silt
					else
						dirt = c_dirt_silt
						lawn = c_lawn_silt
						dry = c_dry_silt
						snow = c_snow_silt
					end
				else
					if v15 > sand_threshold then
						dirt = c_desert_sand
						lawn = c_desert_sand
						dry = c_desert_sand
						snow = c_desert_sand
					else
						dirt = c_dirt_sand
						lawn = c_lawn_sand
						dry = c_dry_sand
						snow = c_snow_sand
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

			local column = {}
			for y = maxp.y + 6, minp.y, -1 do -- for each node in vertical line
				local ivm = a:index(x, y, z) -- index of the data array, matching the position {x, y, z}
				local v6 = n6[i3d_sup] -- take the noise values for 3D noises
				local v8, v9, v10, v11, v12

				if use_3d_rivers then
					v2 = n2[i3d_sup]
					mountain_ground, slopes, river, v2 = calculate_terrain_at_point(base_ground, v2, v3, v4, v5)
				end

				local in_ground = v6 * slopes > y - mountain_ground
				column[y] = in_ground

				if y <= maxp.y then
					if in_ground then -- if pos is in the ground
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

						if not is_cave then -- if pos is not inside a cave
							local thickness = v7 - math.sqrt(math.abs(y)) / dirt_reduction -- Calculate dirt thickness, according to noise #7, dirt reduction parameter, and elevation (y coordinate)
							local above = math.floor(thickness + math.random()) -- The following code will look for air at this many nodes up. If any, make dirt, else, make stone. So, it's the dirt layer thickness. An "above" of zero = bare stone.
							above = math.max(above, 0) -- must be positive

							if y >= water_level and not column[y+1] and not river then -- If node above is not in the ground
								if is_beach and y < beach then -- if beach, make sand
									data[ivm] = c_sand
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
											data[ivm] = c_stone
										end
									else -- Snow
										if above > 0 then
											data[ivm] = snow -- dirt with snow
										else
											data[ivm] = c_stone
										end
										data[ivm2] = c_snow_layer -- set node above to snow
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
							elseif not column[y+above] then -- if node at "above" nodes up is not in the ground, make dirt
								if is_beach and y < beach then
									data[ivm] = c_sand
								else
									data[ivm] = dirt
								end
							else
								if do_cave_stuff and x == last_cave_block[1] and z == last_cave_block[3] and y == last_cave_block[2] + 1 and math.random() < 0.13 then
									if data[ivm - ystride] == c_air and math.random() < 0.75 then
										data[ivm] = c_stone
										data[ivm - ystride] = c_stalactite
									else
										local temp = vmg.get_temperature({x=x, y=y, z=z})
										if temp > 1.2 and temp < 1.6 then
											data[ivm] = c_glowing_fungal_stone
										end
									end
								else
									data[ivm] = c_stone
								end
							end
						elseif simple_caves and y <= lava_max_height and sr < math.ceil(-y/10000) and y > minp.y and data[ivm - ystride] == c_stone then
							data[ivm] = c_lava
						elseif (not simple_caves) and v11 + v12 > 2 ^ (y / lava_depth) and y <= lava_max_height then
							data[ivm] = c_lava
						elseif do_cave_stuff then
							-- mushrooms and water in caves -- djr
							last_cave_block = {x,y,z}

							-- check how much air we have til we reach stone
							local air_to_stone = -1
							for i = 1,3 do
								local d = data[ivm - (ystride * i)]
								if d ~= c_air then
									if d == c_stone then
										air_to_stone = i
									end
									break
								end
							end

							local temp = vmg.get_temperature({x=x, y=y, z=z})
							if air_to_stone == 1 and math.random() < 0.18 then
								local r = math.random()
								if r < 0.01 then
									data[ivm] = c_riverwater
								elseif r < 0.04 then
									-- reserved
								elseif r < 0.13 and temp > 1.2 and temp < 1.6 then
									data[ivm - ystride] = c_dirt
									data[ivm] = c_mushroom_fertile_red
								elseif r < 0.22 and temp > 1.2 and temp < 1.6 then
									data[ivm - ystride] = c_dirt
									data[ivm] = c_mushroom_fertile_brown
								elseif r < 0.44 then  -- leave some extra dirt, for appearances sake
									data[ivm - ystride] = c_dirt
								else
									data[ivm] = c_stalagmite
								end
							elseif air_to_stone == 2 and temp > 1.2 and temp < 1.6 and math.random() < 0.01 then
								data[ivm] = c_huge_mushroom_cap
								data[ivm - ystride] = c_giant_mushroom_stem
								data[ivm - (ystride * 2)] = c_dirt
							elseif air_to_stone == 3 and temp > 1.2 and temp < 1.6 and math.random() < 0.005 then
								data[ivm] = c_giant_mushroom_cap
								data[ivm - ystride] = c_giant_mushroom_stem
								data[ivm - (ystride * 2)] = c_giant_mushroom_stem
								data[ivm - (ystride * 3)] = c_dirt
							end
						end
					elseif y <= water_level then -- if pos is not in the ground, and below water_level, it's an ocean
						data[ivm] = c_water
					elseif river and y + 1 < base_ground then
						if river_water then
							data[ivm] = c_riverwater
						else
							data[ivm] = c_water
						end
					end
					i3d = i3d + i3d_incrY -- decrement i3d by one line
				end
				i3d_sup = i3d_sup + i3d_incrY -- idem
			end
			i2d = i2d + i2d_incrZ -- increment i2d by one Z
			i3d = i3d + i3d_incrZ -- idem for i3d
			i3d_sup = i3d_sup + i3d_sup_incrZ -- for i3d_sup, just avoid the 6 supplemental lines
		end
		i2d = i2d + i2d_incrX -- decrement the Z line previously incremented and increment by one X (1)
		i3d = i3d + i3d_incrX -- decrement the YZ plane previously incremented and increment by one X (1)
		i3d_sup = i3d_sup + i3d_sup_incrX -- idem, including the supplemental lines
	end
	vmg.execute_after_mapgen() -- needed for jungletree roots

	if darkage_mapgen then -- Compatibility with darkage mod by CraigyDavi. If you see error messages like "WARNING: unknown global variable" at this line, don't worry :)
		darkage_mapgen(data, a, minp, maxp, seed)
	end

	-- After data collecting, check timer
	local t3 = os.clock()
	if vmg.loglevel >= 2 then
		print("[Valleys Mapgen] Data collecting finished in " .. displaytime(t3-t2))
		print("[Valleys Mapgen] Writing data ...")
	end

	-- execute voxelmanip boring stuff to write to the map...
	vm:set_data(data)
	if ores then
		minetest.generate_ores(vm, minp, maxp)
	end
	vm:set_lighting({day = 0, night = 0})
	vm:calc_lighting()
	vm:update_liquids()
	vm:write_to_map()

	-- Now mapgen is finished. What an adventure for just generating a chunk ! I hope your processor is speedy and you have enough RAM !
	local t4 = os.clock()
	if vmg.loglevel >= 2 then
		print("[Valleys Mapgen] Data writing finished in " .. displaytime(t4-t3))
	end
	if vmg.loglevel >= 1 then
		print("[Valleys Mapgen] Mapgen finished in " .. displaytime(t4-t0)) 
	end

	table.insert(mapgen_times.preparation, t1 - t0)
	table.insert(mapgen_times.noises, t2 - t1)
	table.insert(mapgen_times.collecting, t3 - t2)
	table.insert(mapgen_times.writing, t4 - t3)
	table.insert(mapgen_times.total, t4 - t0)
end

-- Display mapgen stats on shutdown
local function stats(t)
	local n = #t

	local sum = 0
	local sum_sq = 0
	for _, k in ipairs(t) do
		sum = sum + k
		sum_sq = sum_sq + k^2
	end
	local average = sum / n
	local variance = sum_sq / n - average^2
	local standard_dev = math.sqrt(variance)

	return average, standard_dev
end

minetest.register_on_shutdown(function()
	if #mapgen_times.total == 0 then
		return
	end

	if vmg.loglevel >= 1 then
		local average, standard_dev
		print("[Valleys Mapgen] Mapgen statistics:")

		if vmg.loglevel >= 2 then
			average, standard_dev = stats(mapgen_times.preparation)
			print("[Valleys Mapgen] Mapgen preparation step:")
			print("                               average " .. displaytime(average))
			print("                    standard deviation " .. displaytime(standard_dev))
		
			average, standard_dev = stats(mapgen_times.noises)
			print("[Valleys Mapgen] Noises calculation step:")
			print("                               average " .. displaytime(average))
			print("                    standard deviation " .. displaytime(standard_dev))
		
			average, standard_dev = stats(mapgen_times.collecting)
			print("[Valleys Mapgen] Data collecting step:")
			print("                               average " .. displaytime(average))
			print("                    standard deviation " .. displaytime(standard_dev))
		
			average, standard_dev = stats(mapgen_times.writing)
			print("[Valleys Mapgen] Data writing step:")
			print("                               average " .. displaytime(average))
			print("                    standard deviation " .. displaytime(standard_dev))
		end
		average, standard_dev = stats(mapgen_times.total)
		print("[Valleys Mapgen] TOTAL:")
		print("                               average " .. displaytime(average))
		print("                    standard deviation " .. displaytime(standard_dev))
	end
end)

-- Trees are registered in a separate file
dofile(vmg.path .. "/trees.lua")
dofile(vmg.path .. "/plants_api.lua")
dofile(vmg.path .. "/plants.lua")

function vmg.get_humidity_raw(pos)
	local v13 = vmg.get_noise(pos, 13) -- Clayey soil : wetter
	local v15 = vmg.get_noise(pos, 15) -- Sandy soil : drier
	local v18 = vmg.get_noise(pos, 18) -- Humidity noise
	return 2 ^ (v13 - v15 + v18 * 2) -- Make sure that humidity is positive. Humidity is between 0.25 and 16.
end

function vmg.get_humidity(pos)
	local y = pos.y
	local flatpos = pos2d(pos)
	local hraw = vmg.get_humidity_raw(flatpos)

	-- Another influence on humidity: Dirt thickness, because when the dirt layer is very thin, the soil is drained.
	local v7 = vmg.get_noise(flatpos, 7)
	local thickness = math.max(v7 - math.sqrt(math.abs(y)) / dirt_reduction, 0) -- Positive
	local soil_humidity = hraw * (1 - math.exp(-thickness - 0.5)) -- Yes I love exponential-like functions. You can modelize whatever you want with exponentials !!!

	-- Get base ground level to know the river level that influences humidity
	local v1 = vmg.get_noise(flatpos, 1)
	local v3 = vmg.get_noise(flatpos, 3) ^ 2
	local base_ground = v1 + v3
	local sea_water = 0.5 ^ math.max((y - water_level) / 6, 0) -- At the sea level, sea_water is 1. Every 6 nodes height divide it by 2.
	local river_water = 0.5 ^ math.max((y - base_ground) / 3, 0) -- At the river level, river_water is 1. Every 3 nodes height divide it by 2.
	local water = sea_water + (1 - sea_water) * river_water -- A simple sum is not satisfactory, because it may be bigger than 1.
	return soil_humidity * (1 + water)
end

function vmg.test_dry(pos)
	return vmg.get_humidity(pos) <= dry_dirt_threshold
end

function vmg.get_temperature(pos)
	local v12 = vmg.get_noise(pos, 12) + 1 -- Lava noise for underground
	local v17 = vmg.get_noise(pos, 17) -- Climate noise
	local y = pos.y
	if y > 0 then
		return v17 * 0.5 ^ (y / altitude_chill) -- Divide v17 by 2 by climbing "altitude_chill" nodes
	else
		return v17 * 0.5 ^ (-y / altitude_chill) + 20 * v12 * (1 - 2 ^ (y / lava_depth)) -- Underground, v17 less and less matter. So, gradually replace it by another calculation method, based on lava. Sorry: I don't remember the sense of this code :/
	end
end

function vmg.test_snow(pos)
	return vmg.get_temperature(pos) <= snow_threshold
end

function vmg.get_noise(pos, i)
	local n = vmg.noises[i]
	local noise = minetest.get_perlin(n)
	if not pos.z then -- 2D noise
		return noise:get2d(pos)
	else -- 3D noise
		return noise:get3d(pos)
	end
end

local function round(n)
	return math.floor(n + 0.5)
end

function vmg.get_elevation(pos)
	local v1 = vmg.get_noise(pos, 1) -- base ground
	local v2, mountain_ground, slopes, river
	local v3 = vmg.get_noise(pos, 3) ^ 2 -- valleys depth
	local v4 = vmg.get_noise(pos, 4) -- valleys profile
	local v5 = vmg.get_noise(pos, 5) -- inter-valleys slopes

	local base_ground = v1 + v3
	local epos = pos3d(pos, math.ceil(base_ground)) -- Position with elevation (3D)
	v2 = vmg.get_noise(use_3d_rivers and epos or pos, 2) -- Use 2D or 3D position according to use_3d_rivers

	mountain_ground, slopes, river = calculate_terrain_at_point(base_ground, v2, v3, v4, v5) -- Calculate terrain parameters
	if river then
		return math.ceil(base_ground), true
	end

	epos = pos3d(pos, math.ceil(mountain_ground)) -- set epos to mountain_ground (most probable ground level) to optimize
	if use_3d_rivers then
		v2 = vmg.get_noise(epos, 2)
		mountain_ground, slopes, river = calculate_terrain_at_point(base_ground, v2, v3, v4, v5) -- Recalculate
	end

	if vmg.get_noise(epos, 6) * slopes > epos.y - mountain_ground then -- Position is in the ground, so look for air higher
		repeat
			epos.y = epos.y + 1
			if use_3d_rivers then
				v2 = vmg.get_noise(epos, 2)
				mountain_ground, slopes, river = calculate_terrain_at_point(base_ground, v2, v3, v4, v5)
			end
		until vmg.get_noise(epos, 6) * slopes <= epos.y - mountain_ground -- End of the loop when there is air
		return epos.y, river -- Return position of the first air node
	else -- Position is not in the ground, so look for dirt lower
		repeat
			epos.y = epos.y - 1
			if use_3d_rivers then
				v2 = vmg.get_noise(epos, 2)
				mountain_ground, slopes, river = calculate_terrain_at_point(base_ground, v2, v3, v4, v5)
			end
		until vmg.get_noise(epos, 6) * slopes > epos.y - mountain_ground -- End of the loop when there is dirt (or any ground)
		return epos.y+1, river -- Return position of the first air node
	end
end

function vmg.spawnplayer(player)
	-- Choose a point to spawn the player, from an angle, and a distance from (0;0)
	local angle = math.random() * math.pi * 2
	local distance = math.random() * player_max_distance
	local p_angle = {x = math.cos(angle), y = math.sin(angle)} -- Get a position on the trigonometric circle. This position is exactely at 1 unit from (0;0)
	local pos = {x = p_angle.x * distance, y = p_angle.y * distance} -- Multiply it by distance, to get the position that meets angle and distance
	local elevation, river = vmg.get_elevation(pos) -- get elevation from the previous function
	while elevation < water_level + 2 or river do -- If there is water, choose another point
		-- Move the position by one unit, to (0;0) to avoid spawning farther than player_max_distance.
		pos.x = pos.x - p_angle.x
		pos.y = pos.y - p_angle.y
		-- and check again
		elevation, river = vmg.get_elevation({x = round(pos.x), y = round(pos.y)})
	end -- end of the loop when pos is not in the water
	pos = {x = round(pos.x), y = round(elevation + 1), z = round(pos.y)} -- Round position and add elevation
	player:setpos(pos)
	return true -- Disable default player spawner
end
