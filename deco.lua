
-- clone node from moretrees

function vmg.clone_node(name)
	local node2 = {}
	local node = minetest.registered_nodes[name]
	for k,v in pairs(node) do
		node2[k]=v
	end
	return node2
end

-- Change leafdecay ratings
minetest.add_group("default:leaves", {leafdecay = 4})
minetest.add_group("default:jungleleaves", {leafdecay = 7})
minetest.add_group("default:pine_needles", {leafdecay = 6})

local decos = {}
for id, deco_table in pairs(minetest.registered_decorations) do
	if not deco_table.schematic or not (deco_table.schematic:find('apple_tree') or deco_table.schematic:find('pine_tree') or deco_table.schematic:find('jungle_tree')) then
		table.insert(decos, deco_table)
	end
end

minetest.clear_registered_decorations()

for _, i in pairs(decos) do
	minetest.register_decoration(i)
end

local newnode = vmg.clone_node("default:leaves")
newnode.tiles = {"default_leaves.png^[colorize:#FF0000:20"}
minetest.register_node("valleys_mapgen:leaves2", newnode)
newnode.tiles = {"default_leaves.png^[colorize:#FFFF00:20"}
minetest.register_node("valleys_mapgen:leaves3", newnode)
newnode.tiles = {"default_leaves.png^[colorize:#00FFFF:20"}
minetest.register_node("valleys_mapgen:leaves4", newnode)
newnode.tiles = {"default_leaves.png^[colorize:#00FF00:20"}
minetest.register_node("valleys_mapgen:leaves5", newnode)

newnode = vmg.clone_node("default:pine_needles")
newnode.tiles = {"default_pine_needles.png^[colorize:#FF0000:20"}
minetest.register_node("valleys_mapgen:pine_needles2", newnode)
newnode.tiles = {"default_pine_needles^[colorize:#FFFF00:20"}
minetest.register_node("valleys_mapgen:pine_needles3", newnode)
newnode.tiles = {"default_pine_needles^[colorize:#00FF00:20"}
minetest.register_node("valleys_mapgen:pine_needles4", newnode)

newnode = vmg.clone_node("default:jungleleaves")
newnode.tiles = {"default_jungleleaves.png^[colorize:#FF0000:10"}
minetest.register_node("valleys_mapgen:jungleleaves2", newnode)
newnode.tiles = {"default_jungleleaves^[colorize:#FFFF00:40"}
minetest.register_node("valleys_mapgen:jungleleaves3", newnode)

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
	local is_jungle = string.find(leaf, "jungle")
	local width = 2 * radii.z + 1
	local trunk_top = height-radii.y-1
	local trunk_bottom = height-2*radii.y

	if height <= width then
		return
	end

	local s = {size={x=width, y=height, z=width}}

	-- clear the array
	for x = 0,width-1 do
		for y = 0,height-1 do
			for z = 0,width-1 do
				local i = x*width*height + y*width + z + 1
				d[i] = {}
				d[i].name = a
				d[i].param1 = 000
			end
		end
	end

	-- the main trunk
	for y = 0,trunk_top do
		local i = (0+radii.x)*width*height + y*width + (0+radii.z) + 1
		d[i].name = trunk
		d[i].param1 = 255
	end

	-- jungle roots and extra leaves
	if is_jungle then
		for x = -1,1 do
			for y = 0,trunk_top do
				for z = -1,1 do
					local i = (x+radii.x)*width*height + y*width + (z+radii.z) + 1
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
	for y = 1,trunk_bottom do
		s.yslice_prob[y] = {ypos=y, prob=200}
	end

	-- Some leaves for free.
	vmg.generate_leaves(d, height, radii, leaf, 0, 0, 0)

	-- specify a table of limb positions
	if radii.x > 3 and limbs then
		for _, p in pairs(limbs) do
			local i = (p.x+radii.x)*width*height + (p.y+(height-radii.y-1))*width + (p.z+radii.z) + 1
			d[i].name = trunk
			d[i].param1 = 255
			vmg.generate_leaves(d, height, radii, p.x, p.y, p.z, true)
		end
		-- or just do it randomly
	elseif radii.x > 3 then
		for x = -radii.x,radii.x do
			for y = -radii.y,radii.y do
				for z = -radii.z,radii.z do
					if x^2/(radii.x-3)^2 + y^2/(radii.y-3)^2 + z^2/(radii.z-3)^2 <= 1 then
						local dist = math.sqrt(x^2 + y^2 + z^2)
						if dist < radii.x - 3 and math.random(4) == 1 then
							local i = (x+radii.x)*width*height + (y+(height-radii.y-1))*width + (z+radii.z) + 1

							d[i].name = trunk
							d[i].param1 = 255
							vmg.generate_leaves(d, height, radii, leaf, x, y, z, true)
						end
					end
				end
			end
		end
	end

	s.data = d

	return s
