
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

-- Copy all the decorations except the ones we don't like.
local decos = {}
for id, deco_table in pairs(minetest.registered_decorations) do
	if not deco_table.schematic or not (deco_table.schematic:find('apple_tree') or deco_table.schematic:find('pine_tree') or deco_table.schematic:find('jungle_tree')) then
		table.insert(decos, deco_table)
	end
end

-- Clear everything.
minetest.clear_registered_decorations()

-- Re-register the good ones.
for _, i in pairs(decos) do
	minetest.register_decoration(i)
end

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
	-- y_min = -31000,
	-- y_max = 60,
	-- flags = "place_center_x, place_center_z",
	-- rotation = "random",
})

-- Flower: Orchid - would be fun to put these in the treetops too.
minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt", "default:dirt_with_grass", "default:jungleleaves"},
	sidelen = 80,
	fill_ratio = 0.02,
	decoration = {"valleys_mapgen_c:orchid",},
	biomes = {"rainforest", "rainforest_swamp",},
	-- y_min = -31000,
	-- y_max = 60,
	-- flags = "place_center_x, place_center_z",
	-- rotation = "random",
})

-- Flower: Hibiscus
local v2 = {offset = 0, scale = 0.005, seed = -6050, spread = {x = 256, y = 256, z = 256}, octaves = 5, persist = 0.6, lacunarity = 2}
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

-- Create a schematic for a spherical tree.
function vmg.generate_tree_schematic(height, radii, trunk, leaf, limbs)
	local air = "air"
	local d = {}
	local is_jungle = string.find(leaf, "jungle")
	local width = 2 * radii.z + 1
	local trunk_top = height-radii.y-1
	local trunk_bottom = height-2*radii.y

	-- This wouldn't work.
	if height <= width then
		return
	end

	-- Dimensions of data array.
	local s = {size={x=width, y=height, z=width}}

	-- Clear the array.
	for x = 0,width-1 do
		for y = 0,height-1 do
			for z = 0,width-1 do
				local i = x*width*height + y*width + z + 1
				d[i] = {}
				d[i].name = air
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

	-- Allow pieces of the trunk to be removed to vary height.
	s.yslice_prob = {}
	for y = 1,trunk_bottom do
		s.yslice_prob[y] = {ypos=y, prob=200}
	end

	-- some leaves for free
	vmg.generate_leaves(d, height, radii, leaf, 0, 0, 0)

	-- Specify a table of limb positions...
	if radii.x > 3 and limbs then
		for _, p in pairs(limbs) do
			local i = (p.x+radii.x)*width*height + (p.y+(height-radii.y-1))*width + (p.z+radii.z) + 1
			d[i].name = trunk
			d[i].param1 = 255
			vmg.generate_leaves(d, height, radii, p.x, p.y, p.z, true)
		end
		-- or just do it randomly.
	elseif radii.x > 3 then
		for x = -radii.x,radii.x do
			for y = -radii.y,radii.y do
				for z = -radii.z,radii.z do
					-- a smaller spheroid inside the radii
					if x^2/(radii.x-3)^2 + y^2/(radii.y-3)^2 + z^2/(radii.z-3)^2 <= 1 then
						if math.random(6) == 1 then
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

-- Create a blob of leaves.
function vmg.generate_leaves(d, height, radii, leaf, x1, y1, z1, adjust)
	local air = "air"
	local r1 = 3  -- leaf decay radius
	local probs = {255,200,150,100,75}
	local width = 2 * radii.z + 1

	for x = -r1,r1 do
		for y = -r1,r1 do
			for z = -r1,r1 do
				if x+x1 >= -radii.x and x+x1 <= radii.x and y+y1 >= -radii.y and y+y1 <= radii.y and z+z1 >= -radii.z and z+z1 <= radii.z then
					local i = (x+x1+radii.x)*width*height + (y+y1+(height-radii.y-1))*width + (z+z1+radii.z) + 1
					local dist1 = math.sqrt(x^2 + y^2 + z^2)
					if dist1 <= r1 then
						local newprob = probs[math.max(1, math.ceil(dist1))]
						if d[i].name == air then
							d[i].name = leaf
							d[i].param1 = newprob
						elseif adjust and d[i].name == leaf then
							d[i].param1 = math.max(d[i].param1, newprob)
						end
					end
				end
			end
		end
	end
