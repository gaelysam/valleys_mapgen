
-- clone node from moretrees

function vmg.clone_node(name)
	local node2 = {}
	local node = minetest.registered_nodes[name]
	for k,v in pairs(node) do
		node2[k]=v
	end
	return node2
end

function math.round(i)
	return math.floor(i + 0.5)
end

-- Change leafdecay ratings
minetest.add_group("default:leaves", {leafdecay = 4})
minetest.add_group("default:jungleleaves", {leafdecay = 4})
minetest.add_group("default:pine_needles", {leafdecay = 5})

-- Copy all the decorations except the ones I don't like.
local decos = {}
for id, deco_table in pairs(minetest.registered_decorations) do
	if not deco_table.schematic or not (deco_table.schematic:find('apple_tree') or deco_table.schematic:find('pine_tree') or deco_table.schematic:find('jungle_tree')) then
		table.insert(decos, deco_table)
	end
end

-- Clear everything.
minetest.clear_registered_decorations()

-- Make some leaves of different colors (but the same properties).
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

-- Flower: Bird of Paradise
minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt", "default:dirt_with_grass"},
	sidelen = 80,
	fill_ratio = 0.02,
	decoration = {"valleys_mapgen_c:bird_of_paradise",},
	biomes = {"rainforest", "rainforest_swamp",},
})

-- Flower: Orchid - would be fun to put these in the treetops too.
minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt", "default:dirt_with_grass", "default:jungleleaves"},
	sidelen = 80,
	fill_ratio = 0.02,
	decoration = {"valleys_mapgen_c:orchid",},
	biomes = {"rainforest", "rainforest_swamp",},
})

-- Flower: Hibiscus
local v2 = {offset = 0, scale = 0.005, seed = -6050, spread = {x = 256, y = 256, z = 256}, octaves = 5, persist = 0.6, lacunarity = 2}
minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass"},
	sidelen = 80,
	noise_params = v2,
	decoration = {"valleys_mapgen_c:hibiscus",},
	biomes = {"sandstone_grassland", "stone_grassland", "coniferous_forest", "deciduous_forest", "rainforest",},
	y_max = 60,
})


-- Create and initialize a table for a schematic.
function vmg.schematic_array(width, height, depth)
	-- Dimensions of data array.
	local s = {size={x=width, y=height, z=depth}}
	s.data = {}

	for x = 0,width-1 do
		for y = 0,height-1 do
			for z = 0,depth-1 do
				local i = x*width*height + y*width + z + 1
				s.data[i] = {}
				s.data[i].name = "air"
				s.data[i].param1 = 000
			end
		end
	end

	s.yslice_prob = {}

	return s
end

-- Create a schematic for a spherical tree.
function vmg.generate_tree_schematic(height, radii, trunk, leaf, fruit, limbs)
	local width = 2 * radii.z + 1
	local trunk_top = height-radii.y-1
	local trunk_bottom = height-2*radii.y

	-- This wouldn't work.
	if height <= width then
		return
	end

	local s = vmg.schematic_array(width, height, width)

	-- the main trunk
	for y = 0,trunk_top do
		local i = radii.x*width*height + y*width + radii.z + 1
		s.data[i].name = trunk
		s.data[i].param1 = 255
	end

	-- some leaves for free
	vmg.generate_leaves(s, leaf, {x=0, y=trunk_top, z=0}, radii.x, fruit)

	-- Specify a table of limb positions...
	if radii.x > 3 and limbs then
		for _, p in pairs(limbs) do
			local i = (p.x+radii.x)*width*height + p.y*width + (p.z+radii.z) + 1
			s.data[i].name = trunk
			s.data[i].param1 = 255
			vmg.generate_leaves(s, leaf, p, radii.x, fruit, true)
		end
		-- or just do it randomly.
	elseif radii.x > 3 then
		for x = -radii.x,radii.x do
			for y = -radii.y,radii.y do
				for z = -radii.z,radii.z do
					-- a smaller spheroid inside the radii
					if x^2/(radii.x-3)^2 + y^2/(radii.y-3)^2 + z^2/(radii.z-3)^2 <= 1 then
						if math.random(6) == 1 then
							local i = (x+radii.x)*width*height + (y+trunk_top)*width + (z+radii.z) + 1

							s.data[i].name = trunk
							s.data[i].param1 = 255
							vmg.generate_leaves(s, leaf, {x=x, y=trunk_top+y, z=z}, radii.x, fruit, true)
						end
					end
				end
			end
		end
	end

	return s
