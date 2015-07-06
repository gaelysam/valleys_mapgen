# Valleys Mapgen
Mapgen mod for Minetest 0.4.12+. Work in progress, not finished.

![Screenshot](http://i.imgur.com/A6CBuaV.png)

[Discussion on Minetest Forums](https://forum.minetest.net/viewtopic.php?f=9&t=11430)

## Changelog
### 2.1 ~> Latest
* Added flowers (6 species)

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