vmg = {}
vmg.version = "2.3"

vmg.path = minetest.get_modpath("valleys_mapgen")

vmg.loglevel = tonumber(minetest.setting_get("vmg_log_level") or 0)

if vmg.loglevel >= 2 then
	print("[Valleys Mapgen] Loading basic functions ...")
end

-- Set mapgen parameters to singlenode
minetest.register_on_mapgen_init(function(mgparams)
	minetest.set_mapgen_params({mgname="singlenode", flags="nolight"})
end)

-- public function made by the default mod, to register ores and blobs
if default then
	if default.register_ores then
		default.register_ores()
	end
	if default.register_blobs then
		default.register_blobs()
	end
end

-- useful function to convert a 3D pos to 2D
function pos2d(pos)
	if type(pos) == "number" then
		return {x = pos, y = pos}
	elseif pos.z then
		return {x = pos.x, y = pos.z}
	else
		return {x = pos.x, y = pos.y}
	end
end

-- useful function to convert a 2D pos to 3D
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

vmg.registered_on_first_mapgen = {}

function vmg.register_on_first_mapgen(func) -- Callback
	table.insert(vmg.registered_on_first_mapgen, func)
end

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

function displaytime(time)
	return math.floor(time * 1000000 + 0.5) / 1000 .. " ms"
end

if vmg.loglevel >= 2 then
	print("[Valleys Mapgen] Loading settings API ...")
end

-- Settings are handled by a separate file, settings.lua
-- This file will also run the appropriate mapgen file, according to the vmg_version setting
dofile(vmg.path .. "/settings.lua")

-- The mapgen file contains a mapgen function and a spawnplayer function. So, set the spawnplayer function on newplayer and on respawnplayer.
if vmg.define("spawn", true) then
	minetest.register_on_newplayer(vmg.spawnplayer)
end

if vmg.define("respawn", true) then
	minetest.register_on_respawnplayer(vmg.spawnplayer)
end

-- Call the mapgen function vmg.generate on mapgen.
--  Inserting helps to ensure that vmg operates first.
table.insert(minetest.registered_on_generateds, 1, vmg.generate)

if vmg.loglevel >= 2 then
	print("[Valleys Mapgen] Loading nodes ...")
end

-- Node definitions
dofile(vmg.path .. "/nodes.lua")

if vmg.loglevel >= 1 then
	print("[Valleys Mapgen] Loaded !")
end
