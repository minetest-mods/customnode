----------------------------------------------------
-- API Call - register new variant
----------------------------------------------------
function customnode.register_variant(name, template)
	local modname = minetest.get_current_modname()

	if name:sub(1,1) == ":" then
		name = name:sub(1)
	elseif not name:match(":") then
		name = modname..':'..name
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
-- API internall Call - Get variant object
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
-- API internall Call: read textures folder and get a generator list
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
			for _, task in pairs(generator.variant.tasks) do
				task(nodedef)
			end
		end
	end
end

----------------------------------------------------
-- API internal Call: Check if a nodedef can be used for shapes
----------------------------------------------------
function customnode.check_nodedef(def, depmod)
	-- disable shapes from loaded modules but not defined in dependency
	if depmod and not depmod:check_depend_by_itemname(def.name) then
		return false
	end

	-- disable shapes for blocks without description
	if def.description == nil or def.description == "" then
		return false
	end

	-- no 3rd hand shapes
	local ignore_groups = {
		not_in_creative_inventory = true,
		carpet = true,
		door = true,
		fence = true,
		stair = true,
		slab = true,
		wall = true,
		micro = true,
		panel = true,
		slope = true,
	}
	for k,v in pairs(def.groups) do
		if ignore_groups[k] then
			return false
		end
	end

	-- not supported node types for shapes
	local ignore_drawtype = {
		liquid = true,
		firelike = true,
		airlike = true,
		plantlike = true,
		nodebox = true,
		raillike = true,
		mesh = true,
	}
	if ignore_drawtype[def.drawtype] then
		return false
	end

	-- no shapes for signs, rail, ladder
	if def.paramtype2 == "wallmounted" then
		return false
	end

	-- all checks passed
	return true
end


local variant_by_group1 = {
	stone = 'stone',
	sand = 'sand',
	tree = 'tree',
	wood = 'wood',
	spreading_dirt_type = 'grass',
}

-- Second try, no matches in group1
local variant_by_group2 = {
	soil = 'dirt',  -- after spreading_dirt_type and sand
	snowy = 'snow', -- after spreading_dirt_type
	falling_node = 'gravel', -- after sand
}

-- third try, no matches in group1 and group2
local variant_by_group3 = {
	cools_lava = 'ice', -- after snowy
}

---------------------------------------------------
-- API internal Call: classify node definition to variant
----------------------------------------------------
function customnode.detect_variant(def)
	for group, _ in pairs(def.groups) do
		local by_group = variant_by_group1[group]
		if by_group then
			return by_group
		end
	end

	for group, _ in pairs(def.groups) do
		local by_group = variant_by_group2[group]
		if by_group then
			return by_group
		end
	end

	for group, _ in pairs(def.groups) do
		local by_group = variant_by_group3[group]
		if by_group then
			return by_group
		end
	end

	if def.sunlight_propagates then
		return 'glass'
	end
end

---------------------------------------------------
-- API Call: Apply variant to all nodes in depending mods
----------------------------------------------------
function customnode.apply_variants_to_depnodes(variant_name)
	local depmod = customnode.modutils.get_depend_checker(minetest.get_current_modname())
	for name, def in pairs(minetest.registered_nodes) do
		if customnode.check_nodedef(def, depmod) then
			local variant
			if variant_name then
				variant = customnode.get_variant(variant_name)
			else
				variant = customnode.get_variant(customnode.detect_variant(def) or 'default')
			end
			for taskname, task in pairs(variant.tasks) do
				if taskname ~= "customnode:node" then
					task(def)
				end
			end
		end
	end
end
