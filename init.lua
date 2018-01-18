local fspath = minetest.get_modpath("customnode")

customnode = {}
customnode._variants = {}
customnode._tasks = {}
customnode.variant_class = dofile(fspath.."/variant_generator.lua")
customnode.modutils = dofile(fspath .. "/modutils.lua")
dofile(fspath.."/framework.lua")
dofile(fspath.."/tasks.lua")
dofile(fspath.."/variants.lua")