end

-- Create a spheroid of leaves.
function vmg.generate_leaves(s, leaf, pos, radius, fruit, adjust)
	local height = s.size.y
	local width = s.size.x
	local rx = math.floor(s.size.x / 2)
	local rz = math.floor(s.size.z / 2)
	local r1 = math.min(3, radius)  -- leaf decay radius
	local probs = {255,200,150,100,75}

	for x = -r1,r1 do
		for y = -r1,r1 do
			for z = -r1,r1 do
				if x+pos.x >= -rx and x+pos.x <= rx and y+pos.y >= 0 and y+pos.y < height and z+pos.z >= -rz and z+pos.z <= rz then
					local i = (x+pos.x+rx)*width*height + (y+pos.y)*width + (z+pos.z+rz) + 1
					local dist1 = math.sqrt(x^2 + y^2 + z^2)
					local dist2 = math.sqrt((x+pos.x)^2 + (z+pos.z)^2)
					if dist1 <= r1 then
						local newprob = probs[math.max(1, math.ceil(dist1))]
						if s.data[i].name == "air" then
							if fruit and (rx < 3 or dist2 / rx > 0.5) and math.random(10) == 1 then
								s.data[i].name = fruit
								s.data[i].param1 = 127
							else
								s.data[i].name = leaf
								s.data[i].param1 = newprob
							end
						elseif adjust and s.data[i].name == leaf then
							s.data[i].param1 = math.max(s.data[i].param1, newprob)
						end
					end
				end
			end
		end
	end
end

-- Create a schematic for a jungle tree.
function vmg.generate_jungle_tree_schematic(height, trunk, leaf)
	local radius = 6
	local width = 2 * radius + 1
	local trunk_top = height - 4
	local trunk_bottom = math.floor(height / 2)

	local s = vmg.schematic_array(width, height, width)

	-- roots, trunk, and extra leaves
	for x = -1,1 do
		for y = 0,trunk_top do
			for z = -1,1 do
				i = (x+radius)*width*height + y*width + (z+radius) + 1
				if x == 0 and z == 0 then
					s.data[i].name = trunk
					s.data[i].param1 = 255
				elseif (x == 0 or z == 0) and y < 3 then
					s.data[i].name = trunk
					s.data[i].param1 = 255
				elseif y > 3 then
					s.data[i].name = leaf
					s.data[i].param1 = 50
				end
			end
		end
	end

	-- canopies
	for y = 0,trunk_top+2 do
		if y > trunk_bottom and (y == trunk_top or math.random(height - y) == 1) then
			local x, z = 0, 0
			while x == 0 and z == 0 do
				x = math.random(-1,1) * 2
				z = math.random(-1,1) * 2
			end
			for j = -1,1,2 do
				local i = (j*x + radius)*width*height + y*width + (j*z + radius) + 1
				s.data[i].name = trunk
				s.data[i].param1 = 255
				vmg.generate_canopy(s, leaf, {x=j*x, y=y, z=j*z})
			end
		end
	end

	return s
end

-- Create a canopy of leaves.
function vmg.generate_canopy(s, leaf, pos)
	local height = s.size.y
	local width = s.size.x
	local rx = math.floor(s.size.x / 2)
	local rz = math.floor(s.size.z / 2)
	local r1 = 4  -- leaf decay radius
	local probs = {255,200,150,100,75}

	for x = -r1,r1 do
		for y = 0,1 do
			for z = -r1,r1 do
				if x+pos.x >= -rx and x+pos.x <= rx and y+pos.y >= 0 and y+pos.y < height and z+pos.z >= -rz and z+pos.z <= rz then
					local i = (x+pos.x+rx)*width*height + (y+pos.y)*width + (z+pos.z+rz) + 1
					local dist1 = math.sqrt(x^2 + y^2 + z^2)
					local dist2 = math.sqrt((x+pos.x)^2 + (z+pos.z)^2)
					if dist1 <= r1 then
						local newprob = probs[math.max(1, math.ceil(dist1))]
						if s.data[i].name == "air" then
							s.data[i].name = leaf
							s.data[i].param1 = newprob
						elseif s.data[i].name == leaf then
							s.data[i].param1 = math.max(s.data[i].param1, newprob)
						end
					end
				end
			end
		end
	end
