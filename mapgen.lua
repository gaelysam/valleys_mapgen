-- Mapgen 2.3-dev
-- Saturday September 26, 2015

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

function vmg.put_stats(t0, t1, t2, t3, t4)
	table.insert(mapgen_times.preparation,	t1-t0)
	table.insert(mapgen_times.noises,	t2-t1)
	table.insert(mapgen_times.collecting,	t3-t2)
	table.insert(mapgen_times.writing,	t4-t3)
	table.insert(mapgen_times.total,	t4-t0)
end

local player_max_distance = vmg.define("player_max_distance", 450)

local water_level = vmg.define("water_level", 1)

local ores = vmg.define("ores", true)

local algo = vmg.define("algorithm", "noise")

local filename
if algo == "noise" then
	filename = vmg.path .. "/mapgen_noiseval.lua"
	-- Other algorithms may come :)
end

local mapgen_algorithm, get_elevation, get_humidity, get_temperature = dofile(filename)

vmg.get_elevation = get_elevation
vmg.get_humidity = get_humidity
vmg.get_temperature = get_temperature

-- Register ores
-- We need more types of stone than just gray. Fortunately, there are
--  two available already. Sandstone forms in layers. Desert stone...
--  doesn't exist, but let's assume it's another sedementary rock
--  and place it similarly. -- djr
if vmg.define("stone_ores", true) then
	minetest.register_ore({ore_type="sheet", ore="default:sandstone", wherein="default:stone", clust_num_ores=250, clust_scarcity=60, clust_size=10, y_min=-1000, y_max=31000, noise_threshhold=0.1, noise_params={offset=0, scale=1, spread={x=256, y=256, z=256}, seed=4130293965, octaves=5, persist=0.60}, random_factor=1.0})
	minetest.register_ore({ore_type="sheet", ore="default:desert_stone", wherein="default:stone", clust_num_ores=250, clust_scarcity=60, clust_size=10, y_min=-1000, y_max=31000, noise_threshhold=0.1, noise_params={offset=0, scale=1, spread={x=256, y=256, z=256}, seed=163281090, octaves=5, persist=0.60}, random_factor=1.0})
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

	local c = {

		-- Ground nodes
		stone = minetest.get_content_id("default:stone"),
		dirt = minetest.get_content_id("default:dirt"),
		lawn = minetest.get_content_id("default:dirt_with_grass"),
		dry = minetest.get_content_id("default:dirt_with_dry_grass"),
		snow = minetest.get_content_id("default:dirt_with_snow"),
		dirt_clay = minetest.get_content_id("valleys_mapgen:dirt_clayey"),
		lawn_clay = minetest.get_content_id("valleys_mapgen:dirt_clayey_with_grass"),
		dry_clay = minetest.get_content_id("valleys_mapgen:dirt_clayey_with_dry_grass"),
		snow_clay = minetest.get_content_id("valleys_mapgen:dirt_clayey_with_snow"),
		dirt_silt = minetest.get_content_id("valleys_mapgen:dirt_silty"),
		lawn_silt = minetest.get_content_id("valleys_mapgen:dirt_silty_with_grass"),
		dry_silt = minetest.get_content_id("valleys_mapgen:dirt_silty_with_dry_grass"),
		snow_silt = minetest.get_content_id("valleys_mapgen:dirt_silty_with_snow"),
		dirt_sand = minetest.get_content_id("valleys_mapgen:dirt_sandy"),
		lawn_sand = minetest.get_content_id("valleys_mapgen:dirt_sandy_with_grass"),
		dry_sand = minetest.get_content_id("valleys_mapgen:dirt_sandy_with_dry_grass"),
		snow_sand = minetest.get_content_id("valleys_mapgen:dirt_sandy_with_snow"),
		desert_sand = minetest.get_content_id("default:desert_sand"),
		sand = minetest.get_content_id("default:sand"),
		gravel = minetest.get_content_id("default:gravel"),
		silt = minetest.get_content_id("valleys_mapgen:silt"),
		clay = minetest.get_content_id("valleys_mapgen:red_clay"),
		water = minetest.get_content_id("default:water_source"),
		riverwater = minetest.get_content_id("default:river_water_source"),
		lava = minetest.get_content_id("default:lava_source"),
		snow_layer = minetest.get_content_id("default:snow"),
		glowing_fungal_stone = minetest.get_content_id("valleys_mapgen:glowing_fungal_stone"),
		stalactite = minetest.get_content_id("valleys_mapgen:stalactite"),
		stalagmite = minetest.get_content_id("valleys_mapgen:stalagmite"),

		-- Mushrooms
		huge_mushroom_cap = minetest.get_content_id("valleys_mapgen:huge_mushroom_cap"),
		giant_mushroom_cap = minetest.get_content_id("valleys_mapgen:giant_mushroom_cap"),
		giant_mushroom_stem = minetest.get_content_id("valleys_mapgen:giant_mushroom_stem"),
		mushroom_fertile_red = minetest.get_content_id("flowers:mushroom_fertile_red"),
		mushroom_fertile_brown = minetest.get_content_id("flowers:mushroom_fertile_brown"),

		-- Air and Ignore
		air = minetest.get_content_id("air"),
		ignore = minetest.get_content_id("ignore"),
	}

	-- The VoxelManipulator, a complicated but speedy method to set many nodes at the same time
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	vm:get_data(data) -- data is the original array of content IDs (solely or mostly air)
	-- Be careful: emin ≠ minp and emax ≠ maxp !
	-- The data array is not limited by minp and maxp. It exceeds it by 16 nodes in the 6 directions.
	-- The real limits of data array are emin and emax.
	-- The VoxelArea is used to convert a position into an index for the array.
	local a = VoxelArea:new({MinEdge = emin, MaxEdge = emax})

	t1, t2 = mapgen_algorithm(minp, maxp, data, a, c)

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

	vmg.put_stats(t0, t1, t2, t3, t4)
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

function vmg.get_noise(pos, i)
	local n = vmg.noises[i]
	local noise = minetest.get_perlin(n)
	if not pos.z then -- 2D noise
		return noise:get2d(pos)
	else -- 3D noise
		return noise:get3d(pos)
	end
end

local round = math.round

function vmg.spawnplayer(player)
	-- Choose a point to spawn the player, from an angle, and a distance from (0;0)
	local angle = math.random() * math.pi * 2
	local distance = math.random() * player_max_distance
	local p_angle = {x = math.cos(angle), y = math.sin(angle)} -- Get a position on the trigonometric circle. This position is exactely at 1 unit from (0;0)
	local pos = {x = p_angle.x * distance, y = p_angle.y * distance} -- Multiply it by distance, to get the position that meets angle and distance
	local elevation, river = get_elevation(pos) -- get elevation from the previous function
	while elevation < water_level + 2 or river do -- If there is water, choose another point
		-- Move the position by one unit, to (0;0) to avoid spawning farther than player_max_distance.
		pos.x = pos.x - p_angle.x
		pos.y = pos.y - p_angle.y
		-- and check again
		elevation, river = get_elevation({x = round(pos.x), y = round(pos.y)})
	end -- end of the loop when pos is not in the water
	pos = {x = round(pos.x), y = round(elevation + 1), z = round(pos.y)} -- Round position and add elevation
	player:setpos(pos)
	return true -- Disable default player spawner
end
