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
	nodes = "valleys_mapgen:calla_lilly",
	cover = 0.32,
	density = 0.06,
	priority = 63,
	check = function(t, pos)
		return t.temp > 1.2 and t.v2 < 0.02 and t.v13 < 1 and t.v14 < 0.1 and t.v15 < 0.75 and pos.y > 3
	end,
})

vmg.register_plant({
	nodes = {"default:grass_1", "default:grass_2", "default:grass_3", "default:grass_4", "default:grass_5"},
	cover = 0.60,
	density = 0.24,
	priority = 59,
	check = function(t, pos)
		return t.v15 < 0.65 and t.temp >= 0.65 and t.temp < 1.5 and t.humidity < 2.6 and t.v16 < 1.5 and t.v13 < 0.8
	end,
})

vmg.register_plant({
	nodes = {"default:junglegrass"},
	cover = 0.65,
	density = 0.40,
	priority = 60,
	check = function(t, pos)
		return t.v15 > -0.6 and t.temp >= 1.8 and t.humidity > 2.2 and t.v16 > 1.8
	end,
})

vmg.register_plant({
	nodes = {"valleys_mapgen:bird_of_paradise"},
	cover = 0.001,
	density = 0.0003,
	priority = 52,
	check = function(t, pos)
		return t.v15 > 0 and t.temp >= 2 and t.humidity > 2.1 and t.v16 > 1.8
	end,
})

vmg.register_plant({
	nodes = {"valleys_mapgen:orchid"},
	cover = 0.002,
	density = 0.0005,
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
