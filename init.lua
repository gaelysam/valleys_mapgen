vmg = {}
vmg.version = "1.1"

local path = minetest.get_modpath("valleys_mapgen")

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

vmg.settings = Settings(minetest.get_worldpath() .. "/vmg.conf")

local version = vmg.settings:get("version")
if not version then
	vmg.settings:set("version", vmg.version)
	dofile(path .. "/mapgen.lua")
elseif version == vmg.version then
	dofile(path .. "/mapgen.lua")
else
	dofile(path .. "/old_mapgens/" .. version .. ".lua")
end

vmg.settings:write()

minetest.register_on_generated(vmg.generate)
minetest.register_on_newplayer(vmg.spawnplayer)

minetest.override_item("default:water_source", {liquid_renewable = false})
minetest.override_item("default:water_flowing", {liquid_renewable = false})