end

function vmg.generate_fir_schematic(height, radius, trunk, leaf)
	local a = "air"
	local d = {}
	local width = 2 * radius + 1
	local trunk_top = height - 5
	local trunk_bottom = 4

	local s = {size={x=radius*2+1, y=height, z=radius*2+1}}

	-- clear the array
	for x = 0,width-1 do
		for y = 0,height-1 do
			for z = 0,width-1 do
				local i = x*width*height + y*width + z + 1
				d[i] = {}
				d[i].name = a
				d[i].param1 = 000
			end
		end
	end

	-- leaves at the top
	for x = -1,1 do
		for y = height-4, height-1 do
			for z = -1,1 do
				local i = (x+radius)*width*height + y*width + (z+radius) + 1
				if (x == 0 and z == 0) or y < height - 1 then
					d[i].name = leaf
					if x == 0 and z == 0 then
						d[i].param1 = 255
					else
						d[i].param1 = 127
					end
				end
			end
		end
	end

	-- the main trunk
	for y = 0,trunk_top do
		local i = (0+radius)*width*height + y*width + (0+radius) + 1
		d[i].name = trunk
		d[i].param1 = 255
		if y > trunk_bottom then
			vmg.generate_leaves(d, height, {x=radius, y=height, z=radius}, leaf, 0, y, 0)
		end
	end

	s.yslice_prob = {}
	s.yslice_prob[1] = {ypos=1, prob=255}
	s.data = d

	return s
end

function vmg.generate_leaves(d, height, radii, leaf, x1, y1, z1, adjust)
	local air = "air"
	local r1 = 3  -- leaf decay radius
	local probs = {255,255,190,127}

	for x = -r1,r1 do
		for y = -r1,r1 do
			for z = -r1,r1 do
				if x+x1 >= -radii.x and x+x1 <= radii.x and y+y1 >= -radii.y and y+y1 <= radii.y and z+z1 >= -radii.z and z+z1 <= radii.z then
					local i = (x+x1+radii.x)*(2*radii.z+1)*height + (y+y1+(height-radii.y-1))*(2*radii.z+1) + (z+z1+radii.z) + 1
					local dist1 = math.sqrt(x^2 + y^2 + z^2)
					if dist1 < r1 then
						if d[i].name == air then
							d[i].name = leaf
							d[i].param1 = math.max(d[i].param1, probs[math.ceil(dist1)+1])
						elseif adjust and d[i].name == leaf then
							d[i].param1 = math.floor((d[i].param1 + 255) / 2)
						end
					end
				end
			end
		end
	end
end

local leaves = {"default:leaves", "valleys_mapgen:leaves2", "valleys_mapgen:leaves3", "valleys_mapgen:leaves4", "valleys_mapgen:leaves5"}
for i = 1,#leaves do
	for r = 3,6 do
		minetest.register_decoration({
			deco_type = "schematic",
			place_on = {"default:dirt_with_grass", "default:dirt_with_dry_grass"},
			sidelen = 80,
			fill_ratio = (6-r)/300,
			biomes = {"deciduous_forest",},
			-- y_min = -31000,
			-- y_max = 31000,
			schematic = vmg.generate_tree_schematic(r*3, {x=r, y=r, z=r}, "default:tree", leaves[i]),
			flags = "place_center_x, place_center_z",
			rotation = "random",
		})
	end
end

leaves = {"default:jungleleaves", "valleys_mapgen:jungleleaves2", "valleys_mapgen:jungleleaves3"}
for i = 1,#leaves do
	for r = 6,8 do
		minetest.register_decoration({
			deco_type = "schematic",
			place_on = {"default:dirt_with_grass",},
			sidelen = 80,
			fill_ratio = (9-r)/500,
			biomes = {"rainforest", "rainforest_swamp",},
			-- y_min = -31000,
			-- y_max = 31000,
			schematic = vmg.generate_tree_schematic(r*3, {x=r, y=math.ceil(r/4), z=r}, "default:jungletree", leaves[i]),
			flags = "place_center_x, place_center_z",
			rotation = "random",
		})
	end
end

leaves = {"default:pine_needles", "valleys_mapgen:pine_needles2", "valleys_mapgen:pine_needles3", "valleys_mapgen:pine_needles4"}
for i = 1,#leaves do
	for r = 2,4 do
		minetest.register_decoration({
			deco_type = "schematic",
			place_on = {"default:dirt_with_grass",},
			sidelen = 80,
			fill_ratio = (9-r)/1000,
			biomes = {"coniferous_forest",},
			-- y_min = -31000,
			-- y_max = 31000,
			schematic = vmg.generate_fir_schematic(math.ceil(r*3), r, "default:pine_tree", leaves[i]),
			flags = "place_center_x, place_center_z",
			rotation = "random",
		})
	end
end

