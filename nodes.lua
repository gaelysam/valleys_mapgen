minetest.register_alias("default:glowing_fungal_stone", "valleys_mapgen_c:glowing_fungal_stone")
minetest.register_alias("default:stalactite", "valleys_mapgen_c:stalactite")
minetest.register_alias("default:stalagmite", "valleys_mapgen_c:stalagmite")

-- Set the liquid range according to settings (by default 3)
-- local waterflow = vmg.define("waterflow", 3)

-- minetest.override_item("default:river_water_source", {liquid_range = waterflow})
-- minetest.override_item("default:river_water_flowing", {liquid_range = waterflow})

-- We need more types of stone than just gray. Fortunately, there are
--  two available already. Sandstone forms in layers. Desert stone...
--  doesn't exist, but let's assume it's another sedementary rock
--  and place it similarly. -- djr
minetest.register_ore({ore_type="sheet", ore="default:sandstone", wherein="default:stone", clust_num_ores=250, clust_scarcity=60, clust_size=10, y_min=-1000, y_max=31000, noise_threshhold=0.1, noise_params={offset=0, scale=1, spread={x=256, y=256, z=256}, seed=4130293965, octaves=5, persist=0.60}, random_factor=1.0})
minetest.register_ore({ore_type="sheet", ore="default:desert_stone", wherein="default:stone", clust_num_ores=250, clust_scarcity=60, clust_size=10, y_min=-1000, y_max=31000, noise_threshhold=0.1, noise_params={offset=0, scale=1, spread={x=256, y=256, z=256}, seed=163281090, octaves=5, persist=0.60}, random_factor=1.0})

-- Add silt
minetest.register_node("valleys_mapgen:silt", {
	description = "Silt",
	tiles = {"vmg_silt.png"},
	is_ground_content = true,
	groups = {crumbly=3},
	sounds = default.node_sound_dirt_defaults(),
})

-- I don't like the default:clay, this does not look like clay. So add red clay.
minetest.register_node("valleys_mapgen:red_clay", {
	description = "Red Clay",
	tiles = {"vmg_red_clay.png"},
	is_ground_content = true,
	groups = {crumbly=3},
	sounds = default.node_sound_dirt_defaults(),
})

minetest.override_item("default:clay", {description = "White Clay"})

-- Add dirts
local function register_dirts(readname)
	local name = readname:lower()
	local itemstr_dirt = "valleys_mapgen:dirt_" .. name
	local itemstr_lawn = itemstr_dirt .. "_with_grass"
	local itemstr_snow = itemstr_dirt .. "_with_snow"
	local tilestr = "vmg_dirt_" .. name .. ".png"

	minetest.register_node(itemstr_dirt, {
		description = readname .. " Dirt",
		tiles = {tilestr},
		is_ground_content = true,
		groups = {crumbly=3,soil=1},
		sounds = default.node_sound_dirt_defaults(),
	})

	minetest.register_node(itemstr_lawn, {
		description = readname .. " Dirt with Grass",
		tiles = {"default_grass.png", tilestr, tilestr .. "^default_grass_side.png"},
		is_ground_content = true,
		groups = {crumbly=3,soil=1},
		drop = itemstr_dirt,
		sounds = default.node_sound_dirt_defaults({
			footstep = {name="default_grass_footstep", gain=0.25},
		}),
	})

	minetest.register_node(itemstr_snow, {
		description = readname .. " Dirt with Snow",
		tiles = {"default_snow.png", tilestr, tilestr .. "^default_snow_side.png"},
		is_ground_content = true,
		groups = {crumbly=3,soil=1},
		drop = itemstr_dirt,
		sounds = default.node_sound_dirt_defaults({
			footstep = {name="default_snow_footstep", gain=0.25},
		}),
	})

	minetest.register_abm({
		nodenames = {itemstr_dirt},
		interval = 2,
		chance = 200,
		action = function(pos, node)
			local above = {x=pos.x, y=pos.y+1, z=pos.z}
			local name = minetest.get_node(above).name
			local nodedef = minetest.registered_nodes[name]
			if nodedef and (nodedef.sunlight_propagates or nodedef.paramtype == "light")
					and nodedef.liquidtype == "none"
					and (minetest.get_node_light(above) or 0) >= 13 then
				if name == "default:snow" or name == "default:snowblock" then
					minetest.set_node(pos, {name = itemstr_snow})
				else
					minetest.set_node(pos, {name = itemstr_lawn})
				end
			end
		end
	})

	minetest.register_abm({
		nodenames = {itemstr_lawn},
		interval = 2,
		chance = 20,
		action = function(pos, node)
			local above = {x=pos.x, y=pos.y+1, z=pos.z}
			local name = minetest.get_node(above).name
			local nodedef = minetest.registered_nodes[name]
			if name ~= "ignore" and nodedef
					and not ((nodedef.sunlight_propagates or nodedef.paramtype == "light")
					and nodedef.liquidtype == "none") then
				minetest.set_node(pos, {name = itemstr_dirt})
			end
		end
	})
