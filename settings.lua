vmg.settings = Settings(minetest.get_worldpath() .. "/vmg.conf") -- Create settings object

local function define_str(flag, default, write_to_config)
	local value = vmg.settings:get(flag)
	if value then -- This flag exists in vmg.conf, return its value
		return value, true
	else
		local on_config = minetest.setting_get("vmg_" .. flag) -- get this flag in minetest.conf
		if on_config then -- This flag exists in minetest.conf, so return its value
			vmg.settings:set(flag, on_config)
			return on_config, false
		else -- Flag don't exist anywhere, so the default value will be written in settings and returned
			if write_to_config then
				minetest.setting_set("vmg_" .. flag, default) -- write to minetest.conf if write_to_config is enabled (usually disabled)
			end
			vmg.settings:set(flag, default) -- write to vmg.conf
			return default, false -- return default value
		end
	end
end

local function define_num(flag, default, write_to_config)
	local value = vmg.settings:get(flag)
	if value then -- This flag exists in vmg.conf, return its value
		return tonumber(value), true
	else
		local on_config = minetest.setting_get("vmg_" .. flag) -- get this flag in minetest.conf
		if on_config then -- This flag exists in minetest.conf, so return its value
			vmg.settings:set(flag, on_config)
			return tonumber(on_config), false
		else -- Flag don't exist anywhere, so the default value will be written in settings and returned
			if write_to_config then
				minetest.setting_set("vmg_" .. flag, default) -- write to minetest.conf if write_to_config is enabled (usually disabled)
			end
			vmg.settings:set(flag, default) -- write to vmg.conf
			return default, false -- return default value
		end
	end
end

local function define_bool(flag, default, write_to_config)
	local value = vmg.settings:get_bool(flag)
	if value ~= nil then -- This flag exists in vmg.conf, return its value
		return value, true
	else
		local on_config = minetest.setting_getbool("vmg_" .. flag) -- get this flag in minetest.conf
		if on_config ~= nil then -- This flag exists in minetest.conf, so return its value
			vmg.settings:set(flag, tostring(on_config))
			return on_config, false
		else -- Flag don't exist anywhere, so the default value will be written in settings and returned
			if write_to_config then
				minetest.setting_setbool("vmg_" .. flag, default) -- write to minetest.conf if write_to_config is enabled (usually disabled)
			end
			vmg.settings:set(flag, tostring(default)) -- write to vmg.conf
			return default, false -- return default value
		end
	end
end

local function define_noise(flag, default, write_to_config)
	local value = vmg.settings:get(flag)
	if value then -- This flag exists in vmg.conf, return its value
		return vmg.string_to_noise(value), true
	else
		local on_config = minetest.setting_get("vmg_" .. flag) -- get this flag in minetest.conf
		if on_config then -- This flag exists in minetest.conf, so return its value
			vmg.settings:set(flag, on_config)
			return vmg.string_to_noise(on_config), false
		else -- Flag don't exist anywhere, so the default value will be written in settings and returned
			local str_default = vmg.noise_to_string(default)
			if write_to_config then
				minetest.setting_set("vmg_" .. flag, str_default) -- write to minetest.conf if write_to_config is enabled (usually disabled)
			end
			vmg.settings:set(flag, str_default) -- write to vmg.conf
			return default, false -- return default value
		end
	end
end

function vmg.define(flag, default, write_to_config)
	local typeval = type(default) -- Select function from the type of the default value
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

-- Write settings after loading
minetest.after(0, function() vmg.settings:write() end)
