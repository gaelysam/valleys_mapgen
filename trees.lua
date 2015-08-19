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

function default.grow_tree(pos, is_apple_tree)
	local rand = math.random()
	local height = math.floor(4 + 2.5 * rand)
	local radius = 3 + rand

	local leaves = minetest.get_content_id("default:leaves")
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

function vmg.make_tree(pos, data, area, height, radius, trunk, leaves, air, ignore)
	if vmg.loglevel >= 3 then
		print("[Valleys Mapgen] Generating tree at " .. minetest.pos_to_string(pos) .. " ...")
	end
	local ystride = area.ystride
	local iv = area:indexp(pos)
	for i = 1, height do
		data[iv] = trunk
		iv = iv + ystride
	end
	local np = {offset = 0.8, scale = 0.4, spread = {x = 8, y = 4, z = 8}, octaves = 3, persist = 0.5}
	pos.y = pos.y + height - 1
	vmg.make_leavesblob(pos, data, area, leaves, air, ignore, {x = radius, y = radius, z = radius}, np)
end

function vmg.make_apple_tree(pos, data, area, height, radius, trunk, leaves, fruit, air, ignore)
	if vmg.loglevel >= 3 then
		print("[Valleys Mapgen] Generating apple tree at " .. minetest.pos_to_string(pos) .. " ...")
	end
	local ystride = area.ystride
	local iv = area:indexp(pos)
	for i = 1, height do
		data[iv] = trunk
		iv = iv + ystride
	end
	local np = {offset = 0.8, scale = 0.4, spread = {x = 8, y = 4, z = 8}, octaves = 3, persist = 0.5}
	pos.y = pos.y + height - 1
	vmg.make_leavesblob(pos, data, area, leaves, air, ignore, {x = radius, y = radius, z = radius}, np, 0.06, fruit)
end

local function make_jungle_root(x0, y0, z0, data, area, tree, air)
	local ystride = area.ystride
	local ybot = y0 - 1
	for x = x0 - 1, x0 + 1 do
		for z = z0 - 1, z0 + 1 do
			local iv = area:index(x, ybot, z)
			for i = 0, 5 do
				if data[iv] == air then
					if math.random() < 0.6 then
						data[iv-ystride] = tree -- make jungle tree below
						if math.random() < 0.6 then
							data[iv] = tree -- make jungle tree at this air node
						end
					end
					break
				end
				iv = iv + ystride
			end
		end
	end
end

function vmg.make_jungle_tree(pos, data, area, height, radius, trunk, leaves, air, ignore)
	if vmg.loglevel >= 3 then
		print("[Valleys Mapgen] Generating jungle tree at " .. minetest.pos_to_string(pos) .. " ...")
	end
	local ystride = area.ystride
	local iv = area:indexp(pos)
	for i = 1, height do
		data[iv] = trunk
		iv = iv + ystride
	end
	vmg.register_after_mapgen(make_jungle_root, pos.x, pos.y, pos.z, data, area, trunk, air)
	local np = {offset = 0.8, scale = 0.4, spread = {x = 8, y = 4, z = 8}, octaves = 3, persist = 0.8}
	pos.y = pos.y + height
	vmg.make_leavesblob(pos, data, area, leaves, air, ignore, {x = radius, y = radius * 0.5, z = radius}, np)
end

function vmg.make_fir_tree(pos, data, area, height, radius, trunk, leaves, air, ignore)
	if vmg.loglevel >= 3 then
		print("[Valleys Mapgen] Generating fir tree at " .. minetest.pos_to_string(pos) .. " ...")
	end
	local ystride = area.ystride
	local iv = area:indexp(pos)
	for i = 1, height do
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
	local ystride = area.ystride
	local iv = area:indexp(pos)
	for i = 1, height do
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
	vmg.make_leavesblob(pos, data, area, leaves, air, ignore, {x = radius, y = 1.5, z = radius}, np)
	while pos.y >= min_height do
		local angle, distance = math.random() * 2 * math.pi, math.random() * midradius
		local cos, sin = math.cos(angle) * distance, math.sin(angle) * distance
		local bpos = {x = pos.x + cos, y = pos.y, z = pos.z + sin}
		vmg.make_leavesblob(bpos, data, area, leaves, air, ignore, {x = midradius, y = 1.5, z = midradius}, np)
		pos.y = pos.y - math.random(1, 2)
	end
end

function vmg.make_leavesblob(pos, data, area, leaves, air, ignore, radius, np, fruit_chance, fruit)
	local count = 0
	fruit_chance = fruit_chance or 0

	np.seed = math.random(0, 16777215)
	local minp = vector.subtract(pos, radius)
	local maxp = vector.add(pos, radius)
	local int_minp = {x = math.floor(minp.x), y = math.floor(minp.y), z = math.floor(minp.z)}
	local int_maxp = {x = math.ceil(maxp.x), y = math.ceil(maxp.y), z = math.ceil(maxp.z)}

	local length = vector.subtract(int_maxp, int_minp)
	local chulens = vector.add(length, 1)
	local obj = minetest.get_perlin_map(np, chulens)
	local pmap = obj:get3dMap_flat(minp)
	local i = 1
	for x = int_minp.x, int_maxp.x do
		local xval = ((x - pos.x) / radius.x) ^ 2
		for y = int_minp.y, int_maxp.y do
			local yval = ((y - pos.y) / radius.y) ^ 2
			for z = int_minp.z, int_maxp.z do
				local zval = ((z - pos.z) / radius.z) ^ 2
				local dist = math.sqrt(xval + yval + zval)
				local nval = pmap[i]
				if nval > dist then
					local iv = area:index(x, y, z)
					if data[iv] == air or data[iv] == ignore then
						count = count + 1
						if math.random() < fruit_chance then
							data[iv] = fruit
						else
							data[iv] = leaves
						end
					end
				end
				i = i + 1
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
