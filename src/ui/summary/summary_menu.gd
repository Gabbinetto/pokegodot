class_name SummaryMenu extends Control

signal closed

const MENU_SCENE: PackedScene = preload("res://src/ui/summary/summary_menu.tscn")
const GENDER_FEMALE_ICON = preload("res://assets/graphics/ui/gender_female_icon.png")
const GENDER_MALE_ICON = preload("res://assets/graphics/ui/gender_male_icon.png")
const NATURE_NEUTRAL = preload("res://assets/resources/ui/text_resources/light_gray.tres")
const NATURE_UP = preload("res://assets/resources/ui/text_resources/nature_up.tres")
const NATURE_DOWN = preload("res://assets/resources/ui/text_resources/nature_down.tres")
const SPRITE_ICON_UPDATE_FRAMES: int = 20
const SOUND_CHANGE_PAGE = preload("res://assets/audio/sfx/GUI summary change page.ogg")

@export var screens: Array[Control]
@export var screen_buttons: Array[TextureButton]
@export var screen_buttons_pressed: Array[Texture2D]
@export var moves_screen_button: BaseButton
@export var close_button: BaseButton
@export_group("General", "pokemon_")
@export var pokemon_name: Label
@export var pokemon_level: Label
@export var pokemon_sprite: TextureRect
@export var pokemon_gender_icon: TextureRect
@export_group("Info", "info_")
@export var info_dex_number: Label
@export var info_species: Label
@export var info_type_1: TextureRect
@export var info_type_2: TextureRect
@export var info_ot: Label
@export var info_id_number: Label
@export var info_exp: Label
@export var info_next_exp: Label
@export var info_exp_bar: Range
@export_group("Trainer Memo", "memo_")
@export var memo_nature: Label
@export var memo_date_obtained: Label
@export var memo_met_place: Label
@export var memo_met_level: Label
@export var memo_personality: Label
@export_group("Skills", "skills_")
@export var skills_hp: Label
@export var skills_hp_bar: Range
@export var skills_stats_names: Array[Label]
@export var skills_stats_values: Array[Label]
@export var skills_ability: Label
@export var skills_ability_description: Label
@export_group("Moves", "moves_")
@export var moves_buttons: Array[SummaryMoveButton]
@export var moves_detail_panel: Control
@export var moves_detail_icon: Sprite2D
@export var moves_detail_type_1: TextureRect
@export var moves_detail_type_2: TextureRect
@export var moves_category: TextureRect
@export var moves_power: Label
@export var moves_accuracy: Label
@export var moves_description_scroll: ScrollContainer
@export var moves_description: Label
@export var moves_description_start_timer: Timer
@export var moves_description_stop_timer: Timer

var pokemon_list: Array[Pokemon]
var current_index: int = 0:
	set(value):
		current_index = value
		_refresh_pokemon.call_deferred()
var current_pokemon: Pokemon:
	get: return pokemon_list[current_index] if pokemon_list.size() else null
	set(value): pokemon_list[current_index] = value
var current_screen_index: int = 0:
	set(value):
		current_screen_index = value
		_refresh_screen()
var current_screen: Control:
	get: return screens[current_screen_index]
	set(value): screens[current_screen_index] = value

var can_switch_moves: bool = true
var selected_move_button: SummaryMoveButton
var last_move_button: SummaryMoveButton


func _ready() -> void:
	for i: int in min(screens.size(), screen_buttons.size(), screen_buttons_pressed.size()):
		screen_buttons[i].set_meta("normal", screen_buttons[i].texture_normal)
		screen_buttons[i].set_meta("pressed", screen_buttons_pressed[i])
		screen_buttons[i].focus_entered.connect(set.bind("current_screen_index", i))

	close_button.pressed.connect(closed.emit)

	for button: SummaryMoveButton in moves_buttons:
		button.disabled = not can_switch_moves
		button.pressed.connect(_on_move_button_pressed.bind(button))
		button.focus_entered.connect(_on_move_button_focused.bind(button))
		button.focus_exited.connect(_on_move_button_unfocused.call_deferred)


	moves_screen_button.pressed.connect(_on_move_screen_button_pressed)
	moves_screen_button.focus_entered.connect(_reset_move_buttons_state)

	_refresh_pokemon()
	_refresh_screen()

	if TransitionManager.transition:
		TransitionManager.play_out()
		await TransitionManager.finished


