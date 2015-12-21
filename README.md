# Valleys Mapgen
Mapgen mod for Minetest 0.4.12+. Work in progress, not finished.
Mod created by Gael-de-Sailly and now developed by **Gael-de-Sailly**, **duane-r** and **vlapsley**.

![Screenshot](https://raw.githubusercontent.com/Gael-de-Sailly/valleys_mapgen/master/screenshot.png)

[Discussion on Minetest Forums](https://forum.minetest.net/viewtopic.php?f=9&t=11430)

## How to use it ?
### Download
1. [Download here](https://github.com/Gael-de-Sailly/valleys_mapgen/archive/master.zip) the .zip file
2. Extract the .zip archive with any archive manager (WinZip, 7-zip, file-roller…)
3. Rename the directory to *valleys_mapgen* and place it in the `/mods` directory of Minetest.

#### Download using Git
[Git](https://en.wikipedia.org/wiki/Git_%28software%29) is a very useful tool to manage repositories such as Valleys Mapgen.
Open the terminal (in Linux) or the Git shell (Windows), and set the working directory (the *mods* folder) using `cd`: for example `cd /home/gael/.minetest/mods` or `cd C:\Users\gael\minetest-0.4.13\mods`.
Download Valleys Mapgen: `git clone https://github.com/Gael-de-Sailly/valleys_mapgen.git`.
Next time, you can automatically update VMG with the same `cd` command, and `git pull origin master`.

### Use
#### Mods compatibility
Keep in mind that mapgen mods as this one are very powerful mods, that may interfere with some other mods. So, be careful when enabling many mods, the result might be unplayable. Valleys Mapgen is incompatible with all other "complete" mapgens like *Watershed*, *Ethereal*, Nore's *Mg*. Some mods that only partially rewrite the terrain will work with VMG: (*Cave Realms*, *Darkage*, *More Ores*, *Nether* (in this case you must add `valleys_mapgen?` in *nether/depends.txt*)). *Plantlife* and *More Trees* work but the respective biomes of the plants are not respected.
It's still compatible with most of the mods that don't affect mapgen (*Areas*, *World Edit*, *Mesecons*, *Home decor*, …)

#### Settings
There are many settings that can be changed by the user.
There are 3 ways to change the settings:
* In the *minetest.conf* file that is generally in the Minetest directory. All the settings of the game are here. For example if you want to change the river size to 8 (default is 5) to get bigger rivers, open the file with a text editor (avoid Notepad on Windows), and add a new line. The setting is named `vmg_river_size`, so you need to write: `vmg_river_size = 8`. If this setting is already present, simply modify it instead of adding a new line. **It will work ONLY for new worlds**.
* In the *vmg.conf* file that is in the world folders (for example `minetest/worlds/test_world`). If this file doesn't exist you can create it. It works the same way, except than we don't write the `vmg_` prefix, like `river_size = 8`. **It will work ONLY for this world.**
* In recent Minetest versions (0.4.13-dev after October 24th), it can be set in the Minetest main menu (*Settings* tab, in *Mods / valleys_mapgen*). It simply changes the settings in minetest.conf, so it has the same effect as writing in minetest.conf (works only for new worlds).
You can find the full list of settings in the file *settingtypes.txt* (do NOT modify this file).

## Plants API for modders
The Plants API has been introduced on October 24th, 2015. It allow mods to generate plants directly on the map.

### To begin
First, make sure that you've added the `valleys_mapgen` dependancy in your depends.txt (followed by a question mark if optional)
The only function is `vmg.register_plant`. It registers a plant that will be generated during mapgen. All plant parameters are passed to this function.

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

All cases are possible, but other cases can't be managed by default and need a `grow` function (see *grow*), like the example above with jungle tree. Anyway, the strings in this table are recursively converted into map content IDs.

#### cover
Decimal number between 0 and 1, which determines the proportion of surface nodes that are "reserved" for the plant. This doesn't necessarily mean that there is a plant on the node (see *density*), but this "cover" prevents other plants with lower priority from spawning on said nodes.

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
* `t`: table containing all possible conditions (the same `t` as above)

```
grow = function(nodes, pos, data, area)
	local rand = math.random()
	local height = math.floor(8 + 4 * rand)
	local radius = 5 + 3 * rand

	vmg.make_jungle_tree(pos, data, area, height, radius, nodes.trunk, nodes.leaves, nodes.air, nodes.ignore)
end,
```

## Changelog
### 1.0 (Saturday March 7, 2015)
* Created mapgen (using 7 noises at the moment).

### 1.0 ~> 1.1 (Sunday March 8, 2015)
* Added caves: they are modelised by 4 3D noises.
* Corrected ores generation: There was too many ores because it was sometimes generated twice or even more.
* Activated versions manager: if you update the mod from 1.0 to this version, the new mapgen will only take effect on new worlds, worlds created with 1.0 will stay in 1.0. If you want to activate mapgen 1.1 in an old world (there could be cleavages), change the file vmg.conf which is in the world directory.
* Added… this changelog :-D

### 1.1 ~> 1.2 (Tuesday March 17, 2015)
* Added lava underground
* Some minor changes about terrain :
    * Bare stone is rarer
    * Valleys are slightly larger
    * Ores are generated properly, according to [Paramat's changes](https://github.com/minetest/minetest/commit/b2b6bbf3e80f0ab06d62c43567122871ae560534) in `minetest.generate_ores`. **I advise you to update your MT version to a recent build (03/11 or later) or the ores overlapping problem will reappear.**
* Settings in minetest.conf : see file vmg.conf.example
* Now the player can't spawn in rivers
* Player spawn location is randomized : you can set the maximal distance from (0;0) at which the player will appear. (If it's in a big ocean, it may be farther)

### 1.2 ~> 1.3 (Wednesday April 8, 2015)
* Added differents types of dirts (the aim is to make real biomes in the future)
* Added beaches
* Fixed fatal error with number settings
* Added setting `water_level` to set water level (default is 1)

### 1.3 ~> 2.0 (Sunday May 31, 2015)
* Added trees (3 species for now), optionnal, enabled by default
* Added plants, optionnal, enabled by default
* Added snow
* Changed parameters for lava
* Added temperature and humidity noises, used by trees
* When a player dies, it's respawned
* Corrected `math.random` too large interval (2³² → 2²⁴)
* Adapted to any `chunksize` (previously the mod was only working for 5)
* Added logs : see vmg.conf.example

### 2.0 ~> 2.1 (Saturday July 4, 2015)
* Added pine tree
* Changed river shape (smooth floor)
* Generate special water in rivers
* Modified conditions for desert plants
* Changed valley shape a bit (no more cliffs on the sides of the rivers)

### 2.1 ~> 2.2 (Saturday September 26, 2015)
* Added birch tree, cherry tree and banana tree
* Added flowers (12 species)
* Added desert stone and sandstone ores
* Added Mushrooms
* Water and giant mushrooms in caves
* Added support for darkage ores
* Adapted sapling growth to new minetest_game API

### 2.2 ~> Latest
* Added plants API to allow external mods registering plants for VMG
* Added dry dirt
* Transform dirt into dirt with grass, dry grass or snow according to the climate
* Added willow tree
* Added optional 5 leaves colors for default tree
* Slimmer trunks for banana, cherry and birch tree
* Added simple caves for quicker mapgen (optional, disabled by default)
* Made ores optional
* Included dirt thickness in humidity calculation
* Changed `vmg.conf.example` to `settingtypes.txt` to be compatible with settings API (for recent builds)
* Fixed function `vmg.get_noise`. Humidity calculation is now correct after mapgen.
* Added mapgen time statistics in logs

