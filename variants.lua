----------------------------------------------------
-- Default base variant
----------------------------------------------------
customnode.register_variant("customnode:default", {
	is_ground_content = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 2},
	sounds = default.node_sound_stone_defaults(),
	tasks = {"customnode:node"},
})

----------------------------------------------------
-- variant that does nothing
----------------------------------------------------
customnode.register_variant("customnode:item", {
	skip = true
})

----------------------------------------------------
-- Other variants
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
	tasks = {"stairs:stairs_slabs"},
})

customnode.register_variant("customnode:stone", {
	groups = {cracky = 3, stone = 1, oddly_breakable_by_hand = 2},
	tasks = {"stairs:stairs_slabs"},
})

customnode.register_variant("customnode:brick", "customnode:stone")
customnode.register_variant("customnode:cobble", "customnode:stone")
customnode.register_variant("customnode:stonebrick", "customnode:stone")
customnode.register_variant("customnode:cobblestone", "customnode:stone")

customnode.register_variant("customnode:sandstone", {
	groups = {crumbly = 1, cracky = 3, oddly_breakable_by_hand = 2},
	tasks = {"stairs:stairs_slabs"},
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
	tasks = {"stairs:stairs_slabs"},
})

customnode.register_variant("customnode:metal", {
	groups = {cracky = 1},
	sounds = default.node_sound_metal_defaults(),
	tasks = {"stairs:stairs_slabs"},
})
customnode.register_variant("customnode:steel", "customnode:metal")

customnode.register_variant("customnode:glass", {
	paramtype = "light",
	sunlight_propagates = true,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	sounds = default.node_sound_glass_defaults(),
})
