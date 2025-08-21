@tool
extends Control

const PKDebug: GDScript = preload("res://addons/pkdebug/pkdebug.gd")

@export var update_button: BaseButton
@export_group("Nodes")
@export var sprite: TextureRect
@export var species: OptionButton
@export var forms: OptionButton
@export var nickname: LineEdit
@export var gender: Button
@export var shiny: CheckButton
@export var super_shiny: CheckButton
@export var level: SpinBox
@export var experience: SpinBox
@export var nature: OptionButton
@export var moves: Control
@export var moves_at_level: BaseButton
@export var stats: Control

var plugin: PKDebug
var slot: int
var pokemon: Dictionary[String, Variant]

var _pokemon_ids: Array[String]
var _natures: Array[String]
var _species_data: Dictionary[String, Variant]
var _form_data: Dictionary[String, Variant]
var _moves: Array[String]

func setup(parent_plugin: PKDebug) -> void:
	plugin = parent_plugin

	update_button.pressed.connect(
		func():
			plugin.send_message("set_pokemon", [slot, pokemon])
	)

	_pokemon_ids.assign(
		JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/pokemon.json")).keys()
	)
	for id: String in _pokemon_ids:
		species.add_item(id)
	species.selected = -1
	
	_natures.assign(
		JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/natures.json")).keys()
	)
	for id: String in _natures:
		nature.add_item(id)
	nature.selected = -1
	
	_moves.assign(
		JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/moves.json")).keys()
	)
	_moves.sort()
	for move_slot: Control in moves.get_children():
		var button: OptionButton = move_slot.get_node("ID")
		for move: String in _moves:
			button.add_item(move)
		button.selected = -1
		
	for stat: Label in stats.get_node("Names").get_children().slice(1):
		stat.text = stat.name.capitalize()

	_connect_signals()


func _set_level(level: int) -> void:
	if level == pokemon.level:
		return
	pokemon.level = level
	var exp: int = await plugin.request_exp(level, _form_data.growth_rate)
	experience.set_value_no_signal(exp)
	pokemon.experience = exp


func _set_exp(exp: int) -> void:
	pokemon.experience = exp
	var new_level: int = await plugin.request_level(exp, _form_data.growth_rate)
	level.set_value_no_signal(new_level)
	pokemon.level = new_level


func _set_move(id: int, slot: int) -> void:
	if slot >= pokemon.moves.size():
		slot = pokemon.moves.size()
		pokemon.moves.append({} as Dictionary[String, Variant])

	pokemon.moves[slot]["id"] = _moves[id]

	_sync_moves()


func _set_pp_ups(value: int, slot: int) -> void:
	if slot >= pokemon.moves.size():
		return
	pokemon.moves[slot]["pp_upgrades"] = value


func _set_moves_at_level() -> void:
	var level_moves: Array = _form_data.moves.filter(func(move: Dictionary): return move.level <= pokemon.level)
	level_moves.reverse()
	pokemon.moves.clear()
	for i: int in min(moves.get_child_count(), level_moves.size()):
		_set_move(_moves.find(level_moves[i].id), i)


func _set_stat(value: int, stat: String, set_evs: bool) -> void:
	# If not set_evs, set ivs instead
	if set_evs:
		pokemon.evs[stat] = value
	else:
		pokemon.ivs[stat] = value
	_sync_stats()


func set_pokemon(pokemon_slot: int, new_pokemon: Dictionary[String, Variant]) -> void:
	slot = pokemon_slot
	pokemon = new_pokemon

	sprite.texture = pokemon.get("texture")

	_sync()


#region Syncing functions
func _connect_signals() -> void:
	species.item_selected.connect(
		func(id: int):
			pokemon["species_id"] = _pokemon_ids[id]
			pokemon["form"] = 0
			_sync_species()
	)
	forms.item_selected.connect(
		func(id: int):
			pokemon["form"] = id
			_sync_species()
			forms.selected = id
	)

	level.value_changed.connect(_set_level)
	experience.value_changed.connect(_set_exp)

	gender.pressed.connect(
		func():
			var old_gender: int = pokemon.gender
			if old_gender == 0:
				gender.text = "Female"
				pokemon.gender = 1
			elif old_gender == 1:
				gender.text = "Male"
				pokemon.gender = 0
			_sync_sprites()
	)

	shiny.pressed.connect(
		func():
			pokemon.shiny = shiny.button_pressed
			_sync_sprites()
	)
	super_shiny.pressed.connect(
		func():
			pokemon.super_shiny = super_shiny.button_pressed
			if pokemon.super_shiny:
				pokemon.shiny = true
				shiny.button_pressed = true
			_sync_sprites()
	)

	for move_slot: Control in moves.get_children():
		var button: OptionButton = move_slot.get_node("ID")
		button.item_selected.connect(_set_move.bind(move_slot.get_index()))
		var pp_ups: SpinBox = move_slot.get_node("PPUps")
		pp_ups.value_changed.connect(_set_pp_ups.bind(move_slot.get_index()))
	
	moves_at_level.pressed.connect(_set_moves_at_level)

	var filter_header: Callable = func(node: Node): return node.name != "Header"
	for stat: SpinBox in stats.get_node("IVs").get_children().filter(filter_header):
		stat.value_changed.connect(_set_stat.bind(stat.name, false))
	for stat: SpinBox in stats.get_node("EVs").get_children().filter(filter_header):
		stat.value_changed.connect(_set_stat.bind(stat.name, true))


