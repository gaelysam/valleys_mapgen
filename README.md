# Valleys Mapgen
Mapgen mod for Minetest 0.4.12+. Still not finished.

![Screenshot](http://i.imgur.com/z78BXy3.png)

[Discussion on Minetest Forums](https://forum.minetest.net/viewtopic.php?f=9&t=11430)

## Changelog
### 1.2 ~> lastest
* Added differents types of dirts (the aim is to make real biomes in the future)

### 1.1 ~> 1.2
* Added lava underground
* Settings in minetest.conf : see file vmg.conf.example
* Now the player can't spawn in rivers
* Player spawn location is randomized : you can set the maximal distance from (0;0) at which the player will appear. (If it's in a big ocean, it may be farther)
* Some minor changes about terrain :
    * Bare stone is rarer
    * Valleys are slightly larger
    * Ores are generated properly, according to [Paramat's changes](https://github.com/minetest/minetest/commit/b2b6bbf3e80f0ab06d62c43567122871ae560534) in `minetest.generate_ores`. **I advise you to update your MT version to a recent build (03/11 or later) or the ores overlapping problem will reappear.**

### 1.0 ~> 1.1
* Added caves: they are modelised by 4 3D noises.
* Corrected ores generation: There was too many ores because it was sometimes generated twice or even more.
* Activated versions manager: if you update the mod from 1.0 to this version, the new mapgen will only take effect on new worlds, worlds created with 1.0 will stay in 1.0. If you want to activate mapgen 1.1 in an old world (there could be cleavages), change the file vmg.conf places in the world directory.
* Added… this changelog :-D
