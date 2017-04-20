customnode = {}
customnode._variants = {}
customnode._tasks = {}

----------------------------------------------------
-- Node generator implementation
----------------------------------------------------
local generator_class = {}
generator_class.__index = generator_class

-- Main method - get a node definition for customnode
function generator_class:get_nodedef()
	local nodedef = table.copy(self.variant.template)
	nodedef.name = self.modname..":"..self:get_name()
	nodedef.description = self:get_description()
	nodedef.tiles = self:get_tiles()
	nodedef.paramtype2 = self:get_paramtype2()
	nodedef.groups = self:get_groups()
	return nodedef
end

-- Get node name
function generator_class:get_name()
	return self.basename
end

-- Get node description
function generator_class:get_description()
	local descr = self.conf.descr_prefix or self.modname
	descr = descr.." "..self.basename:gsub("_"," ")
	return descr
end

-- Get the tiles table for node definition
function generator_class:get_tiles()
	local fallback_file = self.img_tiles.all
			or self.img_tiles.left or self.img_tiles.right
			or self.img_tiles.back or self.img_tiles.front
			or self.img_tiles.bottom or self.img_tiles.top

	local nodetiles = {}
	nodetiles[1] = self.img_tiles.top or fallback_file
	nodetiles[2] = self.img_tiles.bottom or fallback_file
	nodetiles[3] = self.img_tiles.right or fallback_file
	nodetiles[4] = self.img_tiles.left or fallback_file
	nodetiles[5] = self.img_tiles.back or fallback_file
	nodetiles[6] = self.img_tiles.front or fallback_file
	return nodetiles
end

function generator_class:get_paramtype2()
	if not self.variant.template.paramtype2 and -- do not override
			self.img_tiles.front then -- only if front defined
		return "facedir"
	else
		return self.variant.template.paramtype2
	end
end

function generator_class:get_groups()
	local groups = table.copy(self.variant.template.groups)
	if self.variant_shortname == "default" then
		groups.customnode = 1
	else
		groups["customnode_"..self.variant_shortname] = 1
	end
	return groups
end

----------------------------------------------------
-- Node variant implementation
----------------------------------------------------
local variant_class = {}
variant_class.__index = variant_class

-- create new variant (constructor
function variant_class:new_generator(def)
	local generator = setmetatable({}, generator_class)
	generator.__index = generator_class
	generator.variant = self

	for k,v in pairs(def) do
		generator[k] = v
	end

	generator.img_tiles = {}
	return generator
end

-- Add a chaper to the variant
function variant_class:add_task(taskname)
	assert(customnode._tasks[taskname], "task not defined")
	table.insert(self.tasks, customnode._tasks[taskname])
end

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

	local def = setmetatable({}, variant_class)
	def.__index = variant_class

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
				if not variant and customnode._variants[modname..":"..part] then
					variant = customnode._variants[modname..":"..part]
					variant_shortname = part
				elseif not variant and customnode._variants["customnode:"..part] then
					variant = customnode._variants["customnode:"..part]
					variant_shortname = part
				end
				if not basename then
					basename = part
				else
					basename = basename.."_"..part
				end
			end
		end

		if variant and variant.skip then
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

			-- default generator
			if not variant then
				variant = customnode._variants["customnode:default"]
				variant_shortname = "default"
			end

			print(variant_shortname,dump(variant))

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
				task(nodedef, generator)
			end
		end
	end
end

----------------------------------------------------
-- Default base task
----------------------------------------------------
customnode.register_task("default", function(nodedef)
	minetest.register_node(nodedef.name, nodedef)
end)

----------------------------------------------------
-- task for stairs and slabs using stairs mod
----------------------------------------------------
customnode.register_task("stairs_slabs", function(nodedef, generator)
	if minetest.global_exists("stairs") then
		stairs.register_stair_and_slab(
			generator.modname.."_"..generator:get_name(),
			nodedef.name,
			table.copy(nodedef.groups),
			table.copy(nodedef.tiles),
			nodedef.description.." Stair",
			nodedef.description.." Stone Slab",
			table.copy(nodedef.sounds)
		)
	end
end)

----------------------------------------------------
-- Default base variant
----------------------------------------------------
customnode.register_variant("customnode:default", {
	is_ground_content = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 2},
	sounds = default.node_sound_stone_defaults(),
	tasks = {"default"},
})

----------------------------------------------------
-- variant that does nothing
----------------------------------------------------
customnode.register_variant("customnode:item", {
	skip = true
})

----------------------------------------------------
-- Basic variants
----------------------------------------------------
customnode.register_variant("customnode:dirt", {
	sounds = default.node_sound_dirt_defaults(),
	groups = {crumbly = 3, oddly_breakable_by_hand = 2}
})

customnode.register_variant("customnode:grass", {
	groups = {crumbly = 3, oddly_breakable_by_hand = 2},
	sounds = table.copy(minetest.registered_nodes["default:dirt_with_grass"].sounds),
})

customnode.register_variant("customnode:ice", {
	sounds = default.node_sound_glass_defaults(),
	tasks = {"stairs_slabs"},
})

customnode.register_variant("customnode:stone", {
	groups = {cracky = 3, stone = 1, oddly_breakable_by_hand = 2},
	tasks = {"stairs_slabs"},
})

customnode.register_variant("customnode:brick", "customnode:stone")
customnode.register_variant("customnode:cobble", "customnode:stone")
customnode.register_variant("customnode:stonebrick", "customnode:stone")
customnode.register_variant("customnode:cobblestone", "customnode:stone")

customnode.register_variant("customnode:sandstone", {
	groups = {crumbly = 1, cracky = 3, oddly_breakable_by_hand = 2},
	tasks = {"stairs_slabs"},
})

customnode.register_variant("customnode:sand", {
	groups = {crumbly = 3, falling_node = 1, sand = 1,  oddly_breakable_by_hand = 2},
	sounds = default.node_sound_sand_defaults(),
})

customnode.register_variant("customnode:gravel", {
	groups = {crumbly = 2, falling_node = 1,  oddly_breakable_by_hand = 2},
	sounds = default.node_sound_gravel_defaults(),
})

customnode.register_variant("customnode:snow", {
	groups = {crumbly = 3, puts_out_fire = 1, cools_lava = 1},
	sounds = table.copy(minetest.registered_nodes["default:snowblock"].sounds),
})

customnode.register_variant("customnode:tree", {
	paramtype2 = "facedir",
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	on_place = minetest.rotate_node
})

customnode.register_variant("customnode:wood", {
	paramtype2 = "facedir",
	place_param2 = 0,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1},
	sounds = default.node_sound_wood_defaults(),
	tasks = {"stairs_slabs"},
})

customnode.register_variant("customnode:metal", {
	groups = {cracky = 1},
	sounds = default.node_sound_metal_defaults(),
	tasks = {"stairs_slabs"},
})
customnode.register_variant("customnode:steel", "customnode:metal")

customnode.register_variant("customnode:glass", {
	paramtype = "light",
	sunlight_propagates = true,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	sounds = default.node_sound_glass_defaults(),
})