func _sync() -> void:
	species.selected = _pokemon_ids.find(pokemon.species_id)
	nickname.text = pokemon.name
	gender.text = "Male" if pokemon.gender == 0 else "Female"
	shiny.button_pressed = pokemon.shiny
	super_shiny.button_pressed = pokemon.super_shiny
	level.set_value_no_signal(pokemon.level)
	experience.set_value_no_signal(pokemon.experience)
	nature.selected = _natures.find(pokemon.nature)

	_sync_species()
	_sync_moves()
	_sync_stats()


func _sync_species() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/pokemon.json"))
	_species_data.assign(data.get(pokemon.species_id))

	_form_data.assign(_species_data.forms[0].duplicate())
	if pokemon.form != 0:
		_form_data.merge(
			_species_data.forms[pokemon.form],
			true,
		)

	forms.clear()
	for form: Dictionary in _species_data.forms:
		var form_name: String = form.form_name
		if form_name.is_empty():
			form_name = "Normal"
		forms.add_item(form_name)
	
	gender.visible = _form_data.gender_ratio != -1
	var max_exps: Dictionary[int, int] = {}
	max_exps.assign(await plugin.request_max_exp())
	experience.max_value = max_exps[int(_form_data.growth_rate)]

	_sync_sprites()


func _sync_sprites() -> void:
	var dir: DirAccess = DirAccess.open("res://assets/graphics/pokemon_sprites/%s_%d/" % [pokemon.species_id, pokemon.form])
	if dir.get_open_error() != OK:
		EditorInterface.get_editor_toaster().push_toast("Couldn't load %s sprites." % pokemon.species_id, 1)
	var sprite_name: String = "front_%s_%s.png" % [
		"s" if pokemon.shiny else "n",
		"f" if pokemon.gender == 1 else "m",
	]
	if not dir.file_exists(sprite_name):
		sprite_name = "front_%s_m.png" % ("s" if pokemon.shiny else "n")
	
	var texture: Texture2D = load("res://assets/graphics/pokemon_sprites/%s_%d/%s" % [pokemon.species_id, pokemon.form, sprite_name])
	sprite.texture = texture


func _sync_moves() -> void:
	var moves_count: int = pokemon.get("moves", []).size()
	for i: int in moves_count:
		moves.get_child(i).get_node("ID").selected = _moves.find(pokemon.moves[i].id)
		moves.get_child(i).get_node("PPUps").set_value_no_signal(pokemon.moves[i].get("pp_upgrades", 0))
	
	var reversed_moves = moves.get_children()
	reversed_moves.reverse()
	for i: int in moves.get_child_count() - moves_count:
		reversed_moves[i].get_node("ID").selected = -1
		reversed_moves[i].get_node("PPUps").set_value_no_signal(0)


func _sync_stats() -> void:
	var filter_header: Callable = func(node: Node): return node.name != "Header"
	for stat: SpinBox in stats.get_node("IVs").get_children().filter(filter_header):
		stat.set_value_no_signal(pokemon.ivs.get(stat.name, 0))
	for stat: SpinBox in stats.get_node("EVs").get_children().filter(filter_header):
		stat.set_value_no_signal(pokemon.evs.get(stat.name, 0))
	
	var calculated_stats: Dictionary[String, int] = await plugin.request_stats(
		pokemon.species_id,
		_form_data.base_stats,
		pokemon.ivs,
		pokemon.evs,
		pokemon.level,
		pokemon.nature,
	)
	for stat: String in calculated_stats:
		stats.get_node("Values").get_node(stat).text = str(calculated_stats[stat])

#endregion
