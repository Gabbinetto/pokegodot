extends Control

enum STATES {
	START, # Battle start
	ACTION_SELECTION, # Action selection, like using a move or running away
	ACTION_EXECUTION, # The phase where the action gets executed
	WIN, LOSE, # When the player wins/loses
	RUN # When the player runs away
}

# All the battle environments, like the background and the ground pokemons stand on
enum BATTLE_SETTINGS {
	cave1,
	cave1_ice,
	cave1_water,
	cave2,
	cave2_ice,
	cave2_water,
	cave3,
	cave3_ice,
	cave3_water,
	champion1,
	champion2,
	city,
	city_eve,
	city_night,
	distortion,
	elite1,
	elite2,
	elite3,
	elite4,
	elite5,
	elite6,
	elite7,
	elite8,
	field,
	field_eve,
	field_night,
}

var BATTLE_SETTINGS_SPRITES = {
	BATTLE_SETTINGS.cave1: [preload('res://Graphics/Battlebacks/cave1_bg.png'), preload('res://Graphics/Battlebacks/cave1_base1.png')],
	BATTLE_SETTINGS.cave1_ice: [preload('res://Graphics/Battlebacks/cave1_bg.png'), preload('res://Graphics/Battlebacks/cave1_ice_base1.png')],
	BATTLE_SETTINGS.cave1_water: [preload('res://Graphics/Battlebacks/cave1_bg.png'), preload('res://Graphics/Battlebacks/cave1_water_base1.png')],
	BATTLE_SETTINGS.cave2: [preload('res://Graphics/Battlebacks/cave2_bg.png'), preload('res://Graphics/Battlebacks/cave2_base1.png')],
	BATTLE_SETTINGS.cave2_ice: [preload('res://Graphics/Battlebacks/cave2_bg.png'), preload('res://Graphics/Battlebacks/cave2_ice_base1.png')],
	BATTLE_SETTINGS.cave2_water: [preload('res://Graphics/Battlebacks/cave2_bg.png'), preload('res://Graphics/Battlebacks/cave2_water_base1.png')],
	BATTLE_SETTINGS.cave3: [preload('res://Graphics/Battlebacks/cave3_bg.png'), preload('res://Graphics/Battlebacks/cave3_base1.png')],
	BATTLE_SETTINGS.cave3_ice: [preload('res://Graphics/Battlebacks/cave3_bg.png'), preload('res://Graphics/Battlebacks/cave3_ice_base1.png')],
	BATTLE_SETTINGS.cave3_water: [preload('res://Graphics/Battlebacks/cave3_bg.png'), preload('res://Graphics/Battlebacks/cave3_water_base1.png')],
	BATTLE_SETTINGS.champion1: [preload('res://Graphics/Battlebacks/champion1_bg.png'), preload('res://Graphics/Battlebacks/champion1_base1.png')],
	BATTLE_SETTINGS.champion2: [preload('res://Graphics/Battlebacks/champion2_bg.png'), preload('res://Graphics/Battlebacks/champion2_base1.png')],
	BATTLE_SETTINGS.city: [preload('res://Graphics/Battlebacks/city_bg.png'), preload('res://Graphics/Battlebacks/city_base1.png')],
	BATTLE_SETTINGS.city_eve: [preload('res://Graphics/Battlebacks/city_eve_bg.png'), preload('res://Graphics/Battlebacks/city_base1.png')],
	BATTLE_SETTINGS.city_night: [preload('res://Graphics/Battlebacks/city_night_bg.png'), preload('res://Graphics/Battlebacks/city_base1.png')],
	BATTLE_SETTINGS.distortion: [preload('res://Graphics/Battlebacks/distortion_bg.png'), preload('res://Graphics/Battlebacks/distortion_base1.png')],
	BATTLE_SETTINGS.elite1: [preload('res://Graphics/Battlebacks/elite1_bg.png'), preload('res://Graphics/Battlebacks/elite1_base1.png')],
	BATTLE_SETTINGS.elite2: [preload('res://Graphics/Battlebacks/elite2_bg.png'), preload('res://Graphics/Battlebacks/elite2_base1.png')],
	BATTLE_SETTINGS.elite3: [preload('res://Graphics/Battlebacks/elite3_bg.png'), preload('res://Graphics/Battlebacks/elite3_base1.png')],
	BATTLE_SETTINGS.elite4: [preload('res://Graphics/Battlebacks/elite4_bg.png'), preload('res://Graphics/Battlebacks/elite4_base1.png')],
	BATTLE_SETTINGS.elite5: [preload('res://Graphics/Battlebacks/elite5_bg.png'), preload('res://Graphics/Battlebacks/elite5_base1.png')],
	BATTLE_SETTINGS.elite6: [preload('res://Graphics/Battlebacks/elite6_bg.png'), preload('res://Graphics/Battlebacks/elite6_base1.png')],
	BATTLE_SETTINGS.elite7: [preload('res://Graphics/Battlebacks/elite7_bg.png'), preload('res://Graphics/Battlebacks/elite7_base1.png')],
	BATTLE_SETTINGS.elite8: [preload('res://Graphics/Battlebacks/elite8_bg.png'), preload('res://Graphics/Battlebacks/elite8_base1.png')],
	BATTLE_SETTINGS.field: [preload('res://Graphics/Battlebacks/field_bg.png'), preload('res://Graphics/Battlebacks/field_base1.png')],
	BATTLE_SETTINGS.field_eve: [preload('res://Graphics/Battlebacks/field_eve_bg.png'), preload('res://Graphics/Battlebacks/field_eve_base1.png')],
	BATTLE_SETTINGS.field_night: [preload('res://Graphics/Battlebacks/field_night_bg.png'), preload('res://Graphics/Battlebacks/field_night_base1.png')],
}

