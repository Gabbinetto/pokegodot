class_name Databox extends Control


const HP_BAR_TIME: float = 1.0 ## Time needed for the HP bar to go from full to empty.

@export var enabled: bool = true
@export var pokemon: Pokemon:
	set(value):
		pokemon = value
		_refresh()
@export var name_label: Label
@export var hp_bar: Range
@export var hp_numbers: Label
@export var exp_bar: TextureProgressBar
@export var level_text: Label


func _ready() -> void:
	_refresh()


func _process(_delta: float) -> void:
	if not pokemon or not enabled:
		return


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
		_set_hp_numbers()

	if is_instance_valid(name_label):
		name_label.text = pokemon.name


func _set_hp_numbers() -> void:
	if not is_instance_valid(hp_numbers):
		return
	hp_numbers.text = "%d/%d" % [hp_bar.value, hp_bar.max_value]


func _tween_bar(value: int) -> void:
	if hp_bar:
		hp_bar.value = value
		_set_hp_numbers()


func animate_hp_bar() -> Tween:
	var tween: Tween = create_tween()
	var time: float = abs(pokemon.hp - hp_bar.value) / pokemon.max_hp * HP_BAR_TIME
	
	tween.tween_method(_tween_bar, hp_bar.value, pokemon.hp, time)
	
	return tween
