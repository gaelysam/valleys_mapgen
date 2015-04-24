vmg.settings = Settings(minetest.get_worldpath() .. "/vmg.conf")

local function define_str(flag, default, write_to_config)
	local value = vmg.settings:get(flag)
	if value then
		return value, true
	else
		local on_config = minetest.setting_get("vmg_" .. flag)
		if on_config then
			vmg.settings:set(flag, on_config)
			return on_config, false
		else
			if write_to_config then
				minetest.setting_set("vmg_" .. flag, default)
			end
			vmg.settings:set(flag, default)
			return default, false
		end
	end
end

local function define_num(flag, default, write_to_config)
	local value = vmg.settings:get(flag)
	if value then
		return tonumber(value), true
	else
		local on_config = minetest.setting_get("vmg_" .. flag)
		if on_config then
			vmg.settings:set(flag, on_config)
			return tonumber(on_config), false
		else
			if write_to_config then
				minetest.setting_set("vmg_" .. flag, default)
			end
			vmg.settings:set(flag, default)
			return default, false
		end
	end
end

local function define_bool(flag, default, write_to_config)
	local value = vmg.settings:get_bool(flag)
	if value ~= nil then
		return value, true
	else
		local on_config = minetest.setting_getbool("vmg_" .. flag)
		if on_config ~= nil then
			vmg.settings:set(flag, tostring(on_config))
			return on_config, false
		else
			if write_to_config then
				minetest.setting_setbool("vmg_" .. flag, default)
			end
			vmg.settings:set(flag, tostring(default))
			return default, false
		end
	end
end

local function define_noise(flag, default, write_to_config)
	local value = vmg.settings:get(flag)
	if value then
		return vmg.string_to_noise(value), true
	else
		local on_config = minetest.setting_get("vmg_" .. flag)
		if on_config then
			vmg.settings:set(flag, on_config)
			return vmg.string_to_noise(on_config), false
		else
			local str_default = vmg.noise_to_string(default)
			if write_to_config then
				minetest.setting_set("vmg_" .. flag, str_default)
			end
			vmg.settings:set(flag, str_default)
			return default, false
		end
	end
end

function vmg.define(flag, default, write_to_config)
	local typeval = type(default)
	if typeval == "string" then
		return define_str(flag, default, write_to_config)
	elseif typeval == "number" then
		return define_num(flag, default, write_to_config)
	elseif typeval == "boolean" then
		return define_bool(flag, default, write_to_config)
	elseif typeval == "table" then
		return define_noise(flag, default, write_to_config)
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
	for line in str:gmatch("[%d%.%-e]+") do
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

if vmg.loglevel >= 2 then
	print("[Valleys Mapgen] Loading mapgen ...")
end

-- Choose the appropriate mapgen version

local version = vmg.define("version", vmg.version)
if version == vmg.version then
	dofile(vmg.path .. "/mapgen.lua")
else
	dofile(vmg.path .. "/old_mapgens/" .. version .. ".lua")
end

vmg.settings:write()