end

-- 3 types of dirt :
-- Clayey dirt is a dirt that contains clay, but is not pure clay
register_dirts("Clayey")
-- Idem for silty dirt that contains silt without beeing pure silt
register_dirts("Silty")
-- And sandy dirt
register_dirts("Sandy")

-----------
-- Trees --
-----------

-- Credits / Notes
-- Banana tree: textures by demon_boy
-- Cherry Blossom tree: textures by demon_boy
-- Fir tree: Fir trees don't exist in the default game. Textures from Forest mod by Gael-de-Sailly

vmg.treelist = {
--	 treename			treedesc			leafname	leafdesc	leaftiles					fruitname	fruitdesc	droprarity	selbox									healthpoints
	{"banana",			"Banana",			"leaves",	"Leaves",	"banana_leaves",			"banana",	"Banana",	20,			{-0.35, -0.5, -0.35, 0.35, 0.5, 0.35},	3},
	{"cherry_blossom",	"Cherry Blossom",	"leaves",	"Leaves",	"cherry_blossom_leaves",	nil,		nil,		20,			nil,									nil},
	{"fir",				"Fir",				"needles",	"Needles",	"fir_leaves",				nil,		nil,		20,			nil,									nil},
}

for i in ipairs(vmg.treelist) do
	local treename = vmg.treelist[i][1]
	local treedesc = vmg.treelist[i][2]
	local leafname = vmg.treelist[i][3]
	local leafdesc = vmg.treelist[i][4]
	local leaftiles = vmg.treelist[i][5]
	local fruitname = vmg.treelist[i][6]
	local fruitdesc = vmg.treelist[i][7]
	local droprarity = vmg.treelist[i][8]
	local selbox = vmg.treelist[i][9]
	local healthpoints = vmg.treelist[i][10]

	minetest.register_node("valleys_mapgen:"..treename.."_tree", {
		description = treedesc.." Tree",
		tiles = {
			"vmg_"..treename.."_tree_top.png",
			"vmg_"..treename.."_tree_top.png",
			"vmg_"..treename.."_tree.png"
		},
		paramtype2 = "facedir",
		is_ground_content = true,
		groups = {tree=1,choppy=2,oddly_breakable_by_hand=1,flammable=2},
		sounds = default.node_sound_wood_defaults(),
		on_place = minetest.rotate_node,
	})

	minetest.register_node("valleys_mapgen:"..treename.."_wood", {
		description = treedesc.." Planks",
		tiles = {"vmg_"..treename.."_wood.png"},
		is_ground_content = true,
		groups = {choppy=2,oddly_breakable_by_hand=2,flammable=3,wood=1},
		sounds = default.node_sound_wood_defaults(),
	})

	minetest.register_craft({
		output = "valleys_mapgen:"..treename.."_wood 5",
		recipe = {
			{"valleys_mapgen:"..treename.."_tree"}
		}
	})

	minetest.register_node("valleys_mapgen:"..treename.."_sapling", {
		description = treedesc.." Sapling",
		drawtype = "plantlike",
		visual_scale = 1.0,
		tiles = {"vmg_"..treename.."_sapling.png"},
		inventory_image = "vmg_"..treename.."_sapling.png",
		wield_image = "vmg_"..treename.."_sapling.png",
		paramtype = "light",
		sunlight_propagates = true,
		walkable = false,
		selection_box = {
			type = "fixed",
			fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
		},
		groups = {snappy=2,dig_immediate=3,flammable=2,attached_node=1,sapling=1},
		sounds = default.node_sound_leaves_defaults(),
	})

	minetest.register_node("valleys_mapgen:"..treename.."_"..leafname.."", {
		description = treedesc.." "..leafdesc.."",
		drawtype = "allfaces_optional",
		waving = 1,
		visual_scale = 1.3,
		tiles = { "vmg_"..leaftiles..".png"},
		paramtype = "light",
		is_ground_content = false,
		groups = {snappy=3, leafdecay=7, flammable=2, leaves=1},
		drop = {
			max_items = 1,
			items = {
				{items = {"valleys_mapgen:"..treename.."_sapling"}, rarity = droprarity },
				{items = {"valleys_mapgen:"..treename.."_"..leafname..""} }
			}
		},
		sounds = default.node_sound_leaves_defaults(),
		after_place_node = default.after_place_leaves,
	})

	if fruitname then
		minetest.register_node("valleys_mapgen:"..fruitname.."", {
			description = fruitdesc,
			drawtype = "plantlike",
			visual_scale = 1.0,
			tiles = { "vmg_"..fruitname..".png" },
			inventory_image = "vmg_"..fruitname..".png",
			wield_image = "vmg_"..fruitname..".png",
			paramtype = "light",
			sunlight_propagates = true,
			walkable = false,
			is_ground_content = false,
			selection_box = {
				type = "fixed",
					fixed = selbox
			},
			groups = {fleshy=3,dig_immediate=3,flammable=2, leafdecay=3,leafdecay_drop=1},
			on_use = minetest.item_eat(healthpoints),
			sounds = default.node_sound_leaves_defaults(),
			after_place_node = function(pos, placer, itemstack)
				if placer:is_player() then
					minetest.set_node(pos, {name="valleys_mapgen:"..fruitname.."", param2=1})
				end
			end,
		})
	end

	if minetest.get_modpath("stairs") then
		stairs.register_stair_and_slab(
			"vmg_"..treename.."_tree",
			"valleys_mapgen:"..treename.."_tree",
			{snappy=1, choppy=2, oddly_breakable_by_hand=1, flammable=2 },
			{	"vmg_"..treename.."_tree_top.png",
				"vmg_"..treename.."_tree_top.png",
				"vmg_"..treename.."_tree.png"
			},
			treedesc.." Tree Stair",
			treedesc.." Tree Slab",
			default.node_sound_wood_defaults()
		)
		stairs.register_stair_and_slab(
			"vmg_"..treename.."_wood",
			"valleys_mapgen:"..treename.."_wood",
			{ snappy=1, choppy=2, oddly_breakable_by_hand=2, flammable=3 },
			{"vmg_"..treename.."_wood.png" },
			treedesc.." Planks Stair",
			treedesc.." Planks Slab",
			default.node_sound_wood_defaults()
		)
	end

