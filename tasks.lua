----------------------------------------------------
-- Default base task
----------------------------------------------------
customnode.register_task("customnode:node", function(nodedef)
	minetest.register_node(nodedef.name, nodedef)
end)

----------------------------------------------------
-- task for stairs and slabs using stairs mod
----------------------------------------------------
customnode.register_task("stairs:stairs_slabs", function(nodedef, generator)
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
