extends Node

const BattleScene : = preload('res://Scenes/Battle/BattleScene.tscn')

func get_player() -> CharacterBody2D:
	return get_tree().get_first_node_in_group('Player')

## Start a pokemon battle where [param enemy] is the wild pokemon
func start_battle(enemy : Pokemon) -> void:
	var battle = BattleScene.instantiate()

	battle.pokemon_1 = GameVariables.player_team[0]
	battle.enemy_team[0] = enemy
	
	var battle_canvas = CanvasLayer.new()
	battle_canvas.add_child(battle)
	get_player().get_parent().add_child(battle_canvas)
	get_tree().paused = true


## [param pool] must be an [Array] of [Dictionary]s. The dictionaries should follow this format:
## [codeblock] 
## {
##    # The value to return when picked; 
##	  value
##    # (1 to 100) the chance to be picked from the pool. All the chances should add up to 100
##	  chance
## }
## [/codeblock] 
## This fills a "bag" with items from the pool array. The number of items depends on the chance.
## By shuffling the bag and picking the front item the chance of picking an item should represent
## the set chance. [br]
## Probably it's not the most optimal way to do this, but if it works it works.
func weighted_random(pool : Array[Dictionary]) -> Variant:
	
	var bag = [] # The bag 
	for item in pool:
		for i in item.chance:
			bag.append(item.value)
	
	# Shuffle the bag and pick the front item 
	bag.shuffle()
	return bag.front()

## Returns a [Dictionary] useful for [method weighted_random]
func create_weighted_pool_element(value : Variant, chance : int) -> Dictionary:
	return {'value': value, 'chance': chance}


func generate_random_pokemon(id : String, form_number : int, level : int) -> Pokemon:
	
	var natures = GameVariables.NATURES.keys()
	var nature = natures[randi() % natures.size()]
	var is_shiny = randf() <= GameVariables.SHINY_CHANCE
	
	var ivs : Dictionary = generate_random_ivs()
	
	var pokemon = await Pokemon.new(id, form_number, '', level, is_shiny, 0, nature)
	
	var gender = 1 if randf() <= pokemon.species.gender_ratio else 0
	if pokemon.species.gender_ratio == -1:
		gender = 2
	pokemon.gender = gender

	return pokemon


func generate_random_ivs() -> Dictionary:
	return {
		'HP': randi() % 32,
		'ATTACK': randi() % 32,
		'DEFENSE': randi() % 32,
		'SPECIAL_ATTACK': randi() % 32,
		'SPECIAL_DEFENSE': randi() % 32,
		'SPEED': randi() % 32,
	}