func _process(_delta: float) -> void:
	if Engine.get_process_frames() % SPRITE_ICON_UPDATE_FRAMES == 0 and moves_detail_icon and moves_detail_panel.visible:
		moves_detail_icon.frame = 0 if bool(moves_detail_icon.frame) else 1

	# Scroll move description
	if moves_detail_panel.visible and Engine.get_process_frames() % 5 and moves_description_start_timer.is_stopped() and moves_description_stop_timer.is_stopped():
		var last_description_scroll = moves_description_scroll.scroll_vertical
		moves_description_scroll.scroll_vertical += 1
		if moves_description_scroll.scroll_vertical == last_description_scroll:
			moves_description_stop_timer.start()
			await moves_description_stop_timer.timeout
			moves_description_scroll.scroll_vertical = 0
			moves_description_start_timer.start()


func _show_screen(screen: Control) -> void:
	for node: Control in screens:
		if node == screen:
			if not node.visible:
				node.show()
				Audio.play_sfx(SOUND_CHANGE_PAGE)
		else:
			node.hide()


func _refresh_screen() -> void:
	_show_screen(current_screen)
	for button: TextureButton in screen_buttons:
		var texture: Texture2D
		if button.get_index() == current_screen_index:
			texture = button.get_meta("pressed")
			button.grab_focus.call_deferred()
		else:
			texture = button.get_meta("normal")
		button.texture_normal = texture
		button.texture_pressed = texture
		button.texture_hover = texture


func _refresh_pokemon() -> void:
	if not current_pokemon:
		return

	#region General
	pokemon_name.text = current_pokemon.name
	pokemon_level.text = str(current_pokemon.level)
	if current_pokemon.gender == Pokemon.Genders.GENDERLESS:
		pokemon_gender_icon.hide()
	else:
		pokemon_gender_icon.show()
		pokemon_gender_icon.texture = GENDER_FEMALE_ICON if current_pokemon.gender == Pokemon.Genders.FEMALE else GENDER_MALE_ICON
	pokemon_sprite.texture = current_pokemon.sprite_front
	#endregion

	#region Info screen
	info_dex_number.text = "%03d" % DB.pokemon[current_pokemon.species.id].number
	info_species.text = current_pokemon.species.name
	info_type_1.texture = Types.ICONS[current_pokemon.species.types[0]]
	if current_pokemon.species.types.size() > 1:
		info_type_2.show()
		info_type_2.texture = Types.ICONS[current_pokemon.species.types[1]]
	else:
		info_type_2.hide()
	info_ot.text = current_pokemon.original_trainer_name
	info_id_number.text = "%05d" % current_pokemon.original_trainer_id
	info_exp.text = str(current_pokemon.experience)
	if current_pokemon.level < Experience.MAX_LEVEL:
		info_next_exp.text = str(
			Experience.tables[current_pokemon.species.growth_rate][current_pokemon.level] - current_pokemon.experience
		)
		info_exp_bar.min_value = Experience.tables[current_pokemon.species.growth_rate][current_pokemon.level - 1]
		info_exp_bar.max_value = Experience.tables[current_pokemon.species.growth_rate][current_pokemon.level]
		info_exp_bar.value = current_pokemon.experience
	else:
		info_next_exp.text = "0"
		info_exp_bar.min_value = 0
		info_exp_bar.value = 0
	# TODO: Add pokeball and item icons
	#endregion

	#region Trainer memo
	memo_nature.text = current_pokemon.nature.capitalize()
	var datetime: Dictionary = Time.get_datetime_dict_from_unix_time(int(current_pokemon.obtained_time))
	memo_date_obtained.text = "%d %s, %d" % [datetime.day, Globals.MONTH_NAMES[datetime.month], datetime.year]
	memo_met_place.text = "Placeholder" # TODO: Add map names
	memo_met_level.text = "Met at Lv. %d" % current_pokemon.obtained_level
	memo_personality.text = "Lorem ipsum dolor sit amet." # TODO: Add personality characteristics
	#endregion

	#region Skills
	skills_hp.text = "%d/%d" % [current_pokemon.hp, current_pokemon.max_hp]
	skills_hp_bar.max_value = current_pokemon.max_hp
	skills_hp_bar.value = current_pokemon.hp
	var nature_modifiers: Array[float] = Globals.natures[current_pokemon.nature].values()
	for i in range(1, 6):
		if nature_modifiers[i] > 1:
			skills_stats_names[i - 1].label_settings = NATURE_UP
		elif nature_modifiers[i] < 1:
			skills_stats_names[i - 1].label_settings = NATURE_DOWN
		else:
			skills_stats_names[i - 1].label_settings = NATURE_NEUTRAL
		skills_stats_values[i - 1].text = str(current_pokemon.stats.values()[i])
	# TODO: Add ability names and description
	skills_ability.text = "Placeholder"
	skills_ability_description.text = "Lorem ipsum dolor sit amet."
	#endregion

	#region Moves
	for i: int in moves_buttons.size():
		if i < current_pokemon.moves.size():
			moves_buttons[i].show()
			moves_buttons[i].move = current_pokemon.moves[i]
		else:
			moves_buttons[i].hide()
	moves_detail_icon.texture = current_pokemon.sprite_icon
	moves_detail_type_1.texture = Types.ICONS[current_pokemon.species.types[0]]
	if current_pokemon.species.types.size() > 1:
		moves_detail_type_2.show()
		moves_detail_type_2.texture = Types.ICONS[current_pokemon.species.types[1]]
	else:
		moves_detail_type_2.hide()
	#endregion
	# TODO: Add ribbons



