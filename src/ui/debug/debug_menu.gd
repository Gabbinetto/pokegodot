class_name DebugMenu extends Control

signal closed

const MENU_SCENE: PackedScene = preload("res://src/ui/debug/debug_menu.tscn")

@export var main: Control
@export var buttons_edit: Array[TextureButton] = [null, null, null, null, null, null]


func _ready() -> void:
	_sync_edit_buttons()
	for i: int in buttons_edit.size():
		buttons_edit[i].pressed.connect(_open_pokemon_editor.bind(i))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		closed.emit()


func _sync_edit_buttons() -> void:
	for i: int in buttons_edit.size():
		var button: TextureButton = buttons_edit[i]
		if PlayerData.team.size() > i:
			button.show()
			if not (button.texture_normal is AtlasTexture):
				button.texture_normal = AtlasTexture.new()
				button.texture_normal.atlas = PlayerData.team.slot(i).sprite_icon
				button.texture_normal.region = Rect2(
					Vector2.ZERO, 
					Vector2(button.texture_normal.atlas.get_width() / 2, 0)
				)
			else:
				button.texture_normal.atlas = PlayerData.team.slot(i).sprite_icon
			
			button.texture_hover = button.texture_normal
			button.texture_pressed = button.texture_normal
		else:
			button.hide()


func _open_pokemon_editor(slot: int) -> void:
	var editor: PokemonEditor = PokemonEditor.create()
	main.hide()
	add_child(editor)
	editor.pokemon = PlayerData.team.slot(slot)
	editor.closed.connect(
		func():
			editor.queue_free()
			_sync_edit_buttons()
			main.show()
			buttons_edit[slot].grab_focus.call_deferred()
	)
	


static func create() -> DebugMenu:
	var menu: DebugMenu = MENU_SCENE.instantiate()
	return menu