end

-- similar to the general tree schematic, but basically vertical
function vmg.generate_conifer_schematic(height, radius, trunk, leaf)
	local width = 2 * radius + 1
	local trunk_top = height - radius - 1
	local trunk_bottom = math.min(radius, 3)
	local s = vmg.schematic_array(width, height, width)

	-- the main trunk
	local probs = {200,150,100,75,50,25}
	for x = -radius,radius do
		for y = 0,trunk_top do
			-- Gives it a vaguely conical shape.
			local r1 = math.ceil((height - y) / 4)
			-- But rounded at the bottom.
			if y == trunk_bottom + 1 then
				r1 = r1 -1 
			end

			for z = -radius,radius do
				local i = (x+radius)*width*height + y*width + (z+radius) + 1
				local dist = math.round(math.sqrt(x^2 + z^2))
				if x == 0 and z == 0 then
					s.data[i].name = trunk
					s.data[i].param1 = 255
				elseif y > trunk_bottom and dist <= r1 then
					s.data[i].name = leaf
					s.data[i].param1 = probs[dist]
				end
			end
		end
	end

	-- leaves at the top
	for x = -1,1 do
		for y = trunk_top, height-1 do
			for z = -1,1 do
				local i = (x+radius)*width*height + y*width + (z+radius) + 1
				if (x == 0 and z == 0) or y < height - 1 then
					s.data[i].name = leaf
					if x == 0 and z == 0 then
						s.data[i].param1 = 255
					else
						s.data[i].param1 = 200
					end
				end
			end
		end
	end

	return s
end

-- A shock of leaves at the top and some fruit.
function vmg.generate_banana_schematic(height)
	height = height + 1
	local radius = 1
	local width = 3
	local trunk_top = height - 2
	local s = vmg.schematic_array(width, height, width)

	-- the main trunk
	for y = 0,trunk_top do
		local i = (0+radius)*width*height + y*width + (0+radius) + 1
		s.data[i].name = "valleys_mapgen:banana_tree"
		s.data[i].param1 = 255
	end

	-- leaves at the top
	for x = -1,1 do
		for y = trunk_top, height-1 do
			for z = -1,1 do
				local i = (x+radius)*width*height + y*width + (z+radius) + 1
				if y > height - 2 then
					s.data[i].name = "valleys_mapgen:banana_leaves"
					if x == 0 and z == 0 then
						s.data[i].param1 = 255
					else
						s.data[i].param1 = 127
					end
				elseif x ~= 0 or z ~= 0 then
					s.data[i].name = "valleys_mapgen:banana"
					s.data[i].param1 = 75
				end
			end
		end
	end

	return s
end