func _on_move_button_pressed(button: SummaryMoveButton) -> void:
	Audio.play_sfx(Audio.SOUNDS.GUI_SEL_DECISION)
	if not selected_move_button:
		selected_move_button = button
		moves_buttons[0].focus_neighbor_top = moves_buttons[0].get_path()
		return
	_swap_moves(
		current_pokemon.moves.find(selected_move_button.move),
		current_pokemon.moves.find(button.move)
	)
	selected_move_button = null
	moves_buttons[0].focus_neighbor_top = moves_screen_button.get_path()
	for move_button: SummaryMoveButton in moves_buttons:
		move_button.button_pressed = false
	_refresh_pokemon()
	_on_move_button_focused(button)


func _on_move_button_unfocused() -> void:
	if not moves_buttons.has(get_viewport().gui_get_focus_owner()):
		moves_detail_panel.hide()
		moves_screen_button.grab_focus.call_deferred()
		Audio.play_sfx(Audio.SOUNDS.GUI_MENU_CLOSE)


func _on_move_button_focused(button: SummaryMoveButton) -> void:
	Audio.play_sfx(Audio.SOUNDS.GUI_SEL_CURSOR)

	last_move_button = button

	moves_category.texture = PokemonMove.CATEGORY_ICONS[button.move.category]
	moves_power.text = str(button.move.power) if button.move.power > 0 else "---"
	moves_accuracy.text = (str(button.move.accuracy) + "%") if button.move.accuracy > 0 else "---"
	moves_description.text = button.move.description
	moves_detail_panel.show()

	moves_description_start_timer.start()
	moves_description_stop_timer.stop()
	moves_description_scroll.scroll_vertical = 0


func _on_move_screen_button_pressed() -> void:
	moves_buttons[0].grab_focus.call_deferred()


func _reset_move_buttons_state() -> void:
	if selected_move_button:
		selected_move_button.button_pressed = false
		selected_move_button = null
	moves_buttons[0].focus_neighbor_top = moves_screen_button.get_path()


func _swap_moves(from: int, to: int) -> void:
	var tmp: PokemonMove = current_pokemon.moves[from]
	current_pokemon.moves[from] = current_pokemon.moves[to]
	current_pokemon.moves[to] = tmp


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if selected_move_button:
			_reset_move_buttons_state()
		elif not selected_move_button and moves_buttons.has(get_viewport().gui_get_focus_owner()):
			moves_screen_button.grab_focus.call_deferred()
		else:
			closed.emit()
	if get_viewport().gui_get_focus_owner() is SummaryMoveButton:
		return
	if event.is_action_pressed("ui_up"):
		current_index = max(current_index - 1, 0)
	if event.is_action_pressed("ui_down") and get_viewport().gui_get_focus_owner() != moves_screen_button:
		current_index = min(current_index + 1, pokemon_list.size() - 1)


static func create(list: Array[Pokemon], attributes: Dictionary[String, Variant] = {}) -> SummaryMenu:
	var summary_menu: SummaryMenu = MENU_SCENE.instantiate()
	summary_menu.pokemon_list.assign(list)
	summary_menu.current_index = attributes.get("starting_index", 0)
	summary_menu.can_switch_moves = not attributes.get("in_battle", false)
	return summary_menu
