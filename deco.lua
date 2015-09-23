
-- Change leafdecay ratings
minetest.add_group("default:leaves", {leafdecay = 4})
minetest.add_group("default:jungleleaves", {leafdecay = 7})
minetest.add_group("default:pine_needles", {leafdecay = 6})

minetest.clear_registered_decorations()

	-- biomes = {"sandstone_grassland", "glacier", "tundra", "taiga", "stone_grassland", "coniferous_forest", "deciduous_forest", "desert", "savanna", "rainforest", "rainforest_swamp",},

local v2 = {offset = 0, scale = 0.005, seed = -6050, spread = {x = 256, y = 256, z = 256}, octaves = 5, persist = 0.6, lacunarity = 2}

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt", "default:dirt_with_grass"},
	sidelen = 80,
	-- noise_params = v2,
	fill_ratio = 0.02,
	decoration = {"valleys_mapgen_c:bird_of_paradise",},
	biomes = {"rainforest", "rainforest_swamp",},
	-- y_min = -31000,
	-- y_max = 60,
	-- flags = "place_center_x, place_center_z",
	-- rotation = "random",
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt", "default:dirt_with_grass", "default:jungleleaves"},
	sidelen = 80,
	-- noise_params = v2,
	fill_ratio = 0.02,
	decoration = {"valleys_mapgen_c:orchid",},
	biomes = {"rainforest", "rainforest_swamp",},
	-- y_min = -31000,
	-- y_max = 60,
	-- flags = "place_center_x, place_center_z",
	-- rotation = "random",
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass"},
	sidelen = 80,
	noise_params = v2,
	-- fill_ratio = 0.1,
	decoration = {"valleys_mapgen_c:hibiscus",},
	biomes = {"sandstone_grassland", "stone_grassland", "coniferous_forest", "deciduous_forest", "rainforest",},
	-- y_min = -31000,
	y_max = 60,
	-- flags = "place_center_x, place_center_z",
	-- rotation = "random",
})

local mushroom1 = {
	size = {x=1, y=3, z=1},
	data = {
		{name="air", param1=255},
		{name="valleys_mapgen_c:giant_mushroom_stem", param1=255},
		{name="valleys_mapgen_c:huge_mushroom_cap", param1=255},
	},
	yslice_prob = {
		{ypos=1, prob=255},
	},
}

local mushroom2 = {
	size = {x=1, y=4, z=1},
	data = {
		{name="air", param1=255},
		{name="valleys_mapgen_c:giant_mushroom_stem", param1=255},
		{name="valleys_mapgen_c:giant_mushroom_stem", param1=255},
		{name="valleys_mapgen_c:giant_mushroom_cap", param1=255},
	},
	yslice_prob = {
		{ypos=1, prob=255},
	},
}

if false then
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"default:dirt"},
		sidelen = 80,
		fill_ratio = 0.01,
		--biomes = {"underground"},
		-- y_min = -31000,
		-- y_max = 31000,
		schematic = mushroom1,
		flags = "place_center_x, place_center_z",
		-- rotation = "random",
	})

	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"default:dirt"},
		sidelen = 80,
		fill_ratio = 0.01,
		--biomes = {"underground"},
		-- y_min = -31000,
		-- y_max = 31000,
		schematic = mushroom2,
		flags = "place_center_x, place_center_z",
		-- rotation = "random",
	})
end

function math.round(i)
	return math.floor(i + 0.5)
end

