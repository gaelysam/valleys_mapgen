vmg = {}
vmg.version = "1.2"

vmg.path = minetest.get_modpath("valleys_mapgen")

minetest.register_on_mapgen_init(function(mgparams)
	minetest.set_mapgen_params({mgname="singlenode", flags="nolight"})
end)

if default then
	if default.register_ores then
		default.register_ores()
	end
	if default.register_blobs then
		default.register_blobs()
	end
end

function pos2d(pos)
	if type(pos) == "number" then
		return {x = pos, y = pos}
	elseif pos.z then
		return {x = pos.x, y = pos.z}
	else
		return {x = pos.x, y = pos.y}
	end
end

function pos3d(pos, alt)
	alt = alt or 0
	if type(pos) == "number" then
		return {x = pos, y = pos, z = pos}
	elseif pos.z then
		return {x = pos.x, y = pos.z, z = pos.z}
	else
		return {x = pos.x, y = alt, z = pos.y}
	end
end

dofile(vmg.path .. "/settings.lua")

minetest.register_on_generated(vmg.generate)
minetest.register_on_newplayer(vmg.spawnplayer)

minetest.override_item("default:water_source", {liquid_renewable = false})
minetest.override_item("default:water_flowing", {liquid_renewable = false})