end


----------------------
-- Flowers / Plants --
----------------------

minetest.register_node("valleys_mapgen:bird_of_paradise", {
	description = "Bird of Paradise",
	drawtype = "plantlike",
	tiles = {"vmg_bird_of_paradise.png"},
	inventory_image = "vmg_bird_of_paradise.png",
	paramtype = "light",
	walkable = false,
	visual_scale = 1.2,
	groups = {snappy=3,flammable=2,flora=1,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.3125, 0.5},
	},
})

minetest.register_node("valleys_mapgen:gerbera", {
	description = "Gerbera",
	drawtype = "plantlike",
	tiles = {"vmg_gerbera.png"},
	inventory_image = "vmg_gerbera.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	groups = {snappy=3,flammable=2,flower=1,flora=1,attached_node=1,color_pink=1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.15, -0.5, -0.15, 0.15, 0.2, 0.15},
	},
})

minetest.register_node("valleys_mapgen:hibiscus", {
	description = "White Hibiscus",
	drawtype = "plantlike",
	tiles = {"vmg_hibiscus.png"},
	inventory_image = "vmg_hibiscus.png",
	paramtype = "light",
	walkable = false,
	waving = 1,
	groups = {snappy=3,flammable=2,flower=1,flora=1,attached_node=1,color_white=1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.3125, 0.5},
	},
})

