class_name DebugBattleMenu extends Control

signal closed

const MENU_SCENE: PackedScene = preload("res://src/ui/debug/debug_battle_menu.tscn")

@export var back_button: BaseButton
@export_group("Wild battle UI", "wild_battle_")
@export var wild_battle_button: BaseButton
@export var wild_battle_prompt: Control
@export var wild_battle_input: LineEdit
@export var wild_battle_ok: BaseButton
@export var wild_battle_cancel: BaseButton


func _ready() -> void:
	back_button.pressed.connect(closed.emit)
	wild_battle_button.pressed.connect(_wild_battle_open)


func _wild_battle_open() -> void:
	wild_battle_prompt.show()
	wild_battle_input.grab_focus.call_deferred()
	wild_battle_cancel.pressed.connect((
		func():
			wild_battle_button.grab_focus.call_deferred()
			wild_battle_input.text = ""
			wild_battle_prompt.hide()
	), CONNECT_ONE_SHOT)
	var on_ok: Callable = func(self_call: Callable):
		var text: String = wild_battle_input.text
		if text.count("_") != 2:
			return
		var id: String = text.get_slice("_", 0)
		if not (text.get_slice("_", 1).is_valid_int() and text.get_slice("_", 2).is_valid_int()):
			return
		var form: int = int(text.get_slice("_", 1))
		var level: int = int(text.get_slice("_", 2))
		
		if not DB.pokemon.has(id):
			print("Doesn't have ", id)
			return
		if form > DB.pokemon[id]["forms"].size() - 1:
			print("Doesn't have form ", form)
			return
		 
		wild_battle_ok.pressed.disconnect(self_call)
		Battle.start_battle(
			{"enemy_trainers": BattleTrainer.make_wild(
				Pokemon.generate(id, form, {"level": level})
			)}
		)
		wild_battle_cancel.pressed.emit()
	
	wild_battle_ok.pressed.connect(on_ok.bind(on_ok))
	

static func create() -> DebugBattleMenu:
	return MENU_SCENE.instantiate()
