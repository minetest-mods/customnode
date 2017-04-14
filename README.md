# customnode - A minetest mod for easy nodes definitions in other mods

This mod provides the function customnode.get_nodelist_by_textures() that can be used in other mods to get additional mods in easy. 
The modder can focus on textures.

The best explanation is an example: 

## How to create a mod called "newsupermario"

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

7. store the compatible textures to the texture folder according the filename convention
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


# API

## customnode.add_nodes_from_textures(def)
def.descr_prefix - prefix added to all generated node descriptions. If not defined the modname will be used
def.check_prefix - Additional prefix if not all textures should be processed
def.add_stairs_slabs - Adds stairs and slabs for nodes with specific variants. Default value is "brick,cobblestone,ice,iron,sandstone,stone". false means disable, true means for all variants


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
