class_name Databox extends Control


@export var enabled: bool = true
@export var pokemon: Pokemon:
	set(value):
		pokemon = value
		_refresh()
@export var name_label: Label
@export var hp_bar: HPBar
@export var hp_numbers: Label
@export var exp_bar: TextureProgressBar
@export var level_text: Label


func _ready() -> void:

	_refresh()


func _process(_delta: float) -> void:
	if not pokemon or not enabled:
		return


	if is_instance_valid(name_label):
		name_label.text = pokemon.name


	if is_instance_valid(hp_bar) and hp_bar.value != pokemon.hp:
		hp_bar.value = move_toward(hp_bar.value, pokemon.hp, 1)
		
		if is_instance_valid(hp_numbers):
			hp_numbers.text = "%d/%d" % [hp_bar.value, hp_bar.max_value]
	

	if is_instance_valid(level_text):
		level_text.text = str(pokemon.level)


	if is_instance_valid(exp_bar):
		# TODO: Completely revise in the future, possibly with a tween
		var min_exp: int = Experience.calculate_exp(pokemon.level, pokemon.species.growth_rate)
		var max_exp: int = Experience.calculate_exp(pokemon.level + 1, pokemon.species.growth_rate)
		var exp_percentage: float = smoothstep(min_exp, max_exp, pokemon.experience)
		if exp_percentage > exp_bar.value:
			exp_bar.value = move_toward(exp_bar.value, exp_percentage, exp_bar.step)
		else:
			exp_bar.value = exp_percentage


func _refresh() -> void:
	if not pokemon or not enabled:
		return
	if is_instance_valid(hp_bar):
		hp_bar.max_value = pokemon.max_hp
		hp_bar.value = pokemon.hp

	if is_instance_valid(hp_numbers):
		hp_numbers.text = "%d/%d" % [pokemon.hp, pokemon.max_hp]