var state : = -1

# Setting nodes
@onready var textbox : = $MessageBox/Text
@onready var pokemon_1_databox : Databox = $DataboxPokemon1
@onready var pokemon_2_databox : Databox = $DataboxPokemon2
@onready var ground_1 : = $Ground1
@onready var ground_2 : = $Ground2
@onready var background : = $Bg

@onready var fight_button : Button = $MessageBox/ActionSelection/Actions/Fight
@onready var pokemons_button : Button = $MessageBox/ActionSelection/Actions/Pokemons
@onready var bag_button : Button = $MessageBox/ActionSelection/Actions/Bag
@onready var run_button : Button = $MessageBox/ActionSelection/Actions/Run

@onready var back_button : Button = $MessageBox/Moves/MoveDescription/BackButton



# Data used if pokemons are not set. Should not be used if not for testing, scripts should invoke battles with pregenerated pokemons
@export var pokemon_1_data : PokemonData
@export var pokemon_2_data : PokemonData
@export var setting : = BATTLE_SETTINGS.cave1

@onready var sprite_1 : = $Ground1/Sprite1
@onready var sprite_2 : = $Ground2/Sprite2
@onready var move_buttons : Array[Node] = [
	$MessageBox/Moves/MovesButtons/Move1,
	$MessageBox/Moves/MovesButtons/Move2,
	$MessageBox/Moves/MovesButtons/Move3,
	$MessageBox/Moves/MovesButtons/Move4,
]
@onready var animation : AnimationPlayer = $AnimationPlayer

var pokemon_1 : Pokemon
var pokemon_2 : Pokemon

var volatile_battle_data_1 : VolatileBattleData
var volatile_battle_data_2 : VolatileBattleData

var weather : GameVariables.WEATHERS = GameVariables.WEATHERS.NONE 


