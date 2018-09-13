vmg.settings = Settings(minetest.get_worldpath() .. "/vmg.conf") -- Create settings object

local function define_str(flag, default, write_to_config)
	local value = vmg.settings:get(flag)
	if value then -- This flag exists in vmg.conf, return its value
		return value, true
	else
		local on_config = minetest.settings:get("vmg_" .. flag) -- get this flag in minetest.conf
		if on_config then -- This flag exists in minetest.conf, so return its value
			vmg.settings:set(flag, on_config)
			return on_config, false
		else -- Flag don't exist anywhere, so the default value will be written in settings and returned
			if write_to_config then
				minetest.settings:set("vmg_" .. flag, default) -- write to minetest.conf if write_to_config is enabled (usually disabled)
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
		local on_config = minetest.settings:get("vmg_" .. flag) -- get this flag in minetest.conf
		if on_config then -- This flag exists in minetest.conf, so return its value
			vmg.settings:set(flag, on_config)
			return tonumber(on_config), false
		else -- Flag don't exist anywhere, so the default value will be written in settings and returned
			if write_to_config then
				minetest.settings:set("vmg_" .. flag, default) -- write to minetest.conf if write_to_config is enabled (usually disabled)
			end
			vmg.settings:set(flag, default) -- write to vmg.conf
			return tonumber(default), false -- return default value
		end
	end
end

local function define_bool(flag, default, write_to_config)
	local value = vmg.settings:get_bool(flag)
	if value then -- This flag exists in vmg.conf, return its value
		return value, true
	else
		local on_config = minetest.settings:get_bool("vmg_" .. flag) -- get this flag in minetest.conf
		if on_config then -- This flag exists in minetest.conf, so return its value
			vmg.settings:set_bool(flag, on_config)
			return on_config, false
		else -- Flag don't exist anywhere, so the default value will be written in settings and returned
			if write_to_config then
				minetest.settings:set_bool("vmg_" .. flag, default) -- write to minetest.conf if write_to_config is enabled (usually disabled)
			end
			vmg.settings:set_bool(flag, default) -- write to vmg.conf
			return default, false -- return default value
		end
	end
end

local function define_noise(flag, default, write_to_config)
	local value = vmg.settings:get_np_group(flag)
	if value then -- This flag exists in vmg.conf, return its value
		return value, true
	else
		local on_config = minetest.settings:get_np_group("vmg_" .. flag) -- get this flag in minetest.conf
		if on_config then -- This flag exists in minetest.conf, so return its value
			vmg.settings:set_np_group(flag, on_config)
			return on_config, false
		else -- Flag don't exist anywhere, so the default value will be written in settings and returned
			if write_to_config then
				minetest.settings:set_np_group("vmg_" .. flag, default) -- write to minetest.conf if write_to_config is enabled (usually disabled)
			end
			vmg.settings:set_np_group(flag, default) -- write to vmg.conf
			return default, false -- return default value
		end
	end
end

local definefunc = {
	string = define_str,
	number = define_num,
	boolean = define_bool,
	table = define_noise,
}

function vmg.define(flag, default, write_to_config)
	local typeval = type(default) -- Select function from the type of the default value
	local f = definefunc[typeval] -- Choose the appropriate function
	if f then
		return f(flag, default, write_to_config)
	end
end

if vmg.loglevel >= 2 then
	print("[Valleys Mapgen] Loading mapgen ...")
end

-- Choose the appropriate mapgen version

local version = vmg.define("version", vmg.version)
if vmg.valleys_c then
	dofile(vmg.path .. "/mapgen_c.lua")
elseif version == vmg.version then
	dofile(vmg.path .. "/mapgen.lua")
else
	dofile(vmg.path .. "/old_mapgens/" .. version .. ".lua")
end

-- Write settings after loading
minetest.after(0, function() vmg.settings:write() end)
