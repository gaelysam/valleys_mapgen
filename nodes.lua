-- clone node from VanessaE's moretrees
--  https://github.com/VanessaE/moretrees
function vmg.clone_node(name)
	local node2 = {}
	local node = minetest.registered_nodes[name]
	for k,v in pairs(node) do
		node2[k]=v
	end
	return node2
end


-- Set the liquid range according to settings (by default 3)
local waterflow = vmg.define("waterflow", 3)

minetest.override_item("default:river_water_source", {liquid_range = waterflow})
minetest.override_item("default:river_water_flowing", {liquid_range = waterflow})

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
-- Birch tree: textures from Forest mod by Gael-de-Sailly
-- Cherry Blossom tree: textures by demon_boy
-- Mangrove tree: textures by demon_boy
-- Fir tree: Fir trees don't exist in the default game. Textures from Forest mod by Gael-de-Sailly
-- Willow tree: textures from Forest mod by Gael-de-Sailly

-- a list of tree descriptions
vmg.treelist = {
	{name="banana",
	 desc="Banana",
	 leaf="leaves",
	 leaf_desc="Leaves",
	 leaf_tile="banana_leaves",
	 fruit="banana",
	 fruit_desc="Banana",
	 drop_rarity=20,
	 selbox={-0.35, -0.5, -0.35, 0.35, 0.5, 0.35},
	 health=3,
	 trunk_dia=0.75},
	{name="birch",
	 desc="Birch",
	 leaf="leaves",
	 leaf_desc="Leaves",
	 leaf_tile="birch_leaves",
	 drop_rarity=20,
	 trunk_dia=0.5},
	{name="cherry_blossom",
	 desc="Cherry Blossom",
	 leaf="leaves",
	 leaf_desc="Leaves",
	 leaf_tile="cherry_blossom_leaves",
	 drop_rarity=20,
	 trunk_dia=0.5},
	{name="fir",
	 desc="Fir",
	 leaf="needles",
	 leaf_desc="Needles",
	 leaf_tile="fir_leaves",
	 drop_rarity=20,
	 trunk_dia=1.0},
	{name="mangrove",
	 desc="Mangrove",
	 leaf="leaves",
	 leaf_desc="Leaves",
	 leaf_tile="mangrove_leaves",
	 drop_rarity=20,
	 trunk_dia=0.5},
	{name="willow",
	 desc="Willow",
	 leaf="leaves",
	 leaf_desc="Leaves",
	 leaf_tile="willow_leaves",
	 drop_rarity=20,
	 trunk_dia=1.0},
}

