local function can_grow(pos) -- from default mod
	local node_under = minetest.get_node_or_nil({x = pos.x, y = pos.y - 1, z = pos.z})
	if not node_under then
		return false
	end
	local name_under = node_under.name
	local is_soil = minetest.get_item_group(name_under, "soil")
	if is_soil == 0 then
		return false
	end
	return true
end

-- Fir sapling growth
minetest.register_abm({
	nodenames = {"valleys_mapgen:fir_sapling"},
	interval = 14,
	chance = 50,
	action = function(pos, node)
		if not can_grow(pos) then
			return
		end

		minetest.log("action", "A fir sapling grows into a tree at "..
				minetest.pos_to_string(pos))
		vmg.grow_fir_tree(pos)
	end
})

-- Banana sapling growth
minetest.register_abm({
	nodenames = {"valleys_mapgen:banana_sapling"},
	interval = 10,
	chance = 50,
	action = function(pos, node)
		if not can_grow(pos) then
			return
		end

		minetest.log("action", "A banana sapling grows into a tree at "..
				minetest.pos_to_string(pos))
		vmg.grow_banana_tree(pos)
	end
})

-- Birch sapling growth
minetest.register_abm({
	nodenames = {"valleys_mapgen:birch_sapling"},
	interval = 20,
	chance = 50,
	action = function(pos, node)
		if not can_grow(pos) then
			return
		end

		minetest.log("action", "A birch sapling grows into a tree at "..
				minetest.pos_to_string(pos))
		vmg.grow_birch_tree(pos)
	end
})

-- Cherry Blossom sapling growth
minetest.register_abm({
	nodenames = {"valleys_mapgen:cherry_blossom_sapling"},
	interval = 20,
	chance = 50,
	action = function(pos, node)
		if not can_grow(pos) then
			return
		end

		minetest.log("action", "A cherry blossom sapling grows into a tree at "..
				minetest.pos_to_string(pos))
		vmg.grow_cherry_blossom_tree(pos)
	end
})

-- Mangrove sapling growth
minetest.register_abm({
	nodenames = {"valleys_mapgen:mangrove_sapling"},
	interval = 20,
	chance = 50,
	action = function(pos, node)
		if not can_grow(pos) then
			return
		end

		minetest.log("action", "A mangrove sapling grows into a tree at "..
				minetest.pos_to_string(pos))
		vmg.grow_mangrove_tree(pos)
	end
})

-- Willow sapling growth
minetest.register_abm({
	nodenames = {"valleys_mapgen:willow_sapling"},
	interval = 20,
	chance = 50,
	action = function(pos, node)
		if not can_grow(pos) then
			return
		end

		minetest.log("action", "A willow sapling grows into a tree at "..
				minetest.pos_to_string(pos))
		vmg.grow_willow_tree(pos)
	end
})

local leaf_types = {"default:leaves", "valleys_mapgen:leaves2", "valleys_mapgen:leaves3", "valleys_mapgen:leaves4", "valleys_mapgen:leaves5"}
local leaves_colors = vmg.define("leaves_colors", true)

