local dry_dirt_threshold = vmg.define("dry_dirt_threshold", 0.6)

local clay_threshold = vmg.define("clay_threshold", 1)
local sand_threshold = vmg.define("sand_threshold", 0.75)
local silt_threshold = vmg.define("silt_threshold", 1)

if vmg.define("plants", true) then
	vmg.register_plant({
		nodes = {"default:papyrus", n=4},
		cover = 0.030,
		density = 0.014,
		priority = 75,
		check = function(t)
			return t.temp > 1 and t.temp < 1.8 and t.water > 0.7 and t.humidity > 3 and t.v13 > -0.4
		end,
	})

	vmg.register_plant({
		nodes = "valleys_mapgen:arrow_arum",
		cover = 0.40,
		density = 0.32,
		priority = 68,
		check = function(t, pos)
			return t.humidity > 1 and t.v2 < 0.01 and t.v13 > 0.1 and t.v15 < 0.25 and pos.y > 3
		end,
	})

	vmg.register_plant({
		nodes = "valleys_mapgen:hibiscus",
		cover = 0.012,
		density = 0.007,
		priority = 65,
		check = function(t, pos)
			return t.temp > 1 and t.temp < 1.6 and t.v2 < 0.05 and pos.y > 3 and pos.y < 60
		end,
	})

	vmg.register_plant({
		nodes = "valleys_mapgen:calla_lily",
		cover = 0.32,
		density = 0.06,
		priority = 63,
		check = function(t, pos)
			return t.temp > 1.2 and t.v2 < 0.02 and t.v13 < 1 and t.v14 < 0.1 and t.v15 < 0.75 and pos.y > 3
		end,
	})

	-- Grass will be stunted in less ideal soil, but will grow on anything
	-- but straight clay or sand as long as it's not dry.
	for i = 1, 5 do
		vmg.register_plant({
			nodes = { "default:grass_"..i},
			cover = 0.60,
			density = 0.24,
			priority = 59,
			check = function(t, pos)
				return t.v15 < sand_threshold - (i - 1) * 0.1 and t.temp >= 1 and t.temp < 1.5 and t.humidity < 2.6 and t.humidity > dry_dirt_threshold and t.v13 < clay_threshold - (i - 1) * 0.1
			end,
		})
	end

	-- Replaced by dry grass on dry dirt
	for i = 1, 5 do
		vmg.register_plant({
			nodes = { "default:dry_grass_"..i},
			cover = 0.60,
			density = 0.24,
			priority = 59,
			check = function(t, pos)
				return t.v15 < sand_threshold - (i - 1) * 0.1 and t.temp >= 1 and t.temp < 1.5 and t.humidity < 2.6 and t.humidity <= dry_dirt_threshold and t.v13 < clay_threshold - (i - 1) * 0.1
			end,
		})
	end

	vmg.register_plant({
		nodes = {"default:junglegrass"},
		cover = 0.65, --0.65
		density = 0.40,
		priority = 60,
		check = function(t, pos)
			return t.v15 > -0.6 and t.temp >= 1.8 and t.humidity > 2.2 and t.v16 > 1.8
		end,
	})

	vmg.register_plant({
		nodes = {"valleys_mapgen:bird_of_paradise"},
		cover = 0.001, --0.001
		density = 0.0003, --0.0003
		priority = 52,
		check = function(t, pos)
			return t.v15 > 0 and t.temp >= 2 and t.humidity > 2.1 and t.v16 > 1.8
		end,
	})

	vmg.register_plant({
		nodes = {"valleys_mapgen:mangrove_fern"},
		cover = 0.1,
		density = 0.05,
		priority = 50,
		check = function(t, pos)
			return t.v2 < 0.03 and t.temp >= 1.7 and t.humidity > 1.5 and pos.y < 6
		end,
	})

	vmg.register_plant({
		nodes = {"valleys_mapgen:orchid"},
		cover = 0.02,
		density = 0.005,
		priority = 45,
		check = function(t, pos)
			return t.v15 < 0.7 and t.temp >= 1.9 and t.humidity > 2 and t.v16 > 2
		end,
	})

	vmg.register_plant({
		nodes = {"default:cactus", n=4},
		cover = 0.3,
		density = 0.008,
		priority = 10,
		check = function(t, pos)
			return t.v15 > 0.65 and t.humidity < 0.5 and t.v16 > 0 and t.temp > 1.6
		end,
	})

	vmg.register_plant({
		nodes = {"default:dry_shrub"},
		cover = 0.064,
		density = 0.064,
		priority = 54,
		check = function(t, pos)
			return t.v15 > 0.65 and t.humidity < 0.5
		end,
	})

	vmg.register_plant({
		nodes = {"flowers:rose"},
		cover = 0.015,
		density = 0.012,
		priority = 47,
		check = function(t, pos)
			return t.temp > 1.2 and t.temp < 1.8 and t.humidity < 1.7 and t.v14 >= -0.1 and t.v15 < 0.4 and t.v15 >= -0.6 and t.v13 < 0.82
		end,
	})

	vmg.register_plant({
		nodes = {"valleys_mapgen:gerbera"},
		cover = 0.010,
		density = 0.008,
		priority = 44,
		check = function(t, pos)
			return t.temp > 1.1 and t.temp < 1.8 and t.humidity < 1.7 and t.v14 >= -0.1 and t.v15 < 0.4 and t.v15 >= -0.6 and t.v13 < 0.82
		end,
	})

	vmg.register_plant({
		nodes = {"flowers:geranium"},
		cover = 0.040,
		density = 0.015,
		priority = 48,
		check = function(t, pos)
			return t.temp > 0.98 and t.temp < 1.8 and t.humidity < 1.7 and t.v14 >= -0.1 and t.v15 < 0.4 and t.v15 >= -0.6 and t.v13 < 0.82 and t.thickness <= 1.3
		end,
	})

	vmg.register_plant({
		nodes = {"flowers:viola"},
		cover = 0.015,
		density = 0.012,
		priority = 29,
		check = function(t, pos)
			return t.temp > 0.98 and t.temp < 1.8 and t.humidity < 1.7 and t.v14 >= -0.1 and t.v15 < 0.4 and t.v15 >= -0.6 and t.v13 < 0.82 and t.v16 < 1.6
		end,
	})

	vmg.register_plant({
		nodes = {"flowers:tulip"},
		cover = 0.020,
		density = 0.003,
		priority = 50,
		check = function(t, pos)
			return t.temp > 1.3 and t.temp < 1.8 and t.humidity < 1.5 and t.v14 >= -0.1 and t.v15 < 0.4 and t.v15 >= -0.6 and t.v13 < 0.82
		end,
	})

	vmg.register_plant({
		nodes = {"flowers:dandelion_white", "flowers:dandelion_yellow"},
		cover = 0.010,
		density = 0.006,
		priority = 43,
		check = function(t, pos)
			return t.temp > 0.98 and t.temp < 1.8 and t.humidity < 1.7 and t.v14 >= -0.1 and t.v15 < 0.4 and t.v15 >= -0.6 and t.v13 < 0.82
		end,
	})

	vmg.register_plant({
		nodes = {"flowers:mushroom_fertile_red", "flowers:mushroom_fertile_brown"},
		cover = 0.006,
		density = 0.006,
		priority = 61,
		check = function(t, pos)
			return t.temp > 1.2 and t.temp < 1.6 and t.humidity > 0.5 and t.v13 < 0.5 and t.v14 < 0.5 and t.v15 < 0.5
		end,
	})
