extends Control

signal value_changed

const DEFAULT_GRAY_LABEL: LabelSettings = preload("res://assets/resources/ui/text_resources/default_gray.tres")
const BROWN_LABEL: LabelSettings = preload("res://assets/resources/ui/text_resources/brown.tres")

@export var text: String
@export_multiline var description: String
@export_group("Nodes")
@export var arrow: TextureRect
@export var label: Label

var arrow_texture: Texture2D

func _ready() -> void:
	if label:
		label.text = text
	if arrow:
		arrow.custom_minimum_size = arrow.size
		arrow_texture = arrow.texture
	focus_entered.connect(_on_focus.bind(true))
	focus_exited.connect(_on_focus.bind(false))
	
	_on_focus(has_focus())


func _on_focus(focused: bool) -> void:
	arrow.texture = arrow_texture if focused else null
	label.label_settings = BROWN_LABEL if focused else DEFAULT_GRAY_LABEL


func get_value() -> Variant:
	return


func set_value(_value: Variant) -> void:
	pass