func _ready() -> void:
	var _unused = get_viewport().connect('gui_focus_changed', _on_focus_changed) 
	
	# Setting nodes

	fight_button.grab_focus()

	pokemon_1 = GameVariables.player_team[0]

	load_scene()

	# Initializing the volatile data
	volatile_battle_data_1 = VolatileBattleData.new(pokemon_1)
	volatile_battle_data_2 = VolatileBattleData.new(pokemon_2)

	_handle_state(STATES.START)
	
	# Connecting
	fight_button.pressed.connect(_on_fight_button_pressed)
	run_button.pressed.connect(_on_run_pressed)
	back_button.pressed.connect(_on_moves_back_pressed)
	
	for i in move_buttons.size():
		move_buttons[i].pressed.connect(
			func():
				_handle_state(STATES.ACTION_EXECUTION, {'move_index': i})
		)

func load_scene() -> void:
	
	# If Pokemons are not set, generate new ones
	

	if pokemon_1 == null:
		pokemon_1 = await Pokemon.new(pokemon_1_data.ID.to_upper(), pokemon_1_data.FORM_NUMBER, pokemon_1_data.NICKNAME, pokemon_1_data.LEVEL, pokemon_1_data.SHINY, pokemon_1_data.GENDER)
	if pokemon_2 == null:
		pokemon_2 = await Pokemon.new(pokemon_2_data.ID.to_upper(), pokemon_2_data.FORM_NUMBER, pokemon_2_data.NICKNAME, pokemon_2_data.LEVEL, pokemon_2_data.SHINY, pokemon_2_data.GENDER)
	
	sprite_1.texture = pokemon_1.back
	sprite_2.texture = pokemon_2.front

	# Offset sprites down to the ground
	var lowest_sprite1_pixel = Globals.get_lowest_pixel_position(sprite_1.texture.get_image())
	var lowest_sprite2_pixel = Globals.get_lowest_pixel_position(sprite_2.texture.get_image())

	sprite_1.offset.y += sprite_1.texture.get_height() - lowest_sprite1_pixel.y
	sprite_2.offset.y += sprite_2.texture.get_height() - lowest_sprite2_pixel.y

	pokemon_1_databox.pokemon = pokemon_1
	pokemon_2_databox.pokemon = pokemon_2

#	pokemon_1_databox.update_health_bar()

	# Set scenery
	background.texture = BATTLE_SETTINGS_SPRITES[setting][0]
	background.get_node('BgReverse').texture = background.texture
	ground_1.texture = BATTLE_SETTINGS_SPRITES[setting][1]
	ground_2.texture = BATTLE_SETTINGS_SPRITES[setting][1]

	sync_move_buttons()


# Sync move buttons with player Pokemon's moves
func sync_move_buttons():
	for i in move_buttons.size():
		move_buttons[i].text = ''
		if pokemon_1.moves[i].MOVE != null:
			move_buttons[i].text = pokemon_1.moves[i].MOVE.name
		else:
			move_buttons[i].disabled = true
			move_buttons[i].focus_mode = FOCUS_NONE


# Change the state of the fight.
# _data is an optional parameter only used by certain states of the fight like ACTION_EXECUTION
func _handle_state(new_state : int, _data = {}):
	state = new_state
	var secs_per_character = 0.03
	if state == STATES.START:
		animation.play('StartWild')

	elif state == STATES.ACTION_SELECTION:
		$MessageBox/ActionSelection.show()
		$MessageBox/Moves.hide()
		$MessageBox/ActionSelection/Actions/Fight.grab_focus()

		var new_text = 'What will %s do?' % pokemon_1.nickname

		_show_text(new_text)

	elif state == STATES.ACTION_EXECUTION:
		var player_move = pokemon_1.moves[_data.move_index].MOVE 
		var enemy_moves : Array[Dictionary] = pokemon_2.moves.duplicate()
		for i in range(enemy_moves.size() - 1, 0, -1):
			if enemy_moves[i].MOVE == null:
				enemy_moves.remove_at(i)
		enemy_moves.shuffle()
		var enemy_move = enemy_moves.front().MOVE 
		
		_process_battle_turn(player_move, enemy_move)
		
		_handle_state(STATES.ACTION_SELECTION)

	elif state == STATES.WIN:
		pass
		
	elif state == STATES.LOSE:
		pass
		
	elif state == STATES.RUN:
		$MessageBox/ActionSelection.hide()
		$MessageBox/Moves.hide()
		var new_text = 'Ran away safely!'

		var text_tween = _show_text(new_text)
		text_tween.tween_callback(_run_away).set_delay(new_text.length() * secs_per_character)


