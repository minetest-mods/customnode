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

return variant_class