end

-- similar to the general tree schematic, but basically vertical
function vmg.generate_conifer_schematic(height, radius, trunk, leaf)
	local air = "air"
	local d = {}
	local width = 2 * radius + 1
	local trunk_top = height - radius - 1
	local trunk_bottom = math.min(radius, 3)

	local s = {size={x=radius*2+1, y=height, z=radius*2+1}}

	-- clear the array
	for x = 0,width-1 do
		for y = 0,height-1 do
			for z = 0,width-1 do
				local i = x*width*height + y*width + z + 1
				d[i] = {}
				d[i].name = air
				d[i].param1 = 000
			end
		end
	end

	-- the main trunk
	local probs = {200,150,100,75,50,25}
	for x = -radius,radius do
		for y = 0,trunk_top do
			local r1 = math.ceil((height - y) / 4)
			if y == trunk_bottom + 1 then
				r1 = r1 -1 
			end
			for z = -radius,radius do
				local i = (x+radius)*width*height + y*width + (z+radius) + 1
				local dist = math.round(math.sqrt(x^2 + z^2))
				if x == 0 and z == 0 then
					d[i].name = trunk
					d[i].param1 = 255
				elseif y > trunk_bottom and dist <= r1 then
					d[i].name = leaf
					d[i].param1 = probs[dist]
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
					d[i].name = leaf
					if x == 0 and z == 0 then
						d[i].param1 = 255
					else
						d[i].param1 = 200
					end
				end
			end
		end
	end

	-- only one yslice
	s.yslice_prob = {}
	s.yslice_prob[1] = {ypos=1, prob=255}
	s.data = d

	return s
end

-- deciduous trees
local leaves = {"default:leaves", "valleys_mapgen:leaves2", "valleys_mapgen:leaves3", "valleys_mapgen:leaves4", "valleys_mapgen:leaves5"}
for i = 1,#leaves do
	local max_r = 6
	for r = 3,max_r do
		minetest.register_decoration({
			deco_type = "schematic",
			place_on = {"default:dirt_with_grass", "default:dirt_with_dry_grass"},
			sidelen = 80,
			fill_ratio = (max_r-r+1)/1500,
			biomes = {"deciduous_forest",},
			-- y_min = -31000,
			-- y_max = 31000,
			schematic = vmg.generate_tree_schematic(r*3, {x=r, y=r, z=r}, "default:tree", leaves[i]),
			flags = "place_center_x, place_center_z",
			rotation = "random",
		})
	end
end

-- jungle trees
leaves = {"default:jungleleaves", "valleys_mapgen:jungleleaves2", "valleys_mapgen:jungleleaves3"}
for i = 1,#leaves do
	local max_r = 8
	for r = 6,max_r do
		minetest.register_decoration({
			deco_type = "schematic",
			place_on = {"default:dirt_with_grass",},
			sidelen = 80,
			fill_ratio = (max_r-r+1)/750,
			biomes = {"rainforest", "rainforest_swamp",},
			-- y_min = -31000,
			-- y_max = 31000,
			schematic = vmg.generate_tree_schematic(r*3, {x=r, y=math.ceil(r/4), z=r}, "default:jungletree", leaves[i]),
			flags = "place_center_x, place_center_z",
			rotation = "random",
		})
	end
end

-- conifers
leaves = {"default:pine_needles", "valleys_mapgen:pine_needles2", "valleys_mapgen:pine_needles3", "valleys_mapgen:pine_needles4"}
for i = 1,#leaves do
	local max_r = 4
	for r = 2,max_r do
		minetest.register_decoration({
			deco_type = "schematic",
			place_on = {"default:dirt_with_grass",},
			sidelen = 80,
			fill_ratio = (max_r-r+1)/500,
			biomes = {"coniferous_forest",},
			-- y_min = -31000,
			-- y_max = 31000,
			schematic = vmg.generate_conifer_schematic(math.ceil(r*4), r, "default:pine_tree", leaves[i]),
			flags = "place_center_x, place_center_z",
			rotation = "random",
		})
	end
end

