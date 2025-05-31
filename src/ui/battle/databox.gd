class_name Databox extends Control

## Pokegodot Databox

const HP_BAR_TIME: float = 1.0 ## Time needed for the HP bar to go from full to empty.
const EXP_BAR_TIME: float = 0.5 ## Time needed for the EXP bar to move.

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

var shown_level: int = 0:
	set(value):
		shown_level = value
		if is_instance_valid(level_text):
			level_text.text = str(shown_level)

func _ready() -> void:
	_refresh()


func _refresh() -> void:
	if not pokemon or not enabled:
		return
	if is_instance_valid(hp_bar):
		hp_bar.max_value = pokemon.max_hp
		hp_bar.value = pokemon.hp
		_set_hp_numbers()

	if is_instance_valid(exp_bar):
		if pokemon.level < Experience.MAX_LEVEL:
			exp_bar.min_value = Experience.get_exp_at_level(pokemon.level, pokemon.species.growth_rate)
			exp_bar.max_value = Experience.get_exp_at_level(pokemon.level + 1, pokemon.species.growth_rate) - 1
			exp_bar.value = pokemon.experience
		else:
			exp_bar.value = exp_bar.min_value

	if is_instance_valid(name_label):
		name_label.text = pokemon.name

	shown_level = pokemon.level


func _set_hp_numbers() -> void:
	if not is_instance_valid(hp_numbers):
		return
	hp_numbers.text = "%d/%d" % [ceili(hp_bar.value), roundi(hp_bar.max_value)]


func _tween_hp_bar(value: float) -> void:
	if hp_bar:
		hp_bar.value = value
		_set_hp_numbers()


func animate_hp_bar() -> Tween:
	var tween: Tween = create_tween()
	var time: float = abs(pokemon.hp - hp_bar.value) / pokemon.max_hp * HP_BAR_TIME

	tween.tween_method(_tween_hp_bar, hp_bar.value, pokemon.hp, time)

	return tween


func animate_exp_bar() -> Tween:
	var tween: Tween = create_tween()

	if exp_bar.value == pokemon.experience:
		tween.tween_interval(0.01)
		return tween

	var old_level: int = Experience.get_level_at_exp(int(exp_bar.value), pokemon.species.growth_rate)
	var level: int = pokemon.level
	var delta_level: int = level - old_level

	var values: Array[Array] = []
	for i: int in delta_level:
		values.append(
			[
				Experience.get_exp_at_level(old_level + i, pokemon.species.growth_rate),
				Experience.get_exp_at_level(old_level + i + 1, pokemon.species.growth_rate) - 1,
				Experience.get_exp_at_level(old_level + i + 1, pokemon.species.growth_rate) - 1,
			]
		)
	values.append(
		[
			Experience.get_exp_at_level(pokemon.level, pokemon.species.growth_rate),
			Experience.get_exp_at_level(pokemon.level + 1, pokemon.species.growth_rate) - 1,
			pokemon.experience
		]
	)

	for i: int in values.size():
		var min_value: int = values[i][0]
		var max_value: int = values[i][1]
		var target_value: int = values[i][2]

		tween.tween_callback(exp_bar.set.bind("min_value", min_value))
		tween.tween_callback(exp_bar.set.bind("max_value", max_value))

		if i > 0:
			tween.tween_callback(exp_bar.set.bind("value", min_value))

		tween.tween_property(exp_bar, "value", target_value, EXP_BAR_TIME)

		if i < values.size() - 1:
			tween.tween_callback(func(): shown_level += 1)

	return tween
