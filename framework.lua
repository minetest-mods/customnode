----------------------------------------------------
-- API Call - register new variant
----------------------------------------------------
function customnode.register_variant(name, template)
	local modname = minetest.get_current_modname()

	if name:sub(1,1) == ":" then
		name = name:sub(1)
	elseif name:sub(1,modname:len()+1) ~= modname..":" then
		error(name.." does not match naming conventions")
	end

	local def = setmetatable({}, customnode.variant_class)
	def.__index = customnode.variant_class

	-- set variant name
	def.name = name

	-- set template
	if not template then
		template = "default"
	end

	if type(template) == "string" then
		assert(customnode._variants[template], "unknown template: "..template)
		def.template = customnode._variants[template].template
		def.tasks = customnode._variants[template].tasks
	else
		if name == "customnode:default" then
			def.template = {}
			def.tasks = {}
		else
			def.template = table.copy(customnode._variants["customnode:default"].template or {})
			def.tasks = table.copy(customnode._variants["customnode:default"].tasks or {})
		end
		if template then
			for k,v in pairs(template) do
				if k == "tasks" then
					for _, s in ipairs(v) do
						def:add_task(s)
					end
				elseif k == "skip" then
					def.skip = v
				else
					def.template[k] = v
				end
			end
		end
	end
	customnode._variants[name] = def
	return def
end

----------------------------------------------------
-- API Call - Get variant object
----------------------------------------------------
function customnode.get_variant(name)
	if name:match(":") then
		return customnode._variants[name]
	else
		local modname = minetest.get_current_modname()
		return customnode._variants[modname..":"..name] or customnode._variants["customnode:"..name]
	end
end

----------------------------------------------------
-- API Call - register task
----------------------------------------------------
function customnode.register_task(name, task)
	if customnode._tasks[name] then
		error(name.." is already registered task")
	end
	customnode._tasks[name] = task
end

----------------------------------------------------
-- read textures folder and get a generator list
----------------------------------------------------
function customnode.get_nodelist_by_textures(conf)
	local tile_mapping = {
		top = "top",
		bottom = "bottom",
		down = "bottom",
		right = "right",
		left = "left",
		back = "back",
		inner = "back",
		front = "front",
		side = "all",
		normal = "all",
	}

	local modname = minetest.get_current_modname()
	local modpath = minetest.get_modpath(modname)
	local files = minetest.get_dir_list(modpath.."/textures")

	local customnode_list = {}

	-- syntax is modename_[prefix_][name_][type_][tiletype].xyz
	for _, v in ipairs(files) do
		local index = 0
		local skip = false

		local basename
		local variant
		local variant_shortname
		local tiletype

		for part in v:gmatch("([^_]+)") do -- split filename by "_"
			index = index + 1

			-- remove file ending in last part
			part = part:gsub('%....$','')

			-- check modname namespace
			if index == 1 then
				if part ~= modname then
					skip = true
					break
				end

			-- check additional namespace
			elseif index == 2 and conf.check_prefix then
				if part ~= conf.check_prefix then
					skip = true
					break
				end

			-- process tile mapping
			elseif tile_mapping[part] then
				tiletype = tile_mapping[part]
			else
				if not variant then
					variant = customnode.get_variant(part)
					if variant then
						variant_shortname = part
					end
				end
				if not basename then
					basename = part
				else
					basename = basename.."_"..part
				end
			end
		end

		-- default generator
		if not variant then
			variant = customnode.get_variant("default")
			variant_shortname = "default"
		end

		if variant.skip then
			skip = variant.skip
		end

		if not skip then
			-- default tiletype
			if not tiletype then
				tiletype = "all"
			end

			if not basename then
				basename = modname
			end

			-- Add information to the customnode
			if not customnode_list[basename] then
				customnode_list[basename] = variant:new_generator({
						modname = modname,
						basename = basename,
						variant_shortname = variant_shortname,
						conf = conf,
				})
			end
			customnode_list[basename].img_tiles[tiletype] = v
		end
	end
	return customnode_list
end

----------------------------------------------------
-- API Call read textures folder and create all configured tasks
----------------------------------------------------
function customnode.add_nodes_from_textures(conf)
	local generator_list = customnode.get_nodelist_by_textures(conf or {})
	for name, generator in pairs(generator_list) do
		local nodedef = generator:get_nodedef()
		if nodedef then
			for _, task in ipairs(generator.variant.tasks) do
				task(nodedef)
			end
		end
	end
end
