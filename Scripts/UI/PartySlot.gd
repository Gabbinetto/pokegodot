extends Sprite2D

signal focus_changed

const pokeball_texture: = preload("res://Graphics/Pictures/Party/icon_ball.png")
const pokeball_selected_texture: = preload("res://Graphics/Pictures/Party/icon_ball_sel.png")

@export var pokemon: Pokemon
@export var is_round: = false
@export_group("HP bar")
@export var hp_bar_full_width: = 96
@export var hp_bar_height: = 8

@export_category("Textures")
@export_file("*.png") var blank: String = "res://Graphics/Pictures/Party/panel_blank.png"
@export_group("Normal")
@export_file("*.png") var normal_default: String = "res://Graphics/Pictures/Party/panel_rect.png"
@export_file("*.png") var normal_default_selected: String = "res://Graphics/Pictures/Party/panel_rect_sel.png"
@export_file("*.png") var normal_faint: String = "res://Graphics/Pictures/Party/panel_rect_faint.png"
@export_file("*.png") var normal_faint_selected: String = "res://Graphics/Pictures/Party/panel_rect_faint_sel.png"
@export_file("*.png") var normal_swap: String = "res://Graphics/Pictures/Party/panel_rect_swap.png"
@export_file("*.png") var normal_swap_selected: String = "res://Graphics/Pictures/Party/panel_rect_swap_sel.png"
@export_group("Round")
@export_file("*.png") var round_default: String = "res://Graphics/Pictures/Party/panel_round.png"
@export_file("*.png") var round_default_selected: String = "res://Graphics/Pictures/Party/panel_round_sel.png"
@export_file("*.png") var round_faint: String = "res://Graphics/Pictures/Party/panel_round_faint.png"
@export_file("*.png") var round_faint_selected: String = "res://Graphics/Pictures/Party/panel_round_faint_sel.png"
@export_file("*.png") var round_swap: String = "res://Graphics/Pictures/Party/panel_round_swap.png"
@export_file("*.png") var round_swap_selected: String = "res://Graphics/Pictures/Party/panel_round_swap_sel.png"

@onready var name_label: Label = $NameLabel
@onready var icon_ball: Sprite2D = $IconBall
@onready var icon: Sprite2D = $Icon
@onready var hp_bar_back: Sprite2D = $HpBarBack
@onready var hp_label: Label = $HpBarBack/HpLabel
@onready var hp_bar: Sprite2D = $HpBarBack/HpBar
@onready var level: Sprite2D = $Level
@onready var level_label: Label = $Level/LevelLabel
@onready var gender_symbol: Sprite2D = $GenderSymbol

var focused: = false

func _process(delta: float) -> void:
	if pokemon == null:
		texture = load(blank)
		for child in get_children():
			child.hide()
		return
	
	# HP Bar
	hp_bar.scale.x = ceili(remap(pokemon.hp, 0, pokemon.stats.HP, 0, 96))

	if pokemon.hp <= pokemon.stats.HP * 0.2:
		hp_bar.region_rect.position.y = hp_bar_height * 2
	elif pokemon.hp <= pokemon.stats.HP * 0.5:
		hp_bar.region_rect.position.y = hp_bar_height * 1
	else:
		hp_bar.region_rect.position.y = hp_bar_height * 0
	
	icon.texture = pokemon.species.icon
	level_label.text = str(pokemon.level)
	hp_label.text = "%s/%s" % [pokemon.hp, pokemon.stats.HP]
	name_label.text = pokemon.nickname
	if pokemon.gender == pokemon.GENDERLESS:
		gender_symbol.hide()
	else:
		gender_symbol.frame = pokemon.gender
		gender_symbol.show()
	
	# Changing textures
	texture = _get_texture()
	icon_ball.texture = pokeball_selected_texture if focused else pokeball_texture
	var frame_interval: = 10 if focused else 20
	if Engine.get_frames_drawn() % frame_interval == 0:
		icon.frame = 0 if icon.frame == 1 else 1

func grab_focus():
	focused = true
	focus_changed.emit()

func _get_texture():
	var prefix: String = "round_" if is_round else "normal_"
	var suffix: String = "_selected" if focused else ""
	var middle: String = "default" if pokemon.hp > 0 else "faint"
	return load(get(prefix + middle + suffix))