minetest.register_node("valleys_mapgen:orchid", {
	description = "Orchid",
	drawtype = "plantlike",
	tiles = {"vmg_orchid.png"},
	inventory_image = "vmg_orchid.png",
	paramtype = "light",
	walkable = false,
	waving = 1,
	groups = {snappy=3,flammable=2,flower=1,flora=1,attached_node=1,color_white=1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.3125, 0.5},
	},
})



minetest.register_node("valleys_mapgen:huge_mushroom_cap", {
	description = "Huge Mushroom Cap",
	tiles = {"vmg_mushroom_giant_cap.png", "vmg_mushroom_giant_under.png", "vmg_mushroom_giant_cap.png"},
	is_ground_content = false,
	paramtype = "light",
	drawtype = "nodebox",
	node_box = { type = "fixed", 
		fixed = {
			{-0.5, -0.5, -0.33, 0.5, -0.33, 0.33}, 
			{-0.33, -0.5, 0.33, 0.33, -0.33, 0.5}, 
			{-0.33, -0.5, -0.33, 0.33, -0.33, -0.5}, 
			{-0.33, -0.33, -0.33, 0.33, -0.17, 0.33}, 
		} },
	light_source = 4,
	groups = {oddly_breakable_by_hand=1, dig_immediate=3, flammable=2, plant=1, leafdecay=1},
})

minetest.register_node("valleys_mapgen:giant_mushroom_cap", {
	description = "Giant Mushroom Cap",
	tiles = {"vmg_mushroom_giant_cap.png", "vmg_mushroom_giant_under.png", "vmg_mushroom_giant_cap.png"},
	is_ground_content = false,
	paramtype = "light",
	drawtype = "nodebox",
	node_box = { type = "fixed", 
		fixed = {
			{-0.4, -0.5, -0.4, 0.4, 0.0, 0.4},
			{-0.75, -0.5, -0.4, -0.4, -0.25, 0.4},
			{0.4, -0.5, -0.4, 0.75, -0.25, 0.4},
			{-0.4, -0.5, -0.75, 0.4, -0.25, -0.4},
			{-0.4, -0.5, 0.4, 0.4, -0.25, 0.75},
		} },
	light_source = 8,
	groups = {oddly_breakable_by_hand=1, dig_immediate=3, flammable=2, plant=1, leafdecay=1},
})

minetest.register_node("valleys_mapgen:giant_mushroom_stem", {
	description = "Giant Mushroom Stem",
	tiles = {"vmg_mushroom_giant_under.png", "vmg_mushroom_giant_under.png", "vmg_mushroom_giant_stem.png"},
	is_ground_content = false,
	groups = {tree=1,choppy=2,oddly_breakable_by_hand=1,flammable=2, plant=1},
	sounds = default.node_sound_wood_defaults(),
	paramtype = "light",
	drawtype = "nodebox",
	node_box = { type = "fixed", fixed = { {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25}, }},
})

