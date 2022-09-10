extends Control

enum STATES {
	START, # Battle start
	ACTION_SELECTION, # Action selection, like using a move or running away
	ACTION_EXECUTION, # The phase where the action gets executed
	WIN, LOSE, # When the player wins/loses
	RUN # When the player runs away
}

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
}

var state : = -1
var textbox : Label

# Data used if pokemons are not set. Should not be used if not for testing, scripts should invoke battles with pregenerated pokemons
export(Dictionary) var pokemon_1_data = {'ID': '', 'FORM_NUMBER': 0, 'NICKNAME': '', 'LEVEL': 1, 'GENDER': 0, 'SHINY': false}
export(Dictionary) var pokemon_2_data = {'ID': '', 'FORM_NUMBER': 0, 'NICKNAME': '', 'LEVEL': 1, 'GENDER': 0, 'SHINY': false}
export(BATTLE_SETTINGS) var setting = BATTLE_SETTINGS.cave1

onready var sprite_1 : = $Ground1/Sprite1
onready var sprite_2 : = $Ground2/Sprite2
onready var move_buttons : = [
	$MessageBox/Moves/MovesButtons/Move1,
	$MessageBox/Moves/MovesButtons/Move2,
	$MessageBox/Moves/MovesButtons/Move3,
	$MessageBox/Moves/MovesButtons/Move4,
]

var pokemon_1 : Resource
var pokemon_2 : Resource

func _ready() -> void:
	var _unused = get_viewport().connect('gui_focus_changed', self, '_on_focus_changed') 
	textbox = $MessageBox/Text
	
	$MessageBox/ActionSelection/Actions/Fight.grab_focus()

	load_scene()

	_handle_state(STATES.START)

func load_scene() -> void:
	
	# If Pokemons are not set, generate new ones
	if pokemon_1 == null:
		pokemon_1 = Pokemon.new(pokemon_1_data.ID.to_upper(), pokemon_1_data.FORM_NUMBER, pokemon_1_data.NICKNAME, pokemon_1_data.LEVEL, pokemon_1_data.SHINY, pokemon_1_data.GENDER)
	if pokemon_2 == null:
		pokemon_2 = Pokemon.new(pokemon_2_data.ID.to_upper(), pokemon_2_data.FORM_NUMBER, pokemon_2_data.NICKNAME, pokemon_2_data.LEVEL, pokemon_2_data.SHINY, pokemon_2_data.GENDER)
	
	
	sprite_1.texture = pokemon_1.back
	sprite_2.texture = pokemon_2.front

	# Offset sprites down to the ground
	var lowest_sprite1_pixel = Globals.get_lowest_pixel_position(sprite_1.texture.get_data())
	var lowest_sprite2_pixel = Globals.get_lowest_pixel_position(sprite_2.texture.get_data())

	sprite_1.offset.y += sprite_1.texture.get_height() - lowest_sprite1_pixel.y
	sprite_2.offset.y += sprite_2.texture.get_height() - lowest_sprite2_pixel.y

	$DataboxPokemon1.pokemon = pokemon_1
	$DataboxPokemon2.pokemon = pokemon_2

	# Set scenery
	$Bg.texture = BATTLE_SETTINGS_SPRITES[setting][0]
	$Bg/BgReverse.texture = $Bg.texture
	$Ground1.texture = BATTLE_SETTINGS_SPRITES[setting][1]
	$Ground2.texture = BATTLE_SETTINGS_SPRITES[setting][1]

	sync_move_buttons()


# Sync move buttons with player Pokemon's moves
func sync_move_buttons():
	for i in move_buttons.size():
		move_buttons[i].text = ''
		if pokemon_1.moves[i].MOVE != null:
			move_buttons[i].text = pokemon_1.moves[i].MOVE.name


func _handle_state(new_state : int):
	state = new_state
	var secs_per_character = 0.03
	if state == STATES.START:
		$MessageBox/ActionSelection.show()
		$MessageBox/Moves.hide()
		textbox.show()

		var new_text = 'What will %s do?' % pokemon_1.nickname
		textbox.text = new_text
		textbox.percent_visible = 0.0

		print(Globals.text_speed)
		var tween = create_tween()
		tween.tween_property(textbox, 'percent_visible', 1.0, new_text.length() * Globals.text_speed)


	elif state == STATES.ACTION_SELECTION:
		pass
	elif state == STATES.ACTION_EXECUTION:
		pass
	elif state == STATES.WIN:
		pass
	elif state == STATES.LOSE:
		pass
	elif state == STATES.RUN:
		$MessageBox/ActionSelection.hide()
		$MessageBox/Moves.hide()
		textbox.show()

		var new_text = 'Ran away safely!'
		textbox.text = new_text
		textbox.percent_visible = 0.0

		var tween = create_tween()
		tween.tween_property(textbox, 'percent_visible', 1.0, new_text.length() * Globals.text_speed)
		tween.tween_callback(get_tree(), 'quit').set_delay(new_text.length() * secs_per_character)



func _unhandled_input(_event: InputEvent) -> void:
	# if event.is_action_pressed('ui_accept'):
	# 	pokemon_1.hp -= pokemon_1.stats.HP * 0.1
	pass


func _on_focus_changed(node : Control):
	# If focused node is a move button, update move info
	if node in move_buttons:
		var index = move_buttons.find(node)
		# Setting PPs
		var max_pps = pokemon_1.moves[index].MOVE.total_pp * ((5 + pokemon_1.moves[index].PPUPs) / 5.0)
		$MessageBox/Moves/MoveDescription/PPLabel.text = str(pokemon_1.moves[index].PPs) + '/' + str(max_pps)
		# Setting type icon
		$MessageBox/Moves/MoveDescription/TypeLabel/Type.region_rect.position.y = $MessageBox/Moves/MoveDescription/TypeLabel/Type.region_rect.size.y * Globals.TYPES_INDEX[pokemon_1.moves[index].MOVE.type]
		# Setting category icon
		$MessageBox/Moves/MoveDescription/CategoryLabel/Category.region_rect.position.y = $MessageBox/Moves/MoveDescription/CategoryLabel/Category.region_rect.size.y * Globals.CATEGORIES_INDEX[pokemon_1.moves[index].MOVE.category]



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