# Show text by setting the text in the label and tweening the percentage of visible characters
# Percentage visible is used instead of visible characters because it will always be 1.0 in the end
func _show_text(text : String):
	textbox.text = text
	textbox.visible_ratio = 0.0
	textbox.show()
	var tween = create_tween()
	tween.tween_property(textbox, 'visible_ratio', 1.0, text.length() * GameVariables.text_speed)
	return tween

# Used only in the start animations, not intended to be used elsewhere
# Shows the default wild pokemon text with the opposing pokemon name
func _show_wild_text():
	return _show_text('A wild %s appeared!' % pokemon_2.nickname)

func _unhandled_input(_event: InputEvent) -> void:
	if _event.is_action_pressed('ui_page_up'):
		pokemon_1.hp -= 1
		pokemon_2.hp -= 1
	if _event.is_action_pressed('A'):
		# If battle start animation is playing, allow the player to skip the animation by pressing the A button
		if animation.get_current_animation() == 'StartWild':
			animation.advance(animation.get_current_animation_length())
		if state == STATES.RUN:
			_run_away()
	pass


func _on_focus_changed(node : Control):
	# If focused node is a move button, update move info
	if node in move_buttons and node.disabled != true:
		var index = move_buttons.find(node)
		# Setting PPs
		var max_pps = pokemon_1.get_move_max_pp(index)
		$MessageBox/Moves/MoveDescription/PPLabel.text = 'PP: ' + str(pokemon_1.moves[index].PPs) + '/' + str(max_pps)
		# Setting type icon
		$MessageBox/Moves/MoveDescription/TypeLabel/Type.region_rect.position.y = $MessageBox/Moves/MoveDescription/TypeLabel/Type.region_rect.size.y * GameVariables.TYPES_INDEX[pokemon_1.moves[index].MOVE.type]
		# Setting category icon
		$MessageBox/Moves/MoveDescription/CategoryLabel/Category.region_rect.position.y = $MessageBox/Moves/MoveDescription/CategoryLabel/Category.region_rect.size.y * GameVariables.CATEGORIES_INDEX[pokemon_1.moves[index].MOVE.category]


# Button signals

func _on_fight_button_pressed() -> void:
	# Hide action selection and show moves
	textbox.hide()
	$MessageBox/Moves.show()
	$MessageBox/ActionSelection.hide()
	$MessageBox/Moves/MovesButtons/Move1.grab_focus()


func _on_moves_back_pressed() -> void:
	# Go back to action selection
	textbox.show()
	$MessageBox/Moves.hide()
	$MessageBox/ActionSelection.show()
	$MessageBox/ActionSelection/Actions/Fight.grab_focus()

func _on_run_pressed() -> void:
	# Exit battle (quitting the game is a placeholder)
	_handle_state(STATES.RUN)

func _run_away() -> void:
	var tween = create_tween()
	tween.tween_property($BlackScreen, 'modulate:a', 1.0, 0.5)
	tween.tween_callback(queue_free)
	get_tree().paused = false


func _process_battle_turn(player_attack : PokemonMove, enemy_attack : PokemonMove) -> void:
	
	var damage_to_enemy = BattleFunctions.damage_calculation(player_attack, volatile_battle_data_1, volatile_battle_data_2)
	var damage_to_player = BattleFunctions.damage_calculation(enemy_attack, volatile_battle_data_2, volatile_battle_data_1)
	
	pokemon_1.hp -= damage_to_player
	pokemon_2.hp -= damage_to_enemy
