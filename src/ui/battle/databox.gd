class_name Databox extends Control

## Pokegodot Databox

const ICON_MALE: Texture2D = preload("res://assets/graphics/ui/gender_male_icon.png")
const ICON_FEMALE: Texture2D = preload("res://assets/graphics/ui/gender_female_icon.png")
const HP_BAR_TIME: float = 1.0 ## Time needed for the HP bar to go from full to empty.
const EXP_BAR_TIME: float = 0.5 ## Time needed for the EXP bar to move.

@export var enabled: bool = true
@export var pokemon_id: String = ""
@export var form_number: int = 0
@export var pokemon_name: String = ""
@export var hp: int = 1
@export var max_hp: int = 1
@export var level: int = 1
@export var experience: int = 0
@export var gender: Pokemon.Genders = Pokemon.Genders.MALE
@export_group("Nodes")
@export var name_label: Label
@export var hp_bar: Range
@export var hp_numbers: Label
@export var exp_bar: TextureProgressBar
@export var level_text: Label
@export var gender_sprite: TextureRect

var max_experience: int = 1
var shown_level: int = 0:
	set(value):
		shown_level = value
		if is_instance_valid(level_text):
			level_text.text = str(shown_level)

func _ready() -> void:
	refresh()


func refresh() -> void:
	if not enabled or not pokemon_id:
		return
	if is_instance_valid(hp_bar):
		hp_bar.max_value = max_hp
		hp_bar.value = hp
		_set_hp_numbers()

	shown_level = level

	max_experience = Experience.get_exp_at_level(min(level, Experience.MAX_LEVEL), Experience.get_growth_rate_by_id(pokemon_id, form_number))
	if is_instance_valid(exp_bar):
		if experience < max_experience:
			exp_bar.min_value = 0
			exp_bar.max_value = max_experience - 1
			exp_bar.value = experience
		else:
			exp_bar.value = exp_bar.min_value

	if is_instance_valid(name_label):
		name_label.text = pokemon_name


	match gender:
		Pokemon.Genders.MALE:
			gender_sprite.texture = ICON_MALE
		Pokemon.Genders.FEMALE:
			gender_sprite.texture = ICON_FEMALE
		Pokemon.Genders.GENDERLESS:
			gender_sprite.texture = null


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
	var time: float = abs(hp - hp_bar.value) / max_hp * HP_BAR_TIME

	tween.tween_method(_tween_hp_bar, hp_bar.value, hp, time)

	return tween


## Animates a single level. That means that if the pokemon bound to the databox is of a level higher than [member shown_level],
## this function will animate the bar up to the max and increase [member shown_level], otherwise it will just animate the bar
## up to the current experience points. [br]
## This helps if anything needs to happen between level ups (Like learning a move).
func animate_level() -> Tween:
	var tween: Tween = create_tween()

	if level > shown_level:
		if exp_bar:
			tween.tween_property(exp_bar, "value", exp_bar.max_value, EXP_BAR_TIME)
			tween.tween_callback(exp_bar.set.bind("min_value", Experience.get_exp_at_level(shown_level + 1, Experience.get_growth_rate_by_id(pokemon_id, form_number))))
			tween.tween_callback(exp_bar.set.bind("max_value", Experience.get_exp_at_level(shown_level + 2, Experience.get_growth_rate_by_id(pokemon_id, form_number)) - 1))
			tween.tween_callback(func(): shown_level += 1)
			tween.tween_callback(func(): exp_bar.value = exp_bar.min_value)
		else:
			tween.tween_interval(EXP_BAR_TIME)
	else:
		if exp_bar:
			tween.tween_property(exp_bar, "value", experience, EXP_BAR_TIME)
		else:
			tween.tween_interval(EXP_BAR_TIME)

	return tween


func animate_exp_bar() -> Tween:
	var tween: Tween = create_tween()

	if exp_bar.value == experience:
		tween.tween_interval(0.01)
		return tween

	var old_level: int = Experience.get_level_at_exp(int(exp_bar.value), Experience.get_growth_rate_by_id(pokemon_id))
	var delta_level: int = level - old_level

	var values: Array[Array] = []
	for i: int in delta_level:
		values.append(
			[
				Experience.get_exp_at_level(old_level + i, Experience.get_growth_rate_by_id(pokemon_id, form_number)),
				Experience.get_exp_at_level(old_level + i + 1, Experience.get_growth_rate_by_id(pokemon_id, form_number)) - 1,
				Experience.get_exp_at_level(old_level + i + 1, Experience.get_growth_rate_by_id(pokemon_id, form_number)) - 1,
			]
		)
	values.append(
		[
			Experience.get_exp_at_level(old_level + delta_level, Experience.get_growth_rate_by_id(pokemon_id, form_number)),
			Experience.get_exp_at_level(old_level + delta_level + 1, Experience.get_growth_rate_by_id(pokemon_id, form_number)) - 1,
			experience
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