for _, tree in ipairs(vmg.treelist) do
	-- a standard node description
	local node_d = {
		description = tree.desc.." Tree",
		tiles = {
			"vmg_"..tree.name.."_tree_top.png",
			"vmg_"..tree.name.."_tree_top.png",
			"vmg_"..tree.name.."_tree.png"
		},
		paramtype2 = "facedir",
		is_ground_content = true,
		groups = {tree=1,choppy=2,oddly_breakable_by_hand=1,flammable=2},
		sounds = default.node_sound_wood_defaults(),
		on_place = minetest.rotate_node,
	}
	-- Some trunks aren't a meter wide.
	if tree.trunk_dia and tree.trunk_dia ~= 1 then
		local radius = tree.trunk_dia / 2
		node_d.paramtype = "light"
		node_d.drawtype = "nodebox"
		node_d.node_box = { type = "fixed", 
			fixed = { {-radius, -0.5, -radius, radius, 0.5, radius}, }
		}
	end
	minetest.register_node("valleys_mapgen:"..tree.name.."_tree", node_d)

	-- planks that come from the tree
	minetest.register_node("valleys_mapgen:"..tree.name.."_wood", {
		description = tree.desc.." Planks",
		tiles = {"vmg_"..tree.name.."_wood.png"},
		is_ground_content = true,
		groups = {choppy=2,oddly_breakable_by_hand=2,flammable=3,wood=1},
		sounds = default.node_sound_wood_defaults(),
	})

	-- how to get the planks
	minetest.register_craft({
		output = "valleys_mapgen:"..tree.name.."_wood 5",
		recipe = {
			{"valleys_mapgen:"..tree.name.."_tree"}
		}
	})

	-- the tree's sapling form
	minetest.register_node("valleys_mapgen:"..tree.name.."_sapling", {
		description = tree.desc.." Sapling",
		drawtype = "plantlike",
		visual_scale = 1.0,
		tiles = {"vmg_"..tree.name.."_sapling.png"},
		inventory_image = "vmg_"..tree.name.."_sapling.png",
		wield_image = "vmg_"..tree.name.."_sapling.png",
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

	-- leaves for the tree
	minetest.register_node("valleys_mapgen:"..tree.name.."_"..tree.leaf.."", {
		description = tree.desc.." "..tree.leaf_desc.."",
		drawtype = "allfaces_optional",
		waving = 1,
		visual_scale = 1.3,
		tiles = { "vmg_"..tree.leaf_tile..".png"},
		paramtype = "light",
		is_ground_content = false,
		groups = {snappy=3, leafdecay=7, flammable=2, leaves=1},
		drop = {
			max_items = 1,
			items = {
				{items = {"valleys_mapgen:"..tree.name.."_sapling"}, rarity = tree.drop_rarity },
				{items = {"valleys_mapgen:"..tree.name.."_"..tree.leaf..""} }
			}
		},
		sounds = default.node_sound_leaves_defaults(),
		after_place_node = default.after_place_leaves,
	})

	-- appropriate fruit
	if tree.fruit then
		minetest.register_node("valleys_mapgen:"..tree.fruit.."", {
			description = tree.fruit_desc,
			drawtype = "plantlike",
			visual_scale = 1.0,
			tiles = { "vmg_"..tree.fruit..".png" },
			inventory_image = "vmg_"..tree.fruit..".png",
			wield_image = "vmg_"..tree.fruit..".png",
			paramtype = "light",
			sunlight_propagates = true,
			walkable = false,
			is_ground_content = false,
			selection_box = {
				type = "fixed",
					fixed = tree.selbox
			},
			groups = {fleshy=3,dig_immediate=3,flammable=2, leafdecay=3,leafdecay_drop=1},
			-- Fruit makes you healthy.
			on_use = minetest.item_eat(tree.health),
			sounds = default.node_sound_leaves_defaults(),
			after_place_node = function(pos, placer, itemstack)
				if placer:is_player() then
					minetest.set_node(pos, {name="valleys_mapgen:"..tree.fruit.."", param2=1})
				end
			end,
		})
	end

	-- appropriate wooden stairs and slabs
	if minetest.get_modpath("stairs") then
		stairs.register_stair_and_slab(
			"vmg_"..tree.name.."_tree",
			"valleys_mapgen:"..tree.name.."_tree",
			{snappy=1, choppy=2, oddly_breakable_by_hand=1, flammable=2 },
			{	"vmg_"..tree.name.."_tree_top.png",
				"vmg_"..tree.name.."_tree_top.png",
				"vmg_"..tree.name.."_tree.png"
			},
			tree.desc.." Tree Stair",
			tree.desc.." Tree Slab",
			default.node_sound_wood_defaults()
		)
		stairs.register_stair_and_slab(
			"vmg_"..tree.name.."_wood",
			"valleys_mapgen:"..tree.name.."_wood",
			{ snappy=1, choppy=2, oddly_breakable_by_hand=2, flammable=3 },
			{"vmg_"..tree.name.."_wood.png" },
			tree.desc.." Planks Stair",
			tree.desc.." Planks Slab",
			default.node_sound_wood_defaults()
		)
	end

end


----------------------
-- Flowers / Plants --
----------------------

-- Credits / Notes
-- Arrow Arum: texture by demon_boy
-- Bird of Paradise: texture by demon_boy
-- Calla Lily: texture by demon_boy
-- Gerbera: texture by demon_boy
-- Hibiscus: texture by demon_boy
-- Mangrove Fern: texture by demon_boy
-- Orchid: texture by demon_boy

vmg.plantlist = {
--	 plantname				plantdesc			plantwave	plantlight	plantgroup			selbox
	{"arrow_arum",			"Arrow Arum",		1,			"false",	"plantnodye",		{-0.5, -0.5, -0.5, 0.5, -0.3125, 0.5}},
	{"bird_of_paradise",	"Bird of Paradise",	0, 			"true",		"flowernodye",		{-0.5, -0.5, -0.5, 0.5, -0.3125, 0.5}},
	{"calla_lily",			"Calla Lily",		1,			"true",		"flowerwhitedye",	{-0.5, -0.5, -0.5, 0.5, -0.3125, 0.5}},
	{"gerbera",				"Gerbera",			0,			"true",		"flowerpinkdye",	{-0.15, -0.5, -0.15, 0.15, 0.2, 0.15}},
	{"hibiscus",			"Hibiscus",			1,			"false",	"flowerwhitedye",	{-0.5, -0.5, -0.5, 0.5, -0.3125, 0.5}},
	{"mangrove_fern",		"Mangrove Fern",	1,			"false",	"flowernodye",		{-0.5, -0.5, -0.5, 0.5, -0.3125, 0.5}},
	{"orchid",				"Orchid",			1,			"true",		"flowerwhitedye",	{-0.5, -0.5, -0.5, 0.5, -0.3125, 0.5}},
}

for i in ipairs(vmg.plantlist) do
	local plantname = vmg.plantlist[i][1]
	local plantdesc = vmg.plantlist[i][2]
	local plantwave = vmg.plantlist[i][3]
	local plantlight = vmg.plantlist[i][4]
	local plantgroup = vmg.plantlist[i][5]
	local selbox = vmg.plantlist[i][6]

	--group definitions
	if vmg.plantlist[i][5] == "plantnodye" then
		plantgroups = {snappy=3,flammable=2,flora=1,attached_node=1}
	elseif vmg.plantlist[i][5] == "flowernodye" then
		plantgroups = {snappy=3,flammable=2,flower=1,flora=1,attached_node=1}
	elseif vmg.plantlist[i][5] == "flowerpinkdye" then
		plantgroups = {snappy=3,flammable=2,flower=1,flora=1,attached_node=1,color_pink=1}
	elseif vmg.plantlist[i][5] == "flowerwhitedye" then
		plantgroups = {snappy=3,flammable=2,flower=1,flora=1,attached_node=1,color_white=1}
	end

	minetest.register_node("valleys_mapgen:"..plantname.."", {
		description = plantdesc,
		drawtype = "plantlike",
		tiles = {"vmg_"..plantname..".png"},
		inventory_image = "vmg_"..plantname..".png",
		waving = plantwave,
		sunlight_propagates = plantlight,
		paramtype = "light",
		walkable = false,
		groups = plantgroups,
		sounds = default.node_sound_leaves_defaults(),
		selection_box = {
			type = "fixed",
			fixed = selbox,
		},
	})

end


minetest.register_node("valleys_mapgen:mangrove_roots", {
	description = "Mangrove Roots",
	drawtype = "plantlike",
	tiles = {"vmg_mangrove_roots.png"},
	paramtype = "light",
	is_ground_content = true,
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=1,flammable=2},
	sounds = default.node_sound_wood_defaults(),
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


-- Make some new leaves with the same properties.
local newnode = vmg.clone_node("default:leaves")
newnode.tiles = {"default_leaves.png^[colorize:#FF0000:20"}
minetest.register_node("valleys_mapgen:leaves2", newnode)
newnode.tiles = {"default_leaves.png^[colorize:#FFFF00:20"}
minetest.register_node("valleys_mapgen:leaves3", newnode)
newnode.tiles = {"default_leaves.png^[colorize:#00FFFF:20"}
minetest.register_node("valleys_mapgen:leaves4", newnode)
newnode.tiles = {"default_leaves.png^[colorize:#00FF00:20"}
minetest.register_node("valleys_mapgen:leaves5", newnode)
