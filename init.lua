customnode = {}
customnode._templates = {}

----------------------------------------------------
-- API Call to create the nodes reading textures folder
----------------------------------------------------
function customnode.add_nodes_from_textures(conf)

--[[
	the texture names needs to follow the next convention:
	 modname_[prefix_][generator_][name_][tiletype].xyz
	[] is optional

	conf can contains the next attributes:
	conf.descr_prefix - Additional prefix to the node description
	conf.check_prefix - Enhance the prefix check to modname_addprefix_ instead of default modname_

]]
	local customnode_list = customnode.get_nodelist_by_textures(conf.check_prefix)
	for name, generator in pairs(customnode_list) do
		local nodedef = generator:get_nodedef(conf)
		if nodedef then
			minetest.register_node(nodedef.name, nodedef)
		end
	end
end

----------------------------------------------------
-- API Call - register new nodes generator
----------------------------------------------------
function customnode.register_generator(name, def)
	customnode._templates[name] = def
	if name ~= "default" then
		setmetatable(def, customnode._templates.default)
	end
	def.__index = customnode._templates.default
end


----------------------------------------------------
-- read textures folder and get node names
----------------------------------------------------
function customnode.get_nodelist_by_textures(prefix, generator_mapping)
	if not generator_mapping then
		generator_mapping = {
				brick = "default",
				cobblestone = "default",
				dirt = "default",
				grass = "default",
				ice = "default",
				iron = "default",
				sandstone = "default",
				stone = "default",
				item = "skip",
			}
	end

	local tile_mapping = {
		top = "top",
		bottom = "bottom",
		down = "bottom",
		right = "right",
		left = "left",
		back = "back",
		front = "front",
		side = "all",
		normal = "all",
	}

	local modname = minetest.get_current_modname()
	local modpath = minetest.get_modpath(modname)
	local files = minetest.get_dir_list(modpath.."/textures")

	local customnode_list = {}

	-- syntax is modename_[prefix_]_name_[type_][tiletype].xyz
	local def_name_idx_start = 2
	if prefix then 
		def_name_idx_start = 3
	end

	for _, v in ipairs(files) do
		-- split filename by "_" 
		local nameparts = {}
		for part in v:gmatch("([^_]+)") do
			table.insert(nameparts, part)
		end

		local name_idx_start = def_name_idx_start
		local name_idx_end = #nameparts
		-- check the nameparts if modname(1) and prefix(2) matches
		if name_idx_end >= name_idx_start and
				(nameparts[1] == modname and (not prefix or nameparts[2] == prefix)) then

			-- remove file ending from last namepart 
			nameparts[name_idx_end] = nameparts[name_idx_end]:gsub('\....$','') 

			-- get generator
			local generator
			local variant_name
			if name_idx_end >= name_idx_start then
				local generator_type = generator_mapping[nameparts[name_idx_start]]
				if generator_type then
					generator = customnode._templates[generator_type]
					variant_name = nameparts[name_idx_start]
					name_idx_start = name_idx_start +1
				end
			end
			if not generator then
				variant_name = "default"
				generator = customnode._templates["default"]
			end

			-- get tiletype
			local tiletype
			if name_idx_end >= name_idx_start then
				tiletype = tile_mapping[nameparts[name_idx_end]]
			end
			if not tiletype then
				tiletype = "all"
			else
				name_idx_end = name_idx_end -1 
			end

			-- get the basename and the unique entry name
			local basename
			local entryname
			if name_idx_start <= name_idx_end then
				basename = nameparts[name_idx_start]
				if name_idx_start < name_idx_end then
					for i = name_idx_start+1, name_idx_end do
						basename = basename.."_"..nameparts[i]
					end
				end
				entryname = basename.."_"..variant_name
			else
				entryname = variant_name
			end

			-- Add information to the customnode
			if not customnode_list[entryname] then
				customnode_list[entryname] = generator:new({
						modname = modname,
						prefix = prefix,
						basename = basename,
						variant = variant_name,
				})
			end
			customnode_list[entryname].tiles[tiletype] = v
		end
	end
	return customnode_list
