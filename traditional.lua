-- Greatly abbreviated...

-- THE MAPGEN FUNCTION
function vmg.generate(minp, maxp, seed)
	-- minp and maxp strings, used by logs
	local minps, maxps = minetest.pos_to_string(minp), minetest.pos_to_string(maxp)

	-- Define content IDs
	-- A content ID is a number that represents a node in the core of Minetest.
	-- Every nodename has its ID.
	-- The VoxelManipulator uses content IDs instead of nodenames.

	-- Ground nodes
	local c_stone = minetest.get_content_id("default:stone")
	local c_dirt = minetest.get_content_id("default:dirt")
	local c_dirt_with_grass = minetest.get_content_id("default:dirt_with_grass")

	local c_mushroom_fertile_brown = minetest.get_content_id("flowers:mushroom_fertile_brown")
	local c_mushroom_fertile_red = minetest.get_content_id("flowers:mushroom_fertile_red")
	local c_huge_mushroom_cap = minetest.get_content_id("valleys_mapgen_c:huge_mushroom_cap")
	local c_giant_mushroom_cap = minetest.get_content_id("valleys_mapgen_c:giant_mushroom_cap")
	local c_giant_mushroom_stem = minetest.get_content_id("valleys_mapgen_c:giant_mushroom_stem")

	-- Air and Ignore
	local c_air = minetest.get_content_id("air")
	local c_ignore = minetest.get_content_id("ignore")

	-- The VoxelManipulator, a complicated but speedy method to set many nodes at the same time
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local heightmap = minetest.get_mapgen_object("heightmap")
	local heatmap = minetest.get_mapgen_object("heatmap")
	local humiditymap = minetest.get_mapgen_object("humiditymap")
	local data = vm:get_data() -- data is the original array of content IDs (solely or mostly air)
	-- Be careful: emin ≠ minp and emax ≠ maxp !
	-- The data array is not limited by minp and maxp. It exceeds it by 16 nodes in the 6 directions.
	-- The real limits of data array are emin and emax.
	-- The VoxelArea is used to convert a position into an index for the array.
	local a = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local ystride = a.ystride -- Tip : the ystride of a VoxelArea is the number to add to the array index to get the index of the position above. It's faster because it avoids to completely recalculate the index.

	-- Mapgen preparation is now finished. Check the timer to know the elapsed time.
	local t1 = os.clock()

	-- Calculate the noise values

	-- THE CORE OF THE MOD: THE MAPGEN ALGORITHM ITSELF

	local i = 1
	for z = minp.z, maxp.z do -- for each vertical line in this plane
		for x = minp.x, maxp.x do -- for each YZ plane
			-- This gives you an idea of where to start.
			local y = heightmap[i]
			local ivm = a:index(x, y, z) -- index of the data array, matching the position {x, y, z}
			if data[ivm] == c_air then
				while y >= minp.y and data[ivm] == c_air do
					y = y - 1
					ivm = a:index(x, y, z)
				end
			else
				while y <= maxp.y and data[ivm] ~= c_air do
					y = y + 1
					ivm = a:index(x, y, z)
				end
				y = y - 1
			end
			if y >= minp.y and y < maxp.y then
				if data[ivm] == c_dirt_with_grass or data[ivm] == c_dirt then
					vmg.decorate(vm, x, y, z, heatmap[i], humiditymap[i])
				else
-- 					local s = minetest.get_name_from_content_id(data[ivm])
-- 					if s ~= "air" then
-- 						print(s)
-- 					end
				end
			end

			i = i + 1
		end
	end

	-- execute voxelmanip boring stuff to write to the map...
	vm:set_data(data)
	vm:write_to_map()
end

function vmg.decorate(vm, x, y, z, heat, humidity)
		print(x..","..y..","..z..", heat: "..heat..", humidity: "..humidity)
end
