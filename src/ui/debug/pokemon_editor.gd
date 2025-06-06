class_name PokemonEditor extends Control

signal closed

const MENU_SCENE: PackedScene = preload("res://src/ui/debug/pokemon_editor.tscn")
const ICON_MALE: Texture2D = preload("res://assets/graphics/ui/gender_male_icon.png")
const ICON_FEMALE: Texture2D = preload("res://assets/graphics/ui/gender_female_icon.png")

@export var pokemon: Pokemon:
	set(value):
		pokemon = value
		if pokemon:
			_sync_pokemon(true)

@export_group("Nodes")
@export var close: BaseButton
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
@export var heal: BaseButton
@export var stats: Control

var stat_labels: Dictionary[String, Label] = {}
var evs: Dictionary[String, Range] = {}
var ivs: Dictionary[String, Range] = {}

var valid_moves: Array[String]

func _ready() -> void:

	close.pressed.connect(closed.emit)

	for species_name: String in DB.pokemon.keys():
		species.add_item(species_name.capitalize())

	for key: String in Globals.natures:
		var item_name: String = key.capitalize()
		var up: String = ""
		var down: String = ""
		for stat: String in Globals.natures[key]:
			if Globals.natures[key][stat] > 1:
				up = "+" + Globals.SHORT_STATS[stat]
			elif Globals.natures[key][stat] < 1:
				down = "-" + Globals.SHORT_STATS[stat]
		if not up or not down:
			up = "-"
			down = "-"
		nature.add_item(
			"%s (%s, %s)" % [item_name, up, down]
		)

	nickname.grab_focus.call_deferred()

	species.item_selected.connect(species_edit)
	forms.item_selected.connect(form_edit)
	nickname.text_submitted.connect(name_edit)
	level.value_changed.connect(level_edit)
	experience.value_changed.connect(exp_edit)
	nature.item_selected.connect(nature_edit)
	shiny.toggled.connect(shiny_edit)
	super_shiny.toggled.connect(super_shiny_edit)
	gender.pressed.connect(gender_edit)
	for node: Control in moves.get_children():
		node.get_node("Move").item_selected.connect(move_edit.bind(node.get_index()))
		node.get_node("Clear").pressed.connect(clear_move.bind(node.get_index()))
	moves_at_level.pressed.connect(func():
		pokemon.set_moves(pokemon.level, true)
		_sync_moves(false)
	)
	heal.pressed.connect(func():
		pokemon.heal()
		_sync_pokemon()
	)
	for child: Control in stats.get_children():
		stat_labels[child.name] = child.get_node("Stat")
		evs[child.name] = child.get_node("EVS")
		child.get_node("EVS").value_changed.connect(stat_value_edit.bind(child.name, false))
		ivs[child.name] = child.get_node("IVS")
		child.get_node("IVS").value_changed.connect(stat_value_edit.bind(child.name, true))



func _sync_forms() -> void:
	forms.clear()
	for form: Dictionary in DB.pokemon[pokemon.species.id].forms:
		var form_name: String = form.get("form_name", "")
		if not form_name:
			form_name = "Normal"
		form_name += ": %d" % form.form_number
		forms.add_item(form_name, form.form_number)
	forms.selected = pokemon.species.form_number


func _sync_moves(change_options: bool = true) -> void:
	if change_options:
		valid_moves.clear()
		valid_moves.append_array(pokemon.species.moves.map(func(item: Dictionary): return item.id))
		valid_moves.append_array(pokemon.species.tutor_moves)
		valid_moves.append_array(pokemon.species.egg_moves)
		for node: Control in moves.get_children():
			var options: OptionButton = node.get_node("Move")
			options.clear()
			for id: String in valid_moves:
				options.add_item(id.capitalize())
	for i: int in 4:
		var options: OptionButton = moves.get_child(i).get_node("Move")
		if i >= pokemon.moves.size():
			options.selected = -1
		else:
			options.selected = valid_moves.find(pokemon.moves[i].id)



