# Valleys Mapgen
Mapgen mod for Minetest 0.4.12+. Work in progress, not finished.
Mod created by Gael-de-Sailly and now mainly developed by duane-r.

![Screenshot](http://i.imgur.com/9Avs3tw.png)

[Discussion on Minetest Forums](https://forum.minetest.net/viewtopic.php?f=9&t=11430)

## Changelog
### 2.2 ~> Latest
* Changed `vmg.conf.example` to `settingtypes.txt` to be compatible with settings API (for recent builds)
* Added willow tree
* Added plants API to allow external mods registering plants for VMG
* Added simple caves for quicker mapgen (optional, disabled by default)
* Made ores optional
* Added optional 5 leaves colors for default tree
* Slimmer trunks for banana, cherry and birch tree

### 2.1 ~> 2.2 (Saturday September 26, 2015)
* Added support for darkage ores
* Added birch tree, cherry tree and banana tree
* Water and giant mushrooms in caves
* Added Mushrooms
* Adapted sapling growth to new minetest_game API
* Added flowers (12 species)

### 2.0 ~> 2.1 (Saturday July 4, 2015)
* Modified conditions for desert plants
* Added pine tree
* Generate special water in rivers
* Changed valley shape a bit (no more cliffs on the sides of the rivers)
* Changed river shape (smooth floor)

### 1.3 ~> 2.0 (Sunday May 31, 2015)
* Added plants, optionnal, enabled by default
* Corrected math.random too large interval (2³² → 2²⁴)
* Added snow
* When a player dies, it's respawned
* Adapted to any `chunksize` (previously the mod was only working for 5)
* Added trees (3 species for now), optionnal, enabled by default
* Added logs : see vmg.conf.example
* Added temperature and humidity noises, used by trees
* Changed parameters for lava

### 1.2 ~> 1.3 (Wednesday April 8, 2015)
* Added differents types of dirts (the aim is to make real biomes in the future)
* Added beaches
* Added setting `water_level` to set water level (default is 1)
* Fixed fatal error with number settings

### 1.1 ~> 1.2 (Tuesday March 17, 2015)
* Added lava underground
* Settings in minetest.conf : see file vmg.conf.example
* Now the player can't spawn in rivers
* Player spawn location is randomized : you can set the maximal distance from (0;0) at which the player will appear. (If it's in a big ocean, it may be farther)
* Some minor changes about terrain :
    * Bare stone is rarer
    * Valleys are slightly larger
    * Ores are generated properly, according to [Paramat's changes](https://github.com/minetest/minetest/commit/b2b6bbf3e80f0ab06d62c43567122871ae560534) in `minetest.generate_ores`. **I advise you to update your MT version to a recent build (03/11 or later) or the ores overlapping problem will reappear.**

### 1.0 ~> 1.1 (Sunday March 8, 2015)
* Added caves: they are modelised by 4 3D noises.
* Corrected ores generation: There was too many ores because it was sometimes generated twice or even more.
* Activated versions manager: if you update the mod from 1.0 to this version, the new mapgen will only take effect on new worlds, worlds created with 1.0 will stay in 1.0. If you want to activate mapgen 1.1 in an old world (there could be cleavages), change the file vmg.conf which is in the world directory.
* Added… this changelog :-D

### 1.0 (Saturday March 7, 2015)
* Created mapgen (using 7 noises at the moment).

## Plants API
The Plants API has been introduced on October 24th, 2015. It allow mods to generate plants directly on the map.

### How to use it ?
First, make sure that you've added the `valleys_mapgen` dependancy in your depends.txt (followed by a question mark if optional)
The only function is `vmg.register_plant`. It registers a plant that will be generated during mapgen.

### Parameters
Syntax (example for jungle tree)

```
vmg.register_plant({
	nodes = {
		trunk = "default:jungletree",
		leaves = "default:jungleleaves",
		air = "air", ignore = "ignore",
	},
	cover = 0.5,
	density = 0.06,
	priority = 73,
	check = function(t, pos)
		return t.v15 < 0.7 and t.temp >= 1.9 and t.humidity > 2 and t.v16 > 2
	end,
	grow = function(nodes, pos, data, area)
		local rand = math.random()
		local height = math.floor(8 + 4 * rand)
		local radius = 5 + 3 * rand

		vmg.make_jungle_tree(pos, data, area, height, radius, nodes.trunk, nodes.leaves, nodes.air, nodes.ignore)
	end,
})
```

#### nodes
List of nodes that will be used, could be a table or a simple string. In this table, all strings are converted into content IDs.

Many syntaxes are possible, with their default behaviour (see *grow*):
* `nodes = "default:dry_shrub"`: simply generate a dry shrub.
* `nodes = {"default:papyrus", n=4}`: generate 4 papyrus nodes vertically.
* `nodes = {"default:grass_1", "default:grass_2", "default:grass_3", "default:grass_4", "default:grass_5"}`: generate one grass node, randomly chosen between the 5 nodes.
* `nodes = {"default:grass_1", "default:grass_2", "default:grass_3", "default:grass_4", "default:grass_5, n=3"}`: generate 3 grass nodes vertically (my example is a bit silly…), randomly chosen between the 5 nodes (chosen once, not 3 times).

All cases are possible, but other cases can't be managed by default and need a grow function (see *grow*), like the example above with jungle tree. Anyway, the strings in this table are recursively converted into map content IDs.

#### cover
Number between 0 and 1, which determines the proportion of surface nodes that are "reserved" for the plant. This doesn't necessarily mean that there is a plant on the node (see *density*), but this "cover" prevents other plants with lower priority from spawning on said nodes.

#### density
Number between 0 and cover. Proportion of nodes that are effectively covered by the plant.

Examples:
* `cover = 0.8 ; density = 0.8`: the plant is present on 80% of the nodes, so extremely dense. Other plants can't take more than the remaining 20% if they have a lower `priority`.
* `cover = 0.8 ; density = 0.1`: the plant is present on 10% of the nodes, so more scattered, but other plants can't take more than 20% if they have a lower `priority`. Params like this are suitable for a plant that naturally needs much space.
* `cover = 0.1 ; density = 0.1`: the plant is present on 10% of the nodes as in the previous case, but other plants are much more common (max 90% of the nodes).

#### priority
Integer generally between 0 and 100 (no strict rule :) to determine which plants are dominating the others. The dominant plants (with higher priority) impose their *cover* on the others.

#### check
Function to check the conditions. Should return a boolean: true, the plant can spawn here ; false, the plant can't spawn and doesn't impose its *cover*. It takes 2 parameters:
* `t`: table containing all possible conditions: all noises (`t.v1` to `t.v20`), dirt thickness `t.thickness`, temperature `t.temp`, humidity `t.humidity`, humidity from sea `t.sea_water`, from rivers `t.river_water`, from sea and rivers `t.water`.
* `pos`: position of the future plant, above the dirt node.

```
check = function(t, pos)
	return t.v15 < 0.7 and t.temp >= 1.9 and t.humidity > 2 and t.v16 > 2
end,
```

#### grow
Optional function to override the default behaviour (see *nodes*) for complex plants like trees.
It should "simply" generate the plant.
It takes 5 parameters:
* `nodes`: table of map content IDs, see *nodes*.
* `pos`: position of the future plant, above the dirt node.
* `data`: VoxelManip data (array of content IDs)
* `area`: VoxelArea
* `i`: index of the data array matching the position `pos`. In other terms, `area:indexp(pos) = i`.

```
grow = function(nodes, pos, data, area)
	local rand = math.random()
	local height = math.floor(8 + 4 * rand)
	local radius = 5 + 3 * rand

	vmg.make_jungle_tree(pos, data, area, height, radius, nodes.trunk, nodes.leaves, nodes.air, nodes.ignore)
end,
```