end

----------------------------------------------------
-- Default base generator
----------------------------------------------------
customnode.register_generator("default", {
	-- create new generator (constructor
	new = function(self, def)
		local obj = setmetatable(def, self)
		obj.__index = self
		obj.tiles = {}
		return obj
	end,

	-- Main method - get a node definition for customnode
	get_nodedef = function(self, conf)
		self.conf = conf
		local nodedef = self:get_template()
		nodedef.name = self:get_name()
		nodedef.description = self:get_description()
		nodedef.tiles = self:get_tiles()
		nodedef.sounds = self:get_sounds()
		nodedef.paramtype2 = self:get_paramtype2()
		nodedef.groups = self:get_groups()
		return nodedef
	end,

	-- get the base template for the node
	get_template = function(self)
		return {
			is_ground_content = false,
		}
	end,

	-- Get node name
	get_name = function(self)
		if not self.basename then
			if self.variant == "default" then
				return self.modname..":"..self.modname
			else
				return self.modname..":"..self.variant
			end
		else
			if self.variant == "default" then
				return self.modname..":"..self.basename
			else
				return self.modname..":"..self.variant.."_"..self.basename
			end
		end
	end,

	-- Get node description
	get_description = function(self)
		local descr = self.conf.descr_prefix or self.modname
		if self.basename then
			descr = descr.." "..self.basename:gsub("_"," ")
		end
		if self.variant ~= "default" then
			descr = descr.." "..self.variant
		end
		return descr
	end,

-- Get the tiles table for node definition
	get_tiles = function(self)
		local fallback_file = self.tiles.all
				or self.tiles.left or self.tiles.right
				or self.tiles.back or self.tiles.front
				or self.tiles.bottom or self.tiles.top

		local nodetiles = {}
		nodetiles[1] = self.tiles.top or fallback_file
		nodetiles[2] = self.tiles.bottom or fallback_file
		nodetiles[3] = self.tiles.right or fallback_file
		nodetiles[4] = self.tiles.left or fallback_file
		nodetiles[5] = self.tiles.back or fallback_file
		nodetiles[6] = self.tiles.front or fallback_file
		return nodetiles
	end,

-- get sounds for the node
	get_sounds = function(self)
		local sound_mapping = {
				dirt = default.node_sound_dirt_defaults(),
				grass = minetest.registered_nodes["default:dirt_with_grass"].sounds,
				ice = default.node_sound_glass_defaults(),
				default = default.node_sound_stone_defaults(),
			}
		local sound = sound_mapping[self.variant]
		if not sound then
			sound = sound_mapping.default
		end
		return table.copy(sound)
	end,
	get_paramtype2 = function(self)
		if self.tiles.front then
			return "facedir"
		end
	end,
	get_groups = function(self)
		local groups_mapping = {
				brick = {cracky = 2, stone = 1, oddly_breakable_by_hand = 2},
				cobblestone =  {cracky = 3, stone = 2, oddly_breakable_by_hand = 2},
				dirt = {crumbly = 3, oddly_breakable_by_hand = 2},
				grass = {crumbly = 3, oddly_breakable_by_hand = 2},
				ice = {cracky = 3, oddly_breakable_by_hand = 2},
				iron = {cracky = 1, oddly_breakable_by_hand = 2},
				sandstone = {crumbly = 1, cracky = 3, oddly_breakable_by_hand = 2},
				stone = {cracky = 3, stone = 1, oddly_breakable_by_hand = 2},
				default = {crumbly = 1, cracky = 3, oddly_breakable_by_hand = 2},
		}
		local groups = groups_mapping[self.variant]
		if not groups then
			groups = groups_mapping.default
		end
		groups = table.copy(groups)
		if self.variant == default then
			groups.customnode = 1
		else
			groups["customnode_"..self.variant] = 1
		end
		return groups
				--	groups = {choppy = 3, oddly_breakable_by_hand = 2},
	end,
})


----------------------------------------------------
-- Generator that does nothing
----------------------------------------------------
customnode.register_generator("skip", {
	get_nodedef = function(self, conf)
		return nil
	end,
})