end

---------
--Trees--
---------

if vmg.define("trees", true) then
	vmg.register_plant({ -- Pine tree
		nodes = {
			trunk = "default:pine_tree",
			leaves = "default:pine_needles",
			air = "air", ignore = "ignore",
		},
		cover = 0.4,
		density = 0.015,
		priority = 80,
		check = function(t, pos)
			return t.v14 < 0 and t.temp < 1.5 and t.temp >= 0.90 and t.humidity < 1 and t.v15 < 0.8 and math.abs(t.v13) < 0.2
		end,
		grow = function(nodes, pos, data, area)
			local rand = math.random()
			local height = math.floor(9 + 6 * rand)
			local radius = 4 + 2 * rand

			vmg.make_pine_tree(pos, data, area, height, radius, nodes.trunk, nodes.leaves, nodes.air, nodes.ignore)
		end,
	})

	vmg.register_plant({ -- Jungle tree
		nodes = {
			trunk = "default:jungletree",
			leaves = "default:jungleleaves",
			air = "air", ignore = "ignore",
		},
		cover = 0.5,
		density = 0.06,
		priority = 73,
		check = function(t, pos)
			return t.v15 < 0.7 and t.temp >= 1.9 and t.humidity > 2 and t.v16 > 2
		end,
		grow = function(nodes, pos, data, area)
			local rand = math.random()
			local height = math.floor(8 + 4 * rand)
			local radius = 5 + 3 * rand

			vmg.make_jungle_tree(pos, data, area, height, radius, nodes.trunk, nodes.leaves, nodes.air, nodes.ignore)
		end,
	})

	vmg.register_plant({ -- Mangrove tree
		nodes = {
			trunk = "valleys_mapgen:mangrove_tree",
			leaves = "valleys_mapgen:mangrove_leaves",
			roots = "valleys_mapgen:mangrove_roots",
			air = "air", ignore = "ignore",
		},
		cover = 0.3,
		density = 0.2,
		priority = 72,
		check = function(t, pos)
			return t.v2 < 0.03 and t.temp >= 1.7 and t.humidity > 1.5 and pos.y < 5
		end,
		grow = function(nodes, pos, data, area)
			local rand = math.random()
			local height = math.floor(3 + 1.5 * rand)
			local radius = 2 + 1.5 * rand

			vmg.make_mangrove_tree(pos, data, area, height, radius, nodes.trunk, nodes.leaves, nodes.roots, nodes.air, nodes.ignore)
		end,
	})

	local leaves_colors = vmg.define("leaves_colors", true)

	vmg.register_plant({ -- Apple tree
		nodes = {
			trunk = "default:tree",
			leaves = { -- get some varied leaves
				"default:leaves",
				"valleys_mapgen:leaves2",
				"valleys_mapgen:leaves3",
				"valleys_mapgen:leaves4",
				"valleys_mapgen:leaves5"
			},
			fruit = "default:apple",
			air = "air", ignore = "ignore",
		},
		cover = 0.3,
		density = 0.05,
		priority = 66,
		check = function(t, pos)
			return t.v15 < 0.6 and t.temp >= 0.85 and t.temp < 2.3 and t.humidity < 3 and t.v16 < 2 and t.v14 > -0.5 and t.v13 < 0.8 and pos.y > 2
		end,
		grow = function(nodes, pos, data, area)
			local rand = math.random()
			local height = math.floor(4 + 2.5 * rand)
			local radius = 3 + rand
			local leaves = nodes.leaves[1]
			if leaves_colors then
				leaves = nodes.leaves[math.random(#nodes.leaves)]
			end

			if math.random(4) == 1 then
				vmg.make_apple_tree(pos, data, area, height, radius, nodes.trunk, leaves, nodes.fruit, nodes.air, nodes.ignore)
			else
				vmg.make_tree(pos, data, area, height, radius, nodes.trunk, leaves, nodes.air, nodes.ignore)
			end
		end,
	})

	vmg.register_plant({ -- Banana tree
		nodes = {
			trunk = "valleys_mapgen:banana_tree",
			leaves = "valleys_mapgen:banana_leaves",
			fruit = "valleys_mapgen:banana",
			air = "air", ignore = "ignore",
		},
		cover = 0.18,
		density = 0.005,
		priority = 70,
		check = function(t, pos)
			return t.v15 > -0.6 and t.temp >= 1.8 and t.humidity > 2.2 and t.v16 > 1.8
		end,
		grow = function(nodes, pos, data, area)
			local rand = math.random()
			local height = math.floor(4 + 2.5 * rand)
			local radius = 3 + rand

			vmg.make_banana_tree(pos, data, area, height, radius, nodes.trunk, nodes.leaves, nodes.fruit, nodes.air, nodes.ignore)
		end,
	})

	vmg.register_plant({ -- Fir tree
		nodes = {
			trunk = "valleys_mapgen:fir_tree",
			leaves = "valleys_mapgen:fir_needles",
			air = "air", ignore = "ignore",
		},
		cover = 0.7,
		density = 0.045,
		priority = 71,
		check = function(t, pos)
			return t.temp > 0.38 and t.temp < 1 and t.humidity > 0.9 and t.v15 > 0 and t.v15 < 0.55
		end,
		grow = function(nodes, pos, data, area)
			local rand = math.random()
			local height = math.floor(9 + 6 * rand)
			local radius = 4 + 2 * rand

			vmg.make_fir_tree(pos, data, area, height, radius, nodes.trunk, nodes.leaves, nodes.air, nodes.ignore)
		end,
	})

	vmg.register_plant({ -- Cherry blossom tree
		nodes = {
			trunk = "valleys_mapgen:cherry_blossom_tree",
			leaves = "valleys_mapgen:cherry_blossom_leaves",
			air = "air", ignore = "ignore",
		},
		cover = 0.13,
		density = 0.005,
		priority = 38,
		check = function(t, pos)
			return t.temp > 0.6 and t.temp < 1 and t.humidity < 1.4 and t.v15 > 0 and t.v15 < 0.55 and pos.y > 30
		end,
		grow = function(nodes, pos, data, area)
			local rand = math.random()
			local height = math.floor(4 + 2.5 * rand)
			local radius = 3 + rand

			vmg.make_cherry_blossom_tree(pos, data, area, height, radius, nodes.trunk, nodes.leaves, nodes.air, nodes.ignore)
		end,
	})

	vmg.register_plant({ -- Birch tree
		nodes = {
			trunk = "valleys_mapgen:birch_tree",
			leaves = "valleys_mapgen:birch_leaves",
			air = "air", ignore = "ignore",
		},
		cover = 0.07,
		density = 0.05,
		priority = 69,
		check = function(t, pos)
			return t.temp > 0.5 and t.temp < 1 and t.humidity < 1.4 and t.v13 < 1 and t.v14 < 0.1 and t.v15 < 0.75 and pos.y > 10
		end,
		grow = function(nodes, pos, data, area)
			local rand = math.random()
			local height = math.floor(6 + 2.5 * rand)
			local radius = 2 + rand

			vmg.make_birch_tree(pos, data, area, height, radius, nodes.trunk, nodes.leaves, nodes.air, nodes.ignore)
		end,
	})

	vmg.register_plant({ -- Willow tree
		nodes = {
			trunk = "valleys_mapgen:willow_tree",
			leaves = "valleys_mapgen:willow_leaves",
			air = "air", ignore = "ignore",
		},
		cover = 0.05,
		density = 0.02,
		priority = 70,
		check = function(t, pos)
			return t.temp < 1.5 and t.humidity > 1 and t.humidity < 2 and t.v2 < 0.03 and pos.y > 3
		end,
		grow = function(nodes, pos, data, area)
			local rand = math.random()
			local height = math.floor(5 + 2.5 * rand)
			local radius = 5 + rand

			vmg.make_willow_tree(pos, data, area, height, radius, nodes.trunk, nodes.leaves, nodes.air, nodes.ignore)
		end,
	})
end
