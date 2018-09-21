vmg.settings = Settings(minetest.get_worldpath() .. "/vmg.conf") -- Create settings object

local function define_str(flag, default, config_name)
	local value = vmg.settings:get(flag)
	if value then -- This flag exists in vmg.conf, return its value
		return value, true
	else
		local on_config = minetest.settings:get(config_name or "vmg_" .. flag) -- get this flag in minetest.conf
		if on_config then -- This flag exists in minetest.conf, so return its value
			vmg.settings:set(flag, on_config)
			return on_config, false
		else -- Flag don't exist anywhere, so the default value will be written in settings and returned
			vmg.settings:set(flag, default) -- write to vmg.conf
			return default, false -- return default value
		end
	end
end

local function define_num(flag, default, config_name)
	local value = vmg.settings:get(flag)
	if value then -- This flag exists in vmg.conf, return its value
		return tonumber(value), true
	else
		local on_config = minetest.settings:get(config_name or "vmg_" .. flag) -- get this flag in minetest.conf
		if on_config then -- This flag exists in minetest.conf, so return its value
			vmg.settings:set(flag, on_config)
			return tonumber(on_config), false
		else -- Flag don't exist anywhere, so the default value will be written in settings and returned
			vmg.settings:set(flag, default) -- write to vmg.conf
			return tonumber(default), false -- return default value
		end
	end
end

local function define_bool(flag, default, config_name)
	local value = vmg.settings:get_bool(flag)
	if value then -- This flag exists in vmg.conf, return its value
		return value, true
	else
		local on_config = minetest.settings:get_bool(config_name or "vmg_" .. flag) -- get this flag in minetest.conf
		if on_config then -- This flag exists in minetest.conf, so return its value
			vmg.settings:set_bool(flag, on_config)
			return on_config, false
		else -- Flag don't exist anywhere, so the default value will be written in settings and returned
			vmg.settings:set_bool(flag, default) -- write to vmg.conf
			return default, false -- return default value
		end
	end
end

local function define_noise(flag, default, config_name)
	local value = vmg.settings:get_np_group(flag)
	if value then -- This flag exists in vmg.conf, return its value
		return value, true
	else
		local on_config = minetest.settings:get_np_group(config_name or "vmg_" .. flag) -- get this flag in minetest.conf
		if on_config then -- This flag exists in minetest.conf, so return its value
			vmg.settings:set_np_group(flag, on_config)
			return on_config, false
		else -- Flag don't exist anywhere, so the default value will be written in settings and returned
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

function vmg.define(flag, default, config_name)
	local typeval = type(default) -- Select function from the type of the default value
	local f = definefunc[typeval] -- Choose the appropriate function
	if f then
		return f(flag, default, config_name)
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
elseif not pcall(dofile, vmg.path .. "/old_mapgens/" .. version .. ".lua") then
	print("[Valleys Mapgen] Missing compatibility mapgen for version " .. version .. ". Using latest version, you may see artifacts.")
end

-- Write settings after loading
minetest.after(0, function() vmg.settings:write() end)
