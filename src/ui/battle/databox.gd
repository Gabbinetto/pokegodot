class_name Databox extends Control


@export var pokemon: Pokemon
@export var name_label: Label
@export var hp_bar_texture: Texture2D
@export var hp_bar: TextureProgressBar
@export var hp_numbers: DataboxNumbers
@export var exp_bar: TextureProgressBar
@export var level_text: DataboxNumbers

var hp_texture_high: AtlasTexture
var hp_texture_medium: AtlasTexture
var hp_texture_low: AtlasTexture


func _ready() -> void:
	hp_texture_high = AtlasTexture.new()
	hp_texture_high.atlas = hp_bar_texture
	hp_texture_high.region = Rect2(Vector2(0, hp_bar_texture.get_height() / 3.0 * 0), hp_bar_texture.get_size() * Vector2(1, 1.0 / 3.0))

	hp_texture_medium = AtlasTexture.new()
	hp_texture_medium.atlas = hp_bar_texture
	hp_texture_medium.region = Rect2(Vector2(0, hp_bar_texture.get_height() / 3.0 * 1), hp_bar_texture.get_size() * Vector2(1, 1.0 / 3.0))

	hp_texture_low = AtlasTexture.new()
	hp_texture_low.atlas = hp_bar_texture
	hp_texture_low.region = Rect2(Vector2(0, hp_bar_texture.get_height() / 3.0 * 2), hp_bar_texture.get_size() * Vector2(1, 1.0 / 3.0))

	_refresh()


func _process(_delta: float) -> void:
	if not pokemon:
		return


	if is_instance_valid(name_label):
		name_label.text = pokemon.name


	if is_instance_valid(hp_bar) and hp_bar.value != pokemon.hp:
		hp_bar.value = move_toward(hp_bar.value, pokemon.hp, 1)
		if hp_bar.value <= floori(pokemon.max_hp * 0.2):
			hp_bar.texture_progress = hp_texture_low
		elif hp_bar.value <= floori(pokemon.max_hp * 0.5):
			hp_bar.texture_progress = hp_texture_medium
		else:
			hp_bar.texture_progress = hp_texture_high
		
		if is_instance_valid(hp_numbers):
			hp_numbers.text = "%s/%s" % [hp_bar.value, hp_bar.max_value]
	

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
	hp_bar.max_value = pokemon.max_hp
	hp_bar.value = pokemon.hp