function vmg.generate_tree_schematic(height, radii, trunk, leaf, limbs)
	local a = "air"
	local d = {}

	if height <= radii.y*2 then
		return
	end

	local s = {size={x=radii.x*2+1, y=height, z=radii.z*2+1}}

	-- clear the array
	for x = -radii.x,radii.x do
		for y = 0,height-1 do
			for z = -radii.z,radii.z do
				local i = (x+radii.x)*(2*radii.z+1)*height + y*(2*radii.z+1) + (z+radii.z) + 1
				d[i] = {}
				d[i].name = a
				d[i].param1 = 000
			end
		end
	end

	-- the main trunk
	for y = 0,height-radii.y-1 do
		local i = (0+radii.x)*(2*radii.z+1)*height + y*(2*radii.z+1) + (0+radii.z) + 1
		d[i].name = trunk
		d[i].param1 = 255
	end

	-- jungle roots and extra leaves
	if string.find(leaf, "jungle") then
		for x = -1,1 do
			for y = 0,height-radii.y-1 do
				for z = -1,1 do
					local i = (x+radii.x)*(2*radii.z+1)*height + y*(2*radii.z+1) + (z+radii.z) + 1
					if x == 0 and z == 0 then
						d[i].name = trunk
						d[i].param1 = 255
					elseif (x == 0 or z == 0) and y < 3 then
						d[i].name = trunk
						d[i].param1 = 255
					elseif y > 3 then
						d[i].name = leaf
						d[i].param1 = 50
					end
				end
			end
		end
	end

	s.yslice_prob = {}
	local th = height-(2*radii.y+1)
	for y = 1,th do
		s.yslice_prob[y] = {ypos=y, prob=200}
	end

	if not string.find(leaf, "jungle") then
		-- leaves at the center
		vmg.generate_leaves(d, height, radii, leaf, 0, 0, 0)
	end

	-- specify a table of limb positions
	if radii.x > 3 and limbs then
		for _, p in pairs(limbs) do
			local i = (p.x+radii.x)*(2*radii.z+1)*height + (p.y+(height-radii.y-1))*(2*radii.z+1) + (p.z+radii.z) + 1
			d[i].name = trunk
			d[i].param1 = 255
			vmg.generate_leaves(d, height, radii, p.x, p.y, p.z)
		end
		-- or just do it randomly
	elseif radii.x > 3 then
		for x = -radii.x,radii.x do
			for y = -radii.y,radii.y do
				for z = -radii.z,radii.z do
					if x^2/(radii.x-3)^2 + y^2/(radii.y-3)^2 + z^2/(radii.z-3)^2 <= 1 then
						--local dist = math.sqrt(x^2 + y^2 + z^2)
						-- if dist < radii.x - 3 then
						if math.random(4) == 1 then
							local i = (x+radii.x)*(2*radii.z+1)*height + (y+(height-radii.y-1))*(2*radii.z+1) + (z+radii.z) + 1

							d[i].name = trunk
							d[i].param1 = 255
							vmg.generate_leaves(d, height, radii, leaf, x, y, z)
						end
					end
				end
			end
		end
	end

	s.data = d

	return s
end

function vmg.generate_leaves(d, height, radii, leaf, x1, y1, z1)
	local air = "air"
	local r1 = 3  -- leaf decay radius

	for x = -r1,r1 do
		for y = -r1,r1 do
			for z = -r1,r1 do
				if x+x1 >= -radii.x and x+x1 <= radii.x and y+y1 >= -radii.y and y+y1 <= radii.y and z+z1 >= -radii.z and z+z1 <= radii.z then
					local i = (x+x1+radii.x)*(2*radii.z+1)*height + (y+y1+(height-radii.y-1))*(2*radii.z+1) + (z+z1+radii.z) + 1
					local dist1 = math.sqrt(x^2 + y^2 + z^2)
					if dist1 < r1 then
						if d[i].name == air then
							d[i].name = leaf
							d[i].param1 = math.min(255, math.floor(math.random(99) + math.random(99) + 155 * (r1 - dist1) / r1))
						elseif d[i].name == leaf then
							d[i].param1 = math.floor((d[i].param1 + 255) / 2)
						end
					end
				end
			end
		end
	end
end

for i = 1,2 do
	for r = 3,6 do
		minetest.register_decoration({
			deco_type = "schematic",
			place_on = {"default:dirt_with_grass", "default:dirt_with_dry_grass"},
			sidelen = 80,
			fill_ratio = (6-r)/300,
			biomes = {"deciduous_forest",},
			-- y_min = -31000,
			-- y_max = 31000,
			schematic = vmg.generate_tree_schematic(r*3, {x=r, y=r, z=r}, "default:tree", "default:leaves"),
			flags = "place_center_x, place_center_z",
			rotation = "random",
		})
	end
