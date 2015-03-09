vmg.settings = Settings(minetest.get_worldpath() .. "/vmg.conf")

function vmg.define(flag, default)
	local value = vmg.settings:get(flag)
	if value then
		return value, true
	else
		vmg.settings:set(flag, default)
		return default, false
	end
end

function vmg.noise_to_string(n)
	return n.offset ..
		", " .. n.scale ..
		", " .. minetest.pos_to_string(n.spread) ..
		", " .. n.seed ..
		", " .. n.octaves ..
		", " .. n.persist ..
		", " .. n.lacunarity
end

function vmg.string_to_noise(str)
	local t = {}
	for line in str:gmatch("[%d%.%-]+") do
		table.insert(t, tonumber(line))
	end
	return {
		offset = t[1],
		scale = t[2],
		spread = {x=t[3], y=t[4], z=t[5]},
		seed = t[6],
		octaves = t[7],
		persist = t[8],
		lacunarity = t[9],
	}
end

-- Choose the appropriate mapgen version

local version = vmg.define("version", vmg.version)
if version == vmg.version then
	dofile(vmg.path .. "/mapgen.lua")
else
	dofile(vmg.path .. "/old_mapgens/" .. version .. ".lua")
end

vmg.settings:write()
