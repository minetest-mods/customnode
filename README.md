# customnode - A minetest mod for easy nodes definitions in other mods

Forum thread: https://forum.minetest.net/viewtopic.php?t=17375

## Decorative nodes by reading textures folder
This mod provides the function customnode.get_nodelist_by_textures() that can be used in other mods to get additional mods in easy.
The modder can focus on textures. The framework create the node definitions and some shaped nodes in addition matching node variant.

The best explanation is an example: 

### How to create a mod called "newsupermario"

1. create the mod folder newsupermario/

2. create mod.conf
```
name = newsupermario
```

3. create depends.txt
```
customnode
```

4. create init.lua
```
customnode.add_nodes_from_textures({
	descr_prefix = "New Super Mario",  
})
```

5. create textures folder

6. create your textures (or download them from internet like http://resourcepack.net/super-mario-bros-resource-pack)

7. store the compatible textures to the texture folder according the filename convention. Renaming can be done by any bulk-rename tool.

```
$ ls textures/
newsupermario_brick.png              newsupermario_ice.png                        newsupermario_netherrack.png                 newsupermario_sandstone_smooth_top.png
newsupermario_coal_block.png         newsupermario_iron_block.png                 newsupermario_noteblock.png                  newsupermario_sandstone_top.png
newsupermario_coal_ore.png           newsupermario_iron_ore.png                   newsupermario_obsidian.png                   newsupermario_stone2.png
newsupermario_cobblestone_mossy.png  newsupermario_iron_trapdoor.png              newsupermario_quartz_block_bottom.png        newsupermario_stone3.png
newsupermario_cobblestone.png        newsupermario_jukebox_side.png               newsupermario_quartz_block_chiseled.png      newsupermario_stone_andesite.png
newsupermario_command_block.png      newsupermario_jukebox_top.png                newsupermario_quartz_block_chiseled_top.png  newsupermario_stone_andesite_smooth.png
newsupermario_diamond_block.png      newsupermario_lapis_block.png                newsupermario_quartz_block_lines.png         newsupermario_stonebrick_cracked.png
newsupermario_diamond_ore.png        newsupermario_lapis_ore.png                  newsupermario_quartz_block_lines_top.png     newsupermario_stonebrick_mossy.png
newsupermario_dirt.png               newsupermario_leaves_oak.png                 newsupermario_quartz_block_side.png          newsupermario_stonebrick.png
newsupermario_dirt_podzol_side.png   newsupermario_log_acacia.png                 newsupermario_quartz_block_top.png           newsupermario_stone_diorite.png
newsupermario_dirt_podzol_top.png    newsupermario_log_spruce.png                 newsupermario_quartz_ore.png                 newsupermario_stone_diorite_smooth.png
newsupermario_emerald_block.png      newsupermario_mob_spawner.png                newsupermario_redstone_block.png             newsupermario_stone_granite.png
newsupermario_emerald_ore.png        newsupermario_mushroom_block_skin_brown.png  newsupermario_redstone_ore.png               newsupermario_stone_granite_smooth.png
newsupermario_gold_block.png         newsupermario_mushroom_block_skin_red.png    newsupermario_sandstone_bottom.png           newsupermario_stone.png
newsupermario_gold_ore.png           newsupermario_mushroom_block_skin_stem.png   newsupermario_sandstone_carved.png           newsupermario_tnt_bottom.png
newsupermario_grass_side.png         newsupermario_mycelium_side.png              newsupermario_sandstone_normal.png           newsupermario_tnt_side.png
newsupermario_grass_top.png          newsupermario_mycelium_top.png               newsupermario_sandstone_smooth_bottom.png    newsupermario_tnt_top.png
newsupermario_ice_packed.png         newsupermario_nether_brick.png               newsupermario_sandstone_smooth.png
```
8. add the mod to a creative game and try out the new blocks

## Additional shapes for nodes in already existing mods
The function customnode.apply_variants_to_depnodes() called from other mod analyzes the depends.txt file, analyzes by the mods installed nodes for shapeable, 
classify and apply the shape-tasks to the node.

The best explanation is again an example:

### How to create a mod called "my_shapes"

1. create the mod folder my_shapes/

2. create mod.conf
```
name = my_shapes
```

3. create depends.txt with mods contains some compatible blocks
```
customnode
abriglass?
pbj_pup?
myroofs?
```

4. create init.lua
```
-- Introduce wooden carpets
customnode.register_variant("glass", {
	tasks = {"stairs:stairs_slabs"},
})


-- Enable carpets for all not classified (default) nodes
customnode.register_variant("default", {
	tasks = {"carpets:carpet"},
})

customnode.apply_variants_to_depnodes()
```

This mod creates 23 stairs and 23 slabs usgin glass materials from abriglass and 15 carpets from not classified nodes in myroofs mod.

## Advanced usage
Of course the API allow more specific usage. See [API.md](https://github.com/bell07/minetest-customnode/blob/master/API.md) file. But find the balance sometimes it is easier to use minetest.register_node instead of the framework.