local function push(t, x)
	t[#t+1] = x
end

vmg.schematics = {}

-- generic deciduous trees
vmg.schematics.deciduous_trees = {}
local leaves = {"default:leaves", "valleys_mapgen:leaves2", "valleys_mapgen:leaves3", "valleys_mapgen:leaves4", "valleys_mapgen:leaves5"}
for i = 1,#leaves do
	local max_r = 6
	local fruit = nil

	if i == 1 then
		fruit = "default:apple"
	end

	for r = 3,max_r do
		local schem = vmg.generate_tree_schematic(r*3, {x=r, y=r, z=r}, "default:tree", leaves[i], fruit)

		push(vmg.schematics.deciduous_trees, schem)

		minetest.register_decoration({
			deco_type = "schematic",
			sidelen = 80,
			place_on = {"default:dirt_with_grass", "default:dirt_with_dry_grass"},
			fill_ratio = (max_r-r+1)/1500,
			biomes = {"deciduous_forest",},
			schematic = schem,
			flags = "place_center_x, place_center_z",
			rotation = "random",
		})
	end
end

-- Place the schematic when a sapling grows.
function default.grow_new_apple_tree(pos, bad)
	local schem = vmg.schematics.deciduous_trees[math.random(1,#vmg.schematics.deciduous_trees)]
	local adj = {x = pos.x - math.floor(schem.size.x / 2),
	             y = pos.y - 1,
	             z = pos.z - math.floor(schem.size.z / 2)}
	minetest.place_schematic(adj, schem, 'random', nil, true)
end

-- generic jungle trees
vmg.schematics.jungle_trees = {}
leaves = {"default:jungleleaves", "valleys_mapgen:jungleleaves2", "valleys_mapgen:jungleleaves3"}
for i = 1,#leaves do
	local max_h = 8
	for h = 6,max_h do
		local schem = vmg.generate_jungle_tree_schematic(h*3, "default:jungletree", leaves[i])

		push(vmg.schematics.jungle_trees, schem)

		minetest.register_decoration({
			deco_type = "schematic",
			sidelen = 80,
			place_on = {"default:dirt_with_grass",},
			fill_ratio = (max_h-h+1)/1000,
			biomes = {"rainforest", "rainforest_swamp",},
			schematic = schem,
			flags = "place_center_x, place_center_z",
			rotation = "random",
		})
	end
end

-- Place the schematic when a sapling grows.
function default.grow_new_jungle_tree(pos, bad)
	local schem = vmg.schematics.jungle_trees[math.random(1,#vmg.schematics.jungle_trees)]
	local adj = {x = pos.x - math.floor(schem.size.x / 2),
	             y = pos.y - 1,
	             z = pos.z - math.floor(schem.size.z / 2)}
	minetest.place_schematic(adj, schem, 'random', nil, true)
end

-- generic conifers
vmg.schematics.conifer_trees = {}
leaves = {"default:pine_needles", "valleys_mapgen:pine_needles2", "valleys_mapgen:pine_needles3", "valleys_mapgen:pine_needles4"}
for i = 1,#leaves do
	local max_r = 4
	for r = 2,max_r do
		local schem = vmg.generate_conifer_schematic(math.ceil(r*4), r, "default:pine_tree", leaves[i])

		push(vmg.schematics.conifer_trees, schem)

		minetest.register_decoration({
			deco_type = "schematic",
			sidelen = 80,
			place_on = {"default:dirt_with_grass",},
			fill_ratio = (max_r-r+1)/500,
			biomes = {"coniferous_forest",},
			schematic = schem,
			flags = "place_center_x, place_center_z",
			rotation = "random",
		})
	end
end

-- Place the schematic when a sapling grows.
function default.grow_new_pine_tree(pos, bad)
	local schem = vmg.schematics.conifer_trees[math.random(1,#vmg.schematics.conifer_trees)]
	local adj = {x = pos.x - math.floor(schem.size.x / 2),
	             y = pos.y - 1,
	             z = pos.z - math.floor(schem.size.z / 2)}
	minetest.place_schematic(adj, schem, 'random', nil, true)
end

-- banana plant (It's not a tree.)
vmg.schematics.banana_plants = {}
do
	local max_h = 6
	for h = 4,max_h do
		local schem = vmg.generate_banana_schematic(h)

		push(vmg.schematics.banana_plants, schem)

		minetest.register_decoration({
			deco_type = "schematic",
			sidelen = 80,
			place_on = {"default:dirt_with_grass",},
			fill_ratio = (max_h-h+1)/5000,
			biomes = {"rainforest",},
			schematic = schem,
			flags = "place_center_x, place_center_z",
			rotation = "random",
		})
	end
end

-- Cherries work with the generic generator.
vmg.schematics.cherry_trees = {}
do
	local max_h = 6
	local fruit = nil

	for h = 4,max_h do
		local schem = vmg.generate_tree_schematic(h, {x=2, y=2, z=2}, "valleys_mapgen:cherry_blossom_tree", "valleys_mapgen:cherry_blossom_leaves", fruit)

		push(vmg.schematics.cherry_trees, schem)

		minetest.register_decoration({
			deco_type = "schematic",
			sidelen = 80,
			place_on = {"default:dirt_with_grass", "default:dirt_with_dry_grass"},
			fill_ratio = (max_h-h+1)/10000,
			biomes = {"deciduous_forest",},
			schematic = schem,
			flags = "place_center_x, place_center_z",
			rotation = "random",
		})
	end
end

-- list of all vmg-specific saplings
vmg.saplings = {
	{sapling="valleys_mapgen:banana_sapling",
	 schematics=vmg.schematics.banana_plants},
	{sapling="valleys_mapgen:cherry_blossom_sapling",
	 schematics=vmg.schematics.cherry_trees},
 }
-- create a list of just the node names
local sapling_list = {}
for _, sap in pairs(vmg.saplings) do
	push(sapling_list, sap.sapling)
end

-- This abm can handle all saplings.
minetest.register_abm({
	nodenames = sapling_list,
	interval = 10,
	chance = 50,
	action = function(pos, node)
		local node_under = minetest.get_node_or_nil({x = pos.x, y = pos.y - 1, z = pos.z})
		if not node_under or
		minetest.get_item_group(node_under.name, "soil") == 0 then
			return
		end

		for _, sap in vmg.saplings do
			if node.name == sap.sapling then
				minetest.log("action", "A sapling grows into a tree at "..
					minetest.pos_to_string(pos))

				local schem = sap.schematics[math.random(1,#sap.schematics)]
				local adj = {x = pos.x - math.floor(schem.size.x / 2),
										 y = pos.y - 1,
										 z = pos.z - math.floor(schem.size.z / 2)}
				minetest.place_schematic(adj, schem, 'random', nil, true)
				break
			end
		end
	end,
})


do
	local default_grid
	local tiles = {"default_stone.png", "default_desert_stone.png", "default_sandstone.png"}

	for grid_count = 1,20 do
		local grid = {}
		for rock_count = 1, math.random(6) do
			local rock = {}
			local diameter = math.random(5,15)/100
			local x = math.random(80)/100 - 0.5
			local z = math.random(80)/100 - 0.5
			rock[1] = x
			rock[2] = -0.5
			rock[3] = z
			rock[4] = x + diameter
			rock[5] = diameter - 0.5
			rock[6] = z + diameter
			push(grid, rock)
		end

		local stone = tiles[math.random(#tiles)]

		minetest.register_node("valleys_mapgen:small_rocks"..grid_count, {
			description = "Small Rocks",
			tiles = {stone},
			is_ground_content = true,
			walkable = false,
			paramtype = "light",
			drawtype = "nodebox",
			node_box = { type = "fixed", 
			             fixed = grid },
			selection_box = { type = "fixed", 
			                  fixed = {-0.5,-0.5,-0.5,0.5,-0.4,0.5} },
			groups = {stone=1, oddly_breakable_by_hand=3},
			drop = "valleys_mapgen:small_rocks",
			sounds = default.node_sound_stone_defaults(),
		})

		minetest.register_decoration({
			deco_type = "simple",
			decoration = "valleys_mapgen:small_rocks"..grid_count,
			sidelen = 80,
			place_on = {"default:dirt_with_grass", "default:dirt_with_dry_grass",},
			fill_ratio = 0.002,
			biomes = {"sandstone_grassland", "tundra", "taiga", "stone_grassland", "coniferous_forest", "deciduous_forest", "desert", "savanna", "rainforest",},
			flags = "place_center_x, place_center_z",
			rotation = "random",
		})

		default_grid = grid
	end

	minetest.register_node("valleys_mapgen:small_rocks", {
		description = "Small Rocks",
		tiles = {"default_stone.png"},
		is_ground_content = true,
		walkable = false,
		paramtype = "light",
		drawtype = "nodebox",
		node_box = { type = "fixed", 
								 fixed = default_grid },
		selection_box = { type = "fixed", 
											fixed = {-0.4,-0.5,-0.4,0.4,-0.4,0.4} },
		groups = {stone=1, oddly_breakable_by_hand=3},
		sounds = default.node_sound_stone_defaults(),
	})
end


-- Re-register the good decorations.
-- This has to be done after registering the trees or
--  the trees spawn on top of grass.
for _, i in pairs(decos) do
	minetest.register_decoration(i)
end

