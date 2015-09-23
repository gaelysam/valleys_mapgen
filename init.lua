vmg = {}
vmg.version = "3.0"

vmg.path = minetest.get_modpath("valleys_mapgen_c")

-- Modify a node to add a group
function minetest.add_group(node, groups)
	local def = minetest.registered_items[node]
	if not def then
		return false
	end
	local def_groups = def.groups or {}
	for group, value in pairs(groups) do
		if value ~= 0 then
			def_groups[group] = value
		else
			def_groups[group] = nil
		end
	end
	minetest.override_item(node, {groups = def_groups})
	return true
end

--dofile(vmg.path.."/biomes.lua")
dofile(vmg.path.."/deco.lua")
dofile(vmg.path.."/nodes.lua")
dofile(vmg.path.."/mapgen.lua")
--dofile(vmg.path.."/traditional.lua")

-- Call the mapgen function vmg.generate on mapgen.
minetest.register_on_generated(vmg.generate)

print("Valleys Mapgen C loaded")

