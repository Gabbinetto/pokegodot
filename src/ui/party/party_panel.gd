class_name PartyPanel extends TextureButton

const ICON_MALE: Texture2D = preload("res://assets/graphics/ui/gender_male_icon.png")
const ICON_FEMALE: Texture2D = preload("res://assets/graphics/ui/gender_female_icon.png")
const POKEBALL_ICON: Texture2D = preload("res://assets/graphics/ui/party/icon_ball.png")
const POKEBALL_ICON_SELECTED: Texture2D = preload("res://assets/graphics/ui/party/icon_ball_sel.png")
const HP_BAR_NORMAL = preload("res://assets/graphics/ui/party/overlay_hp_back.png")
const HP_BAR_FAINT = preload("res://assets/graphics/ui/party/overlay_hp_back_faint.png")
const HP_BAR_SWAP = preload("res://assets/graphics/ui/party/overlay_hp_back_swap.png")
const SPRITE_ICON_UPDATE_FRAMES: int = 20

@export var pokemon_name: Label
@export var level: Label
@export var hp_bar: HPBar
@export var health_text: Label
@export var gender_icon: TextureRect
@export var pokemon_icon: Sprite2D
@export var pokeball_icon: TextureRect
@export var item_icon: TextureRect
@export_group("Textures", "texture_")
@export var texture_default: Texture2D
@export var texture_default_selected: Texture2D
@export var texture_fainted: Texture2D
@export var texture_fainted_selected: Texture2D
@export var texture_swap_from: Texture2D
@export var texture_swap_to: Texture2D
@export var texture_swap_both: Texture2D


var pokemon: Pokemon:
	set(value):
		pokemon = value
		if pokemon:
			pokemon.hp_changed.connect(func(_old: int): _sync_hp())
			refresh()

var swapping_from: bool = false
var swapping_to: bool = false


func _ready() -> void:
	refresh()
	
	pokemon = pokemon
	
	focus_entered.connect(refresh.call_deferred)
	focus_exited.connect(refresh.call_deferred)
	pressed.connect(refresh.call_deferred)


func _process(_delta: float) -> void:
	if Engine.get_process_frames() % SPRITE_ICON_UPDATE_FRAMES == 0 and pokemon_icon:
		pokemon_icon.frame = 0 if bool(pokemon_icon.frame) else 1


func refresh() -> void:
	if not pokemon:
		focus_mode = Control.FOCUS_NONE
		disabled = true
		for child: CanvasItem in get_children():
			child.hide()
		return
	focus_mode = Control.FOCUS_ALL
	disabled = false
	for child: CanvasItem in get_children():
		child.show()

	pokemon_name.text = pokemon.name
	level.text = str(pokemon.level)
	_sync_hp()
	if pokemon.gender == Pokemon.Genders.GENDERLESS:
		gender_icon.hide()
	else:
		gender_icon.show()
		gender_icon.texture = ICON_MALE if pokemon.gender == Pokemon.Genders.MALE else ICON_FEMALE
	pokemon_icon.texture = pokemon.sprite_icon
	item_icon.visible = pokemon.held_item != null # TODO: Comeback when mail
	pokeball_icon.texture = POKEBALL_ICON_SELECTED if has_focus() else POKEBALL_ICON
	
	
	if pokemon.hp > 0:
		texture_normal = texture_default
		texture_pressed = texture_default_selected
		hp_bar.texture_under = HP_BAR_NORMAL
	else:
		texture_normal = texture_fainted
		texture_pressed = texture_fainted_selected
		hp_bar.texture_under = HP_BAR_FAINT
	
	if swapping_from and swapping_to:
		texture_normal = texture_swap_both
	elif swapping_from:
		texture_normal = texture_swap_from
	elif swapping_to:
		texture_normal = texture_swap_to
	if swapping_from or swapping_to:
		texture_pressed = texture_normal
		hp_bar.texture_under = HP_BAR_SWAP
		

	texture_hover = texture_normal
	texture_focused = texture_pressed


func _sync_hp() -> void:
	hp_bar.max_value = pokemon.max_hp
	hp_bar.value = pokemon.hp
	health_text.text = "%d/%d" % [hp_bar.value, hp_bar.max_value]