func _sync_pokemon(sync_moves_options: bool = false) -> void:
	sprite.texture = pokemon.sprite_front
	species.selected = DB.pokemon.keys().find(pokemon.species.id)
	_sync_forms()
	nickname.text = pokemon.name
	if pokemon.species.gender_ratio == -1:
		gender.icon = null
	else:
		gender.icon = ICON_FEMALE if pokemon.gender == Pokemon.Genders.FEMALE else ICON_MALE

	shiny.button_pressed = pokemon.shiny
	super_shiny.button_pressed = pokemon.super_shiny

	level.set_value_no_signal(pokemon.level)
	level.min_value = 1
	level.max_value = Experience.MAX_LEVEL
	experience.min_value = pokemon.species.exp_table.front()
	experience.max_value = pokemon.species.exp_table.back()
	experience.set_value_no_signal(pokemon.experience)

	nature.selected = Globals.natures.keys().find(pokemon.nature)

	_sync_moves(sync_moves_options)

	for stat: String in Globals.STATS.values():
		stat_labels[stat].text = str(pokemon.stats[stat])
		evs[stat].set_value_no_signal(pokemon.evs[stat])
		ivs[stat].set_value_no_signal(pokemon.ivs[stat])


#region Edit functions
func _set_new_species(new_species: PokemonSpecies) -> void:
	pokemon.species = new_species
	pokemon.set_sprites()
	pokemon.calculate_stats()

	_sync_pokemon(true)


func species_edit(index: int) -> void:
	var new_species: PokemonSpecies = PokemonSpecies.new(
		DB.pokemon.keys()[index]
	)
	_set_new_species(new_species)


func form_edit(index: int) -> void:
	var new_species: PokemonSpecies = PokemonSpecies.new(
		pokemon.species.id, index
	)
	_set_new_species(new_species)


func name_edit(new_text: String) -> void:
	pokemon.name = new_text
	_sync_pokemon()


func level_edit(value: int) -> void:
	pokemon.level = value
	pokemon.calculate_stats()
	_sync_pokemon()


func exp_edit(value: int) -> void:
	pokemon.experience = value
	pokemon.calculate_stats()
	_sync_pokemon()


func shiny_edit(value: bool) -> void:
	pokemon.shiny = value
	pokemon.set_sprites()
	_sync_pokemon()


func super_shiny_edit(value: bool) -> void:
	pokemon.super_shiny = value
	pokemon.set_sprites()
	_sync_pokemon()


func nature_edit(index: int) -> void:
	pokemon.nature = Globals.natures.keys()[index]
	pokemon.calculate_stats()
	_sync_pokemon()


func gender_edit() -> void:
	if pokemon.species.female_chance >= 1:
		pokemon.gender = Pokemon.Genders.FEMALE
	elif pokemon.species.female_chance <= 0:
		pokemon.gender = Pokemon.Genders.MALE
	else:
		pokemon.gender = Pokemon.Genders.MALE if pokemon.gender == Pokemon.Genders.FEMALE else Pokemon.Genders.FEMALE
	pokemon.set_sprites()
	_sync_pokemon()


func move_edit(index: int, slot: int) -> void:
	var id: String = valid_moves[index]
	var learnt_already: int = pokemon.moves.map(func(learnt_move: PokemonMove): return learnt_move.id).find(id)
	if learnt_already != -1:
		var options: OptionButton = moves.get_child(slot).get_node("Move")
		options.selected = valid_moves.find(pokemon.moves[learnt_already])
		return
	var move: PokemonMove = PokemonMove.new(id)

	if slot >= pokemon.moves.size():
		pokemon.moves.append(move)
	else:
		pokemon.moves[slot] = move

	_sync_moves(false)



func clear_move(slot: int) -> void:
	if pokemon.moves.size() <= slot or pokemon.moves.size() == 0:
		return

	pokemon.moves.pop_at(slot)
	_sync_moves(false)


func stat_value_edit(new_value: int, stat: String, is_ivs: bool) -> void:
	if is_ivs:
		pokemon.ivs[stat] = new_value
	else:
		pokemon.evs[stat] = new_value

	pokemon.calculate_stats()
	_sync_pokemon()

#endregion


static func create() -> PokemonEditor:
	return MENU_SCENE.instantiate()
