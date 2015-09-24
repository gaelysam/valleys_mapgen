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

	local c_mushroom_fertile_brown = minetest.get_content_id("flowers:mushroom_fertile_brown")
	local c_mushroom_fertile_red = minetest.get_content_id("flowers:mushroom_fertile_red")
	local c_huge_mushroom_cap = minetest.get_content_id("valleys_mapgen:huge_mushroom_cap")
	local c_giant_mushroom_cap = minetest.get_content_id("valleys_mapgen:giant_mushroom_cap")
	local c_giant_mushroom_stem = minetest.get_content_id("valleys_mapgen:giant_mushroom_stem")
	local c_glowing_fungal_stone = minetest.get_content_id("valleys_mapgen:glowing_fungal_stone")
	local c_stalactite = minetest.get_content_id("valleys_mapgen:stalactite")
	local c_stalagmite = minetest.get_content_id("valleys_mapgen:stalagmite")

	-- Air and Ignore
	local c_air = minetest.get_content_id("air")
	local c_ignore = minetest.get_content_id("ignore")

	-- The VoxelManipulator, a complicated but speedy method to set many nodes at the same time
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	-- local heightmap = minetest.get_mapgen_object("heightmap")
	-- local heatmap = minetest.get_mapgen_object("heatmap")
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

	for x = minp.x, maxp.x do -- for each YZ plane
		for z = minp.z, maxp.z do -- for each vertical line in this plane
			local underground = false
			local air_count = 0
			for y = maxp.y, minp.y, -1 do -- for each node in vertical line
				local ivm = a:index(x, y, z) -- index of the data array, matching the position {x, y, z}
				if y < -1 or data[ivm] == c_stone then
					underground = true
				end

				if underground and data[ivm] == c_stone or data[ivm] == c_dirt then
					local r = math.random(50)

					if air_count > 0 and r == 1 then
						data[ivm + ystride] = c_mushroom_fertile_red
						data[ivm] = c_dirt
					elseif air_count > 0 and r == 2 then
						data[ivm + ystride] = c_mushroom_fertile_brown
						data[ivm] = c_dirt
					elseif air_count > 1 and r == 4 then
						data[ivm + ystride*2] = c_huge_mushroom_cap
						data[ivm + ystride] = c_giant_mushroom_stem
						data[ivm] = c_dirt
					elseif air_count > 2 and r == 5 then
						data[ivm + ystride*3] = c_giant_mushroom_cap
						data[ivm + ystride*2] = c_giant_mushroom_stem
						data[ivm + ystride] = c_giant_mushroom_stem
						data[ivm] = c_dirt
					elseif air_count > 0 and r <18 then
						data[ivm + ystride] = c_stalagmite
					end

					air_count = 0
				elseif underground and data[ivm] == c_air then
					air_count = air_count + 1
					if air_count == 1 and y < maxp.y and data[ivm + ystride] == c_stone then
						local r = math.random(20)
						if r == 1 then
							data[ivm + ystride] = c_glowing_fungal_stone
						elseif r < 5 then
							data[ivm] = c_stalactite
						end
					end
				else
					air_count = 0
				end
			end
		end
	end

	-- execute voxelmanip boring stuff to write to the map...
	vm:set_data(data)
	vm:write_to_map()
end