end

for i = 1,2 do
	for r = 6,8 do
		minetest.register_decoration({
			deco_type = "schematic",
			place_on = {"default:dirt_with_grass",},
			sidelen = 80,
			fill_ratio = (9-r)/300,
			biomes = {"rainforest", "rainforest_swamp",},
			-- y_min = -31000,
			-- y_max = 31000,
			schematic = vmg.generate_tree_schematic(r*3, {x=r, y=math.ceil(r/4), z=r}, "default:jungletree", "default:jungleleaves"),
			flags = "place_center_x, place_center_z",
			rotation = "random",
		})
	end
end

local function register_grass_decoration(offset, scale, length)
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"default:dirt_with_grass", "default:sand"},
		sidelen = 16,
		noise_params = {
			offset = offset,
			scale = scale,
			spread = {x=200, y=200, z=200},
			seed = 329,
			octaves = 3,
			persist = 0.6
		},
		biomes = {
			"stone_grassland", "stone_grassland_ocean",
			"sandstone_grassland", "sandstone_grassland_ocean",
			"deciduous_forest", "deciduous_forest_ocean",
			"coniferous_forest", "coniferous_forest_ocean",
		},
		y_min = 5,
		y_max = 31000,
		decoration = "default:grass_"..length,
	})
end

local function register_dry_grass_decoration(offset, scale, length)
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"default:dirt_with_dry_grass"},
		sidelen = 16,
		noise_params = {
			offset = offset,
			scale = scale,
			spread = {x=200, y=200, z=200},
			seed = 329,
			octaves = 3,
			persist = 0.6
		},
		biomes = {"savanna"},
		y_min = 5,
		y_max = 31000,
		decoration = "default:dry_grass_"..length,
	})
end