minetest.register_craft({
	output = "default:wood",
	recipe = {
		{"valleys_mapgen:giant_mushroom_stem"}
	}
})

minetest.register_craftitem("valleys_mapgen:mushroom_steak", {
	description = "Mushroom Steak",
	inventory_image = "vmg_mushroom_steak.png",
	on_use = minetest.item_eat(4),
})

minetest.register_craft({
	type = "cooking",
	output = "valleys_mapgen:mushroom_steak",
	recipe = "valleys_mapgen:huge_mushroom_cap",
	cooktime = 2,
})

minetest.register_craft({
	type = "cooking",
	output = "valleys_mapgen:mushroom_steak 2",
	recipe = "valleys_mapgen:giant_mushroom_cap",
	cooktime = 2,
})

minetest.register_node("valleys_mapgen:glowing_fungal_stone", {
	description = "Glowing Fungal Stone",
	tiles = {"default_stone.png^vmg_glowing_fungal.png",},
	is_ground_content = true,
	light_source = 8,
	groups = {cracky=3, stone=1},
	drop = {items={ {items={"default:cobble"},}, {items={"valleys_mapgen:glowing_fungus",},},},},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("valleys_mapgen:glowing_fungus", {
	description = "Glowing Fungus",
	inventory_image = "vmg_glowing_fungus.png",
})

minetest.register_node("valleys_mapgen:moon_juice", {
	description = "Moon Juice",
	inventory_image = "vmg_moon_juice.png",
})

minetest.register_node("valleys_mapgen:moon_glass", {
	description = "Moon Glass",
	drawtype = "glasslike",
	tiles = {"default_glass.png",},
	is_ground_content = true,
	light_source = 14,
	groups = {cracky=3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_craft({
	output = "valleys_mapgen:moon_juice",
	recipe = {
		{"valleys_mapgen:glowing_fungus", "valleys_mapgen:glowing_fungus", "valleys_mapgen:glowing_fungus"},
		{"valleys_mapgen:glowing_fungus", "valleys_mapgen:glowing_fungus", "valleys_mapgen:glowing_fungus"},
		{"valleys_mapgen:glowing_fungus", "vessels:glass_bottle", "valleys_mapgen:glowing_fungus"},
	},
})

minetest.register_craft({
	output = "valleys_mapgen:moon_glass",
	recipe = {
		{"", "valleys_mapgen:moon_juice", ""},
		{"", "valleys_mapgen:moon_juice", ""},
		{"", "default:glass", ""},
	},
})

minetest.register_node("valleys_mapgen:stalactite", {
	description = "Stalactite",
	tiles = {"default_stone.png"},
	is_ground_content = false,
	walkable = false,
	paramtype = "light",
	drawtype = "nodebox",
	node_box = { type = "fixed", 
		fixed = {
			{-0.07, 0.0, -0.07, 0.07, 0.5, 0.07}, 
			{-0.04, -0.25, -0.04, 0.04, 0.0, 0.04}, 
			{-0.02, -0.5, -0.02, 0.02, 0.25, 0.02}, 
		} },
	groups = {stone=1, cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("valleys_mapgen:stalagmite", {
	description = "Stalagmite",
	tiles = {"default_stone.png"},
	is_ground_content = false,
	walkable = false,
	paramtype = "light",
	drawtype = "nodebox",
	node_box = { type = "fixed", 
		fixed = {
			{-0.07, -0.5, -0.07, 0.07, 0.0, 0.07}, 
			{-0.04, 0.0, -0.04, 0.04, 0.25, 0.04}, 
			{-0.02, 0.25, -0.02, 0.02, 0.5, 0.02}, 
		} },
	groups = {stone=1, cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

-- Change leafdecay ratings
minetest.add_group("default:leaves", {leafdecay = 5})
minetest.add_group("default:jungleleaves", {leafdecay = 8})
minetest.add_group("default:pine_needles", {leafdecay = 7})
