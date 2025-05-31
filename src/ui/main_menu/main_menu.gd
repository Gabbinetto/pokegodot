extends Control


const INTRO_SCENE: PackedScene = preload("res://src/ui/intro.tscn")
const WORLD_SCENE: PackedScene = preload("res://src/maps/world.tscn")


@export var new_game_dialogue: DialogueManager
@export var new_game_choice: DialogueChoiceSequence
@export_group("Buttons", "button_")
@export var button_continue: BaseButton
@export var button_new: BaseButton
@export var button_settings: BaseButton
@export var button_quit: BaseButton


func _ready() -> void:
	if not PlayerData.exists_data():
		button_continue.hide()

	button_continue.pressed.connect(_go_to_game)
	button_new.pressed.connect(_new_game_pressed)
	button_settings.pressed.connect(_open_settings)

	if button_continue.visible:
		button_continue.grab_focus.call_deferred()
	else:
		button_new.grab_focus.call_deferred()


func _open_settings() -> void:
	TransitionManager.play_in(TransitionManager.TransitionTypes.FADE)
	await TransitionManager.finished

	var settings: SettingsMenu = SettingsMenu.create()
	add_child(settings)

	TransitionManager.play_out()
	await TransitionManager.finished

	settings.closed.connect(
		func():
			TransitionManager.play_in(TransitionManager.TransitionTypes.FADE)
			await TransitionManager.finished

			settings.queue_free()

			TransitionManager.play_out()
			await TransitionManager.finished
	)


func _new_game_pressed() -> void:
	if PlayerData.exists_data():
		MainDialogue.run_dialogue(new_game_dialogue)
		var next: Callable = func(index: int):
			if index == 0:
				_go_to_intro()
		new_game_choice.choice_taken.connect(next, CONNECT_ONE_SHOT)
		return
	_go_to_intro()



func _go_to_game() -> void:
	PlayerData.load_data()
	var world: World = WORLD_SCENE.instantiate()

	TransitionManager.play_in(TransitionManager.TransitionTypes.FADE)
	await TransitionManager.finished

	add_sibling(world)
	get_parent().move_child(world, 0)

	await get_tree().create_timer(1.0).timeout

	queue_free()

	TransitionManager.play_out()
	await TransitionManager.finished

	Globals.in_game = true


func _go_to_intro() -> void:
	var intro: Control = INTRO_SCENE.instantiate()
	var params: Dictionary[String, Variant] = {}
	params["out_time"] = intro.get("FADE_OUT_TIME")

	TransitionManager.play_in(TransitionManager.TransitionTypes.FADE, params)
	await TransitionManager.finished

	add_sibling(intro)
	get_parent().move_child(intro, 0)

	await get_tree().create_timer(1.0).timeout

	queue_free()

	TransitionManager.play_out()
