# CHANGELOG

## Version 32
- Started adding a battle start animation;
- Now level up dialogue is shown in battle.

## Version 31
- Added a real time battle viewer in the debug menu, able to influence the battle;
- Added speed up by pressing Space;
- Small fixes.

## Version 30
- Added pointing hand to most clickable UI;
- Started (And mostly finished) double battle implementation;
- Small fix on disconnect in the debug menu plugin.

## Version 29
- Repurposed debug menu into a plugin;
  - No new functionality has been added to the debug menu.

## Version 28
- Readded exp gain;
- Changed ActorFrames and PokemonFollowerFrames to not automatically refresh and have a button to generate inside the editor;
- Added wild battle setting in the debug menu.

## Version 27
- Battle backend overhaul;
  - Now is integrated in the buffer system, making it more stable and fixing issues such as GROWL animation.

## Version 26
- Started work on different elevations;
    - Need to solve Y-Sorting;
- Need to fix animations like GROWL not stopping the battle execution.

## Version 25
- Added exp gain with (incomplete) databox animation;
- Added saving data based on serialized dictionaries;
- Added Flag singleton;
- Made a simple, very ugly and still unused CRT shader;
- Added a main menu and intro scene.

## Version 24
- Started adding sounds.

## Version 23
- Added Settings;
    - Those save in a global "settings.cfg" file in the user data directory;
- Small refactoring here and there.

## Version 22
- Started work on battle effects. Implemented a basic stat change
effect, such as GROWL. Seems to be functional;
- Refactored Battle script to work with a simple animation buffering
system;
	- It allows to add an animation or text to be shown to a buffer, which gets played in the Battle process function. A signal is sent when a buffered animation is ran, or when all the buffered animations are ran.

## Version 21
- Added some placeholder battle animations;
- Reworked debug menu a little.

## Version 20
- Added instantiated maps (Like indoor maps);
- Added a transition system;
- Added a rudimentary debug menu (Has to be redone);
- Minor fixes to random stuff.

## Version 19
- Added a functional summary screen (With no ribbons yet);
- Added a rudimental switch on pokemon faint. Probably very buggy;
- Added type interaction texts in battle;
- Fixed some mistakes with the JSON data.

## Version 18
- Added basic in-battle switching;
- Added some documentation;
- Added a basic in-battle animation system;
    - Still have to figure out why the hurt flash doesn't work on the enemy;
- Minor fixes.

## Version 17
- Started work on HUD and party menu;
- Added game world and basic map connections;
- Implemented a secondary method to load sprites;
    - Works by extracting a zip file containing all the sprites to `user://`. Disabled and left unused as it is extremely slow on Android to the point of freezing;
- Implemented placeholder touch controls;
- Minor fixes or improvements to different scripts.

## Version 16
- Implemented shiny calculation (Without modifiers like Masuda method).
- Done much work on actors, added NPCs and other smaller stuff.
- Remade pokemon_graphics.pck with follower pokemon

## Version 15
- Improved the dialogue system with UI and added simple events.
- Fixed a mess with the pokemon_sprites.pck asset pack.

## Version 14
- Started work on overworld tilesets and tilemap.

## Version 13
- Working on Actors and Players.

## Version 12
- Added type interactions.

## Version 11
- Damage in battle can now be actually dealt;
- Battle can actually end.

## Version 10
- Ported to Godot 4.4 beta;
- Damage calculations half done.

## Version 9
- More work on the battle scene;
	- Especially regarding moves;
- Made dialogues into nodes.

## Version 8
- Fixed some sprite loading issues and other minor issues.
- Implemented asset pack loading at runtime and made so that the `pokemon_graphics` folder is ignored by the engine to make startup time faster.

## Version 7
- Started work on the Dialogue system, given it's needed for the battle scene;
	- Also made a small plugin to test the dialogue.

## Version 6
- More work on the battle scene;
	- Mainly UI.

## Version 5
- Documented a lot of code;
- Implemented PokemonTeam resource and PokemonMove resource;
- Fixed some issues.

## Version 4
- More work on battle related stuff in the Pokemon class;
- Implemented fetching for moves.

## Version 3
- Started laying out the battle scene by importing the battlebacks from Essentials;
- Started implementing the Pokemon class.

## Version 2
- Started work on the PokemonSpecies class and converter from Essentials.

## Version 1
- Project restarted.