function default.grow_tree(pos, is_apple_tree) -- Override default function to generate VMG trees
	-- individual parameters
	local rand = math.random()
	local height = math.floor(4 + 2.5 * rand)
	local radius = 3 + rand

	-- VoxelManip stuff
	local leaves = minetest.get_content_id("default:leaves")
	if leaves_colors then
		leaves = minetest.get_content_id(leaf_types[math.random(#leaf_types)])
	end
	local trunk = minetest.get_content_id("default:tree")
	local air = minetest.get_content_id("air")
	local ignore = minetest.get_content_id("ignore")
	local vm = minetest.get_voxel_manip()
	local emin, emax = vm:read_from_map({x = pos.x - 4, y = pos.y, z = pos.z - 4}, {x = pos.x + 4, y = pos.y + height + 4, z = pos.z + 4})
	local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local data = vm:get_data()
	if is_apple_tree then
		vmg.make_apple_tree(pos, data, area, height, radius, trunk, leaves, minetest.get_content_id("default:apple"), air, ignore)
	else
		vmg.make_tree(pos, data, area, height, radius, trunk, leaves, air, ignore)
	end
	vm:set_data(data)
	vm:write_to_map()
	vm:update_map()
end

function vmg.grow_banana_tree(pos)
	-- individual parameters
	local rand = math.random()
	local height = math.floor(4 + 2.5 * rand)
	local radius = 3 + rand

	-- VoxelManip stuff
	local leaves = minetest.get_content_id("valleys_mapgen:banana_leaves")
	local trunk = minetest.get_content_id("valleys_mapgen:banana_tree")
	local air = minetest.get_content_id("air")
	local ignore = minetest.get_content_id("ignore")
	local vm = minetest.get_voxel_manip()
	local emin, emax = vm:read_from_map({x = pos.x - 4, y = pos.y, z = pos.z - 4}, {x = pos.x + 4, y = pos.y + height + 4, z = pos.z + 4})
	local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local data = vm:get_data()
	vmg.make_banana_tree(pos, data, area, height, radius, trunk, leaves, minetest.get_content_id("valleys_mapgen:banana"), air, ignore)
	vm:set_data(data)
	vm:write_to_map()
	vm:update_map()
end

function vmg.grow_birch(pos)
	local rand = math.random()
	local height = math.floor(6 + 2.5 * rand)
	local radius = 2 + rand

	-- VoxelManip stuff
	local leaves = minetest.get_content_id("valleys_mapgen:birch_leaves")
	local trunk = minetest.get_content_id("valleys_mapgen:birch_tree")
	local air = minetest.get_content_id("air")
	local ignore = minetest.get_content_id("ignore")
	local vm = minetest.get_voxel_manip()
	local emin, emax = vm:read_from_map({x = pos.x - 4, y = pos.y, z = pos.z - 4}, {x = pos.x + 4, y = pos.y + height + 4, z = pos.z + 4})
	local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local data = vm:get_data()
	vmg.make_birch_tree(pos, data, area, height, radius, trunk, leaves, air, ignore)
	vm:set_data(data)
	vm:write_to_map()
	vm:update_map()
end

function vmg.grow_cherry_blossom_tree(pos)
	-- individual parameters
	local rand = math.random()
	local height = math.floor(4 + 2.5 * rand)
	local radius = 3 + rand

	-- VoxelManip stuff
	local leaves = minetest.get_content_id("valleys_mapgen:cherry_blossom_leaves")
	local trunk = minetest.get_content_id("valleys_mapgen:cherry_blossom_tree")
	local air = minetest.get_content_id("air")
	local ignore = minetest.get_content_id("ignore")
	local vm = minetest.get_voxel_manip()
	local emin, emax = vm:read_from_map({x = pos.x - 4, y = pos.y, z = pos.z - 4}, {x = pos.x + 4, y = pos.y + height + 4, z = pos.z + 4})
	local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local data = vm:get_data()
	vmg.make_cherry_blossom_tree(pos, data, area, height, radius, trunk, leaves, air, ignore)
	vm:set_data(data)
	vm:write_to_map()
	vm:update_map()
end

function default.grow_jungle_tree(pos)
	local rand = math.random()
	local height = math.floor(8 + 4 * rand)
	local radius = 5 + 3 * rand

	local leaves = minetest.get_content_id("default:jungleleaves")
	local trunk = minetest.get_content_id("default:jungletree")
	local air = minetest.get_content_id("air")
	local ignore = minetest.get_content_id("ignore")
	local vm = minetest.get_voxel_manip()
	local emin, emax = vm:read_from_map({x = pos.x - 8, y = pos.y - 1, z = pos.z - 8}, {x = pos.x + 8, y = pos.y + height + 5, z = pos.z + 8})
	local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local data = vm:get_data()
	vmg.make_jungle_tree(pos, data, area, height, radius, trunk, leaves, air, ignore)
	vmg.execute_after_mapgen()
	vm:set_data(data)
	vm:write_to_map()
	vm:update_map()
end

function default.grow_mangrove_tree(pos)
	local rand = math.random()
	local height = math.floor(3 + 2 * rand)
	local radius = 3 + 2 * rand

	local leaves = minetest.get_content_id("default:mangrove_leaves")
	local trunk = minetest.get_content_id("default:mangrove_tree")
	local air = minetest.get_content_id("air")
	local ignore = minetest.get_content_id("ignore")
	local vm = minetest.get_voxel_manip()
	local emin, emax = vm:read_from_map({x = pos.x - 2, y = pos.y - 1, z = pos.z - 2}, {x = pos.x + 3, y = pos.y + height + 2, z = pos.z + 3})
	local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local data = vm:get_data()
	vmg.make_mangrove_tree(pos, data, area, height, radius, trunk, leaves, air, ignore)
	vmg.execute_after_mapgen()
	vm:set_data(data)
	vm:write_to_map()
	vm:update_map()
end

function default.grow_pine_tree(pos)
	local rand = math.random()
	local height = math.floor(9 + 6 * rand)
	local radius = 4 + 2 * rand

	local leaves = minetest.get_content_id("default:pine_needles")
	local trunk = minetest.get_content_id("default:pinetree")
	local air = minetest.get_content_id("air")
	local ignore = minetest.get_content_id("ignore")
	local vm = minetest.get_voxel_manip()
	local emin, emax = vm:read_from_map({x = pos.x - 6, y = pos.y - 1, z = pos.z - 6}, {x = pos.x + 6, y = pos.y + height + 2, z = pos.z + 6})
	local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local data = vm:get_data()
	vmg.make_pine_tree(pos, data, area, height, radius, trunk, leaves, air, ignore)
	vm:set_data(data)
	vm:write_to_map()
	vm:update_map()
end

function vmg.grow_fir_tree(pos)
	local rand = math.random()
	local height = math.floor(9 + 6 * rand)
	local radius = 4 + 2 * rand

	local leaves = minetest.get_content_id("valleys_mapgen:fir_needles")
	local trunk = minetest.get_content_id("valleys_mapgen:fir_tree")
	local air = minetest.get_content_id("air")
	local ignore = minetest.get_content_id("ignore")
	local vm = minetest.get_voxel_manip()
	local emin, emax = vm:read_from_map({x = pos.x - 6, y = pos.y - 1, z = pos.z - 6}, {x = pos.x + 6, y = pos.y + height + 2, z = pos.z + 6})
	local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local data = vm:get_data()
	vmg.make_fir_tree(pos, data, area, height, radius, trunk, leaves, air, ignore)
	vm:set_data(data)
	vm:write_to_map()
	vm:update_map()
end

function vmg.grow_willow_tree(pos)
	-- individual parameters
	local rand = math.random()
	local height = math.floor(5 + 2.5 * rand)
	local radius = 5 + rand

	-- VoxelManip stuff
	local leaves = minetest.get_content_id("valleys_mapgen:willow_leaves")
	local trunk = minetest.get_content_id("valleys_mapgen:willow_tree")
	local air = minetest.get_content_id("air")
	local ignore = minetest.get_content_id("ignore")
	local vm = minetest.get_voxel_manip()
	local emin, emax = vm:read_from_map({x = pos.x - 4, y = pos.y, z = pos.z - 4}, {x = pos.x + 4, y = pos.y + height + 4, z = pos.z + 4})
	local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local data = vm:get_data()
	vmg.make_willow_tree(pos, data, area, height, radius, trunk, leaves, air, ignore)
	vm:set_data(data)
	vm:write_to_map()
	vm:update_map()
end

function vmg.make_tree(pos, data, area, height, radius, trunk, leaves, air, ignore)
	if vmg.loglevel >= 3 then
		print("[Valleys Mapgen] Generating tree at " .. minetest.pos_to_string(pos) .. " ...")
	end
	local ystride = area.ystride -- Useful to get the index above
	local iv = area:indexp(pos)
	for i = 1, height do -- Build the trunk
		data[iv] = trunk
		iv = iv + ystride -- increment by one node up
	end
	local np = {offset = 0.8, scale = 0.4, spread = {x = 8, y = 4, z = 8}, octaves = 3, persist = 0.5} -- VMG trees use a PerlinNoise to place leaves
	pos.y = pos.y + height - 1 -- pos was at the sapling position. By adding height we have the first air node above the trunk, so subtract 1 to get the highest trunk node.
	vmg.make_leavesblob(pos, data, area, leaves, air, ignore, {x = radius, y = radius, z = radius}, np) -- Generate leaves
end

function vmg.make_apple_tree(pos, data, area, height, radius, trunk, leaves, fruit, air, ignore) -- Same code but with apples
	if vmg.loglevel >= 3 then
		print("[Valleys Mapgen] Generating apple tree at " .. minetest.pos_to_string(pos) .. " ...")
	end
	local ystride = area.ystride -- Useful to get the index above
	local iv = area:indexp(pos)
	for i = 1, height do -- Build the trunk
		data[iv] = trunk
		iv = iv + ystride -- increment by one node up
	end
	local np = {offset = 0.8, scale = 0.4, spread = {x = 8, y = 4, z = 8}, octaves = 3, persist = 0.5}
	pos.y = pos.y + height - 1
	vmg.make_leavesblob(pos, data, area, leaves, air, ignore, {x = radius, y = radius, z = radius}, np, 0.06, fruit)
end

function vmg.make_banana_tree(pos, data, area, height, radius, trunk, leaves, fruit, air, ignore)
	if vmg.loglevel >= 3 then
		print("[Valleys Mapgen] Generating banana tree at " .. minetest.pos_to_string(pos) .. " ...")
	end
	local ystride = area.ystride -- Useful to get the index above
	local iv = area:indexp(pos)
	for i = 1, height do -- Build the trunk
		data[iv] = trunk
		iv = iv + ystride -- increment by one node up
	end
	local np = {offset = 0.8, scale = 0.4, spread = {x = 8, y = 4, z = 8}, octaves = 3, persist = 0.5}
	pos.y = pos.y + height - 1
	vmg.make_leavesblob(pos, data, area, leaves, air, ignore, {x = radius, y = radius, z = radius}, np, 0.06, fruit)
end

function vmg.make_birch_tree(pos, data, area, height, radius, trunk, leaves, air, ignore)
	if vmg.loglevel >= 3 then
		print("[Valleys Mapgen] Generating birch tree at " .. minetest.pos_to_string(pos) .. " ...")
	end
	local ystride = area.ystride -- Useful to get the index above
	local iv = area:indexp(pos)
	for i = 1, height do -- Build the trunk
		data[iv] = trunk
		iv = iv + ystride -- increment by one node up
	end
	local np = {offset = 0.8, scale = 0.4, spread = {x = 8, y = 4, z = 8}, octaves = 3, persist = 0.5}
	pos.y = pos.y + height - 1
	vmg.make_leavesblob(pos, data, area, leaves, air, ignore, {x = radius, y = radius, z = radius}, np)
end

function vmg.make_cherry_blossom_tree(pos, data, area, height, radius, trunk, leaves, air, ignore)
	if vmg.loglevel >= 3 then
		print("[Valleys Mapgen] Generating cherry blossom tree at " .. minetest.pos_to_string(pos) .. " ...")
	end
	local ystride = area.ystride -- Useful to get the index above
	local iv = area:indexp(pos)
	for i = 1, height do -- Build the trunk
		data[iv] = trunk
		iv = iv + ystride -- increment by one node up
	end
	local np = {offset = 0.8, scale = 0.4, spread = {x = 8, y = 4, z = 8}, octaves = 3, persist = 0.5}
	pos.y = pos.y + height - 1
	vmg.make_leavesblob(pos, data, area, leaves, air, ignore, {x = radius, y = radius, z = radius}, np)
end

local function make_jungle_root(x0, y0, z0, data, area, tree, air)
	local ystride = area.ystride
	local ybot = y0 - 1
	for x = x0 - 1, x0 + 1 do
		for z = z0 - 1, z0 + 1 do -- iterate in a 3x3 square around the trunk
			local iv = area:index(x, ybot, z)
			for i = 0, 5 do
				if data[iv] == air then -- find the ground level
					if math.random() < 0.6 then
						data[iv-ystride] = tree -- make jungle tree below
						if math.random() < 0.6 then
							data[iv] = tree -- make jungle tree at this air node
						end
					end
					break
				end
				iv = iv + ystride -- increment by one node up
			end
		end
	end
end

local function make_mangrove_root(x0, y0, z0, data, area, roots, air)
	local ystride = area.ystride
	local ybot = y0 - 1
	for x = x0 - 1, x0 + 1 do
		for z = z0 - 1, z0 + 1 do -- iterate in a 3x3 square around the trunk
			local iv = area:index(x, ybot, z)
			for i = 0, 5 do
				if data[iv] == air then -- find the ground level
					if math.random() < 0.6 then
						data[iv-ystride] = roots -- make mangrove root below
						if math.random() < 0.6 then
							data[iv] = roots -- make mangrove root at this air node
						end
					end
					break
				end
				iv = iv + ystride -- increment by one node up
			end
		end
	end
end

function vmg.make_jungle_tree(pos, data, area, height, radius, trunk, leaves, air, ignore)
	if vmg.loglevel >= 3 then
		print("[Valleys Mapgen] Generating jungle tree at " .. minetest.pos_to_string(pos) .. " ...")
	end
	local ystride = area.ystride -- Useful to get the index above
	local iv = area:indexp(pos)
	for i = 1, height do -- Build the trunk
		data[iv] = trunk
		iv = iv + ystride -- increment by one node up
	end
	vmg.register_after_mapgen(make_jungle_root, pos.x, pos.y, pos.z, data, area, trunk, air)
	local np = {offset = 0.8, scale = 0.4, spread = {x = 8, y = 4, z = 8}, octaves = 3, persist = 0.8}
	pos.y = pos.y + height
	vmg.make_leavesblob(pos, data, area, leaves, air, ignore, {x = radius, y = radius * 0.5, z = radius}, np)
end

function vmg.make_mangrove_tree(pos, data, area, height, radius, trunk, leaves, roots, air, ignore)
	if vmg.loglevel >= 3 then
		print("[Valleys Mapgen] Generating mangrove tree at " .. minetest.pos_to_string(pos) .. " ...")
	end
	local ystride = area.ystride -- Useful to get the index above
	local iv = area:indexp(pos)
	for i = 1, height do -- Build the trunk
		data[iv] = trunk
		iv = iv + ystride -- increment by one node up
	end
	vmg.register_after_mapgen(make_mangrove_root, pos.x, pos.y, pos.z, data, area, roots, air)
	local np = {offset = 0.8, scale = 0.4, spread = {x = 8, y = 4, z = 8}, octaves = 3, persist = 0.8}
	pos.y = pos.y + height
	vmg.make_leavesblob(pos, data, area, leaves, air, ignore, {x = radius, y = radius * 0.5, z = radius}, np)
end

function vmg.make_fir_tree(pos, data, area, height, radius, trunk, leaves, air, ignore)
	if vmg.loglevel >= 3 then
		print("[Valleys Mapgen] Generating fir tree at " .. minetest.pos_to_string(pos) .. " ...")
	end
	local ystride = area.ystride -- Useful to get the index above
	local iv = area:indexp(pos)
	for i = 1, height do -- Build the trunk
		data[iv] = trunk
		iv = iv + ystride -- increment by one node up
	end

	-- add leaves on the top (4% 0 ; 36% 1 ; 60% 2)
	local rand = math.random()
	if rand < 0.96 then
		data[iv] = leaves
		if rand < 0.60 then
			iv = iv + ystride
			data[iv] = leaves
		end
	end

	-- make several leaves rings
	local max_height = pos.y + height
	local min_height = pos.y + math.floor((0.2 + 0.3 * math.random()) * height)
	local radius_increment = (radius - 1.2) / (max_height - min_height)
	local np = {offset = 0.8, scale = 0.4, spread = {x = 12, y = 4, z = 12}, octaves = 3, persist = 0.8}

	pos.y = max_height - 1
	while pos.y >= min_height do
		local ring_radius = (max_height - pos.y) * radius_increment + 1.2
		vmg.make_leavesblob(pos, data, area, leaves, air, ignore, {x = ring_radius, y = 2, z = ring_radius}, np)
		pos.y = pos.y - math.random(2, 3)
	end
end

function vmg.make_pine_tree(pos, data, area, height, radius, trunk, leaves, air, ignore)
	if vmg.loglevel >= 3 then
		print("[Valleys Mapgen] Generating pine tree at " .. minetest.pos_to_string(pos) .. " ...")
	end
	local ystride = area.ystride -- Useful to get the index above
	local iv = area:indexp(pos)
	for i = 1, height do -- Build the trunk
		data[iv] = trunk
		iv = iv + ystride
	end

	-- add leaves on the top (4% 0 ; 36% 1 ; 60% 2)
	local rand = math.random()
	if rand < 0.96 then
		data[iv] = leaves
		if rand < 0.60 then
			iv = iv + ystride
			data[iv] = leaves
		end
	end

	local np = {offset = 0.8, scale = 0.3, spread = {x = 8, y = 4, z = 8}, octaves = 3, persist = 1}
	local min_height = pos.y + math.floor((0.4 + 0.2 * math.random()) * height)
	local midradius = radius / 2

	pos.y = pos.y + height - 1
	vmg.make_leavesblob(pos, data, area, leaves, air, ignore, {x = radius, y = 1.5, z = radius}, np) -- The first leavesblob at the top
	while pos.y >= min_height do -- Lower leavesblobs
		local angle, distance = math.random() * 2 * math.pi, math.random() * midradius -- For the pine tree, lower leavesblobs are smaller and shifted
		local cos, sin = math.cos(angle) * distance, math.sin(angle) * distance
		local bpos = {x = pos.x + cos, y = pos.y, z = pos.z + sin}
		vmg.make_leavesblob(bpos, data, area, leaves, air, ignore, {x = midradius, y = 1.5, z = midradius}, np)
		pos.y = pos.y - math.random(1, 2)
	end
end

function vmg.make_willow_tree(pos, data, area, height, radius, trunk, leaves, air, ignore)
	if vmg.loglevel >= 3 then
		print("[Valleys Mapgen] Generating willow tree at " .. minetest.pos_to_string(pos) .. " ...")
	end
	local ystride = area.ystride -- Useful to get the index above
	local iv = area:indexp(pos)
	for i = 1, height do -- Build the trunk
		data[iv] = trunk
		iv = iv + ystride -- increment by one node up
	end
	local np = {offset = 0.8, scale = 0.4, spread = {x = 8, y = 4, z = 8}, octaves = 3, persist = 0.5}
	pos.y = pos.y + height - 1
	vmg.make_leavesblob(pos, data, area, leaves, air, ignore, {x = radius, y = radius, z = radius}, np)
end

function vmg.make_leavesblob(pos, data, area, leaves, air, ignore, radius, np, fruit_chance, fruit)
	fruit_chance = fruit_chance or 0

	np.seed = math.random(0, 16777215) -- noise seed
	local minp = vector.subtract(pos, radius) -- minimal corner of the leavesblob
	local maxp = vector.add(pos, radius) -- maximal corner of the leavesblob
	local int_minp = {x = math.floor(minp.x), y = math.floor(minp.y), z = math.floor(minp.z)} -- Same positions, but with integer coordinates
	local int_maxp = {x = math.ceil(maxp.x), y = math.ceil(maxp.y), z = math.ceil(maxp.z)}

	local length = vector.subtract(int_maxp, int_minp)
	local chulens = vector.add(length, 1)
	local obj = minetest.get_perlin_map(np, chulens)
	local pmap = obj:get3dMap_flat(minp)
	local i = 1
	-- iterate for every position
	-- calculate the distance from the center by the Pythagorean theorem: d = sqrt(x²+y²+z²)
	for x = int_minp.x, int_maxp.x do
		local xval = ((x - pos.x) / radius.x) ^ 2 -- calculate x², y², z² separately, to avoid recalculating x² for every y or z iteration. Divided by the radius to scale it to 0…1
		for y = int_minp.y, int_maxp.y do
			local yval = ((y - pos.y) / radius.y) ^ 2
			for z = int_minp.z, int_maxp.z do
				local zval = ((z - pos.z) / radius.z) ^ 2
				local dist = math.sqrt(xval + yval + zval) -- Calculate the distance
				local nval = pmap[i] -- Get the noise value
				if nval > dist then -- if the noise is bigger than the distance, make leaves
					local iv = area:index(x, y, z)
					if data[iv] == air or data[iv] == ignore then
						if math.random() < fruit_chance then
							data[iv] = fruit
						else
							data[iv] = leaves
						end
					end
				end
				i = i + 1 -- increment noise index
			end
		end
	end
end

-- Adapt the code to the latest minetest_game that use these functions
function default.grow_new_apple_tree(pos)
	local is_apple_tree = math.random(4) == 1
	default.grow_tree(pos, is_apple_tree)
end
default.grow_new_jungle_tree = default.grow_jungle_tree
default.grow_new_pine_tree = default.grow_pine_tree
