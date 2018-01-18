# API

## customnode.add_nodes_from_textures(def)
  - def.descr_prefix - prefix added to all generated node descriptions. If not defined the modname will be used
  - def.check_prefix - Additional prefix if not all textures should be processed

## customnode.apply_variants_to_depnodes(variant_name)
  - reads the depends.txt for current mod, analyzes all installed nodes by mod, classify and create variant specific shapes.
  - if variant_name (optional) given the classify is skipped and the variant is forced for all nodes


## Textures name convention
modname_[addprefix_][variant_][name_][tiletype].ext
  - [] means optional
  - modname - to avoid overlapping all textures without modname in filename will be ignored
  - addprefix - additional prefix for mods that contains other textures that should not be processed
  - variant - determinate some nodes parameter: 
    - Supported: brick, cobblestone, dirt, grass, ice, iron, sandstone, stone, item (=will be skipped)
  - tiletype - defines the tile position
    - Supported: top, bottom, down, right, left, back, inner, front, side, normal
  - name - additional string makes the nodename unique. Note: if tieltype or variant is not valid, you find it as a part of the name
  - ext - File extendion as supported by minetest


# Advanced API

## New Task
Defines what should be done
`customnode.register_task(name, function)` - register a new task, that can be used in customnode.register_variant. THe function will be called for each definition
   - function(nodedef, generator) - nodedef is data prepared for register_node(), generator is the object with used additional internal data

### Implemented tasks
  - customnode:node - create the node. Allways used in case of add_nodes_from_textures()
  - stairs:stairs_slabs - generate stairs and slabs using stairs.register_stair_and_slab() if stairs mod installed
  - carpets:carpet - Generate carpets if the carpets mod is installed

## New variant
`customnode.register_variant(name, definition)` - register a new nodes variant
  - name - Variant name is namespaced as "modname:pattern". The "pattern" will be checked against texture-filename or determination
  - definition - if a string is provided the variant will be just linked against existing variant
     - if a table is provided the table will be [b]merged[b] to the default template for register_node(). All attributes will be passed to register_node, except:
        - tasks: A table of tasks should be executed for variant. Note the default definition contains already "default" taks that creates the node
        - skip: a bolean value. If it is true, no nodes will be generated for this variant

## Implemented variants - for the definition look to the implementation at the end of init.lua
  - customnode:default - the default one. Is used as template for all other variants. Is used for all nodes without valid variant
  - customnode:item - skip is set
  - customnode:dirt
  - customnode:grass
  - customnode:ice - with stairs_slabs
  - customnode:stone - with stairs_slabs
  - customnode:brick - copy of stone
  - customnode:cobble - copy of stone
  - customnode:stonebrick - copy of stone
  - customnode:cobblestone - copy of stone
  - customnode:sandstone - with stairs_slabs
  - customnode:sand
  - customnode:gravel
  - customnode:snow
  - customnode:tree
  - customnode:wood - with stairs_slabs
  - customnode:metal - with stairs_slabs
  - customnode:steel - copy of metal
  - customnode:glass

## Extended example
```
customnode.register_task("recipe", function(nodedef)
	minetest.register_craft({
		output = nodedef.name,
		recipe = {
			{"default:wood", ingredients[nodedef.name], "default:wood"},
		}
	})
end)

customnode.register_variant("mymod:wood", {
	groups = {choppy = 2, wood = 1}
	tasks = {"stairs_slabs", "recipe"},
})

customnode.add_nodes_from_textures({
	descr_prefix = "My crazy blocks",
})
```