if true then
	if false then
		-- Apple tree

		minetest.register_decoration({
			deco_type = "schematic",
			place_on = {"default:dirt_with_grass"},
			sidelen = 16,
			noise_params = {
				offset = 0.04,
				scale = 0.02,
				spread = {x=250, y=250, z=250},
				seed = 2,
				octaves = 3,
				persist = 0.66
			},
			biomes = {"deciduous_forest"},
			y_min = 6,
			y_max = 31000,
			schematic = minetest.get_modpath("default").."/schematics/apple_tree.mts",
			flags = "place_center_x, place_center_z",
		})
	end

	-- Taiga and temperate forest pine tree

	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"default:snowblock", "default:dirt_with_grass"},
		sidelen = 16,
		noise_params = {
			offset = 0.04,
			scale = 0.02,
			spread = {x=250, y=250, z=250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"taiga", "coniferous_forest"},
		y_min = 2,
		y_max = 31000,
		schematic = minetest.get_modpath("default").."/schematics/pine_tree.mts",
		flags = "place_center_x, place_center_z",
	})

	-- Acacia tree

	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"default:dirt_with_dry_grass"},
		sidelen = 80,
		noise_params = {
			offset = 0,
			scale = 0.003,
			spread = {x=250, y=250, z=250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"savanna"},
		y_min = 6,
		y_max = 31000,
		schematic = minetest.get_modpath("default").."/schematics/acacia_tree.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})

	-- Large cactus

	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"default:desert_sand"},
		sidelen = 80,
		noise_params = {
			offset = -0.0005,
			scale = 0.0015,
			spread = {x=200, y=200, z=200},
			seed = 230,
			octaves = 3,
			persist = 0.6
		},
		biomes = {"desert"},
		y_min = 5,
		y_max = 31000,
		schematic = minetest.get_modpath("default").."/schematics/large_cactus.mts",
		flags = "place_center_x",
		rotation = "random",
	})

	-- Cactus

	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"default:desert_sand"},
		sidelen = 80,
		noise_params = {
			offset = -0.0005,
			scale = 0.0015,
			spread = {x=200, y=200, z=200},
			seed = 230,
			octaves = 3,
			persist = 0.6
		},
		biomes = {"desert"},
		y_min = 5,
		y_max = 31000,
		decoration = "default:cactus",
		height = 2,
		height_max = 5,
	})

	-- Papyrus

	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"default:sand"},
		sidelen = 16,
		noise_params = {
			offset = -0.3,
			scale = 0.7,
			spread = {x=200, y=200, z=200},
			seed = 354,
			octaves = 3,
			persist = 0.7
		},
		biomes = {"savanna_ocean", "desert_ocean"},
		y_min = 0,
		y_max = 0,
		schematic = minetest.get_modpath("default").."/schematics/papyrus.mts",
	})

	-- Grasses

	register_grass_decoration(-0.03,  0.09,  5)
	register_grass_decoration(-0.015, 0.075, 4)
	register_grass_decoration(0,      0.06,  3)
	register_grass_decoration(0.015,  0.045, 2)
	register_grass_decoration(0.03,   0.03,  1)

	-- Dry grasses

	register_dry_grass_decoration(0.01, 0.05,  5)
	register_dry_grass_decoration(0.03, 0.03,  4)
	register_dry_grass_decoration(0.05, 0.01,  3)
	register_dry_grass_decoration(0.07, -0.01, 2)
	register_dry_grass_decoration(0.09, -0.03, 1)

	-- Junglegrass

	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"default:dirt_with_grass"},
		sidelen = 80,
		fill_ratio = 0.1,
		biomes = {"rainforest"},
		y_min = 1,
		y_max = 31000,
		decoration = "default:junglegrass",
	})

	-- Dry shrub

	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"default:desert_sand", "default:dirt_with_snow"},
		sidelen = 16,
		noise_params = {
			offset = 0,
			scale = 0.02,
			spread = {x=200, y=200, z=200},
			seed = 329,
			octaves = 3,
			persist = 0.6
		},
		biomes = {"desert", "tundra"},
		y_min = 2,
		y_max = 31000,
		decoration = "default:dry_shrub",
	})
end


--
-- Generate nyan cats
--

-- All mapgens except singlenode

function default.make_nyancat(pos, facedir, length)
	local tailvec = {x = 0, y = 0, z = 0}
	if facedir == 0 then
		tailvec.z = 1
	elseif facedir == 1 then
		tailvec.x = 1
	elseif facedir == 2 then
		tailvec.z = -1
	elseif facedir == 3 then
		tailvec.x = -1
	else
		facedir = 0
		tailvec.z = 1
	end
	local p = {x = pos.x, y = pos.y, z = pos.z}
	minetest.set_node(p, {name = "default:nyancat", param2 = facedir})
	for i = 1, length do
		p.x = p.x + tailvec.x
		p.z = p.z + tailvec.z
		minetest.set_node(p, {name = "default:nyancat_rainbow", param2 = facedir})
	end
end

function default.generate_nyancats(minp, maxp, seed)
	local height_min = -31000
	local height_max = -32
	if maxp.y < height_min or minp.y > height_max then
		return
	end
	local y_min = math.max(minp.y, height_min)
	local y_max = math.min(maxp.y, height_max)
	local volume = (maxp.x - minp.x + 1) * (y_max - y_min + 1) * (maxp.z - minp.z + 1)
	local pr = PseudoRandom(seed + 9324342)
	local max_num_nyancats = math.floor(volume / (16 * 16 * 16))
	for i = 1, max_num_nyancats do
		if pr:next(0, 1000) == 0 then
			local x0 = pr:next(minp.x, maxp.x)
			local y0 = pr:next(minp.y, maxp.y)
			local z0 = pr:next(minp.z, maxp.z)
			local p0 = {x = x0, y = y0, z = z0}
			default.make_nyancat(p0, pr:next(0, 3), pr:next(3, 15))
		end
	end
end

