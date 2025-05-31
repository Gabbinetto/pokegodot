extends Control


const WORLD_SCENE: PackedScene = preload("res://src/maps/world.tscn")
const FADE_OUT_TIME: float = 3.5

@export var base_sprite: TextureRect
@export var oak_sprite: TextureRect
@export var pokemon_sprite: TextureRect
@export var boy_sprite: TextureRect
@export var girl_sprite: TextureRect
@export var gender_choice: DialogueChoiceSequence
@export var name_confirm: DialogueChoiceSequence
@export_group("Dialogues", "dialogue_")
@export var dialogue_first: DialogueManager
@export var dialogue_second: DialogueManager
@export var dialogue_third: DialogueManager
@export var dialogue_fourth: DialogueManager
@export var dialogue_fifth: DialogueManager
@export var dialogue_sixth: DialogueManager
@export var dialogue_seventh: DialogueManager


func _ready() -> void:
	Globals.in_game = true


	if Flags.f_intro_done:
		_go_to_world(false)
		return

	if TransitionManager.transition:
		await TransitionManager.finished

	_sequence()



func _go_to_world(transition_in: bool = true) -> void:
	Flags.f_intro_done = true

	var world: World = WORLD_SCENE.instantiate()

	if transition_in:
		TransitionManager.play_in(TransitionManager.TransitionTypes.FADE)
		await TransitionManager.finished

	queue_free()

	add_sibling(world)
	get_parent().move_child(world, 0)


	TransitionManager.play_out()
	await TransitionManager.finished


func _sequence() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(base_sprite, "modulate:a", 1, 0.5)
	await tween.finished

	MainDialogue.run_dialogue(dialogue_first)
	await MainDialogue.finished

	tween = create_tween()
	tween.tween_property(oak_sprite, "modulate:a", 0, 0.5)
	tween.tween_property(pokemon_sprite, "modulate:a", 1, 0.5)
	await tween.finished

	MainDialogue.run_dialogue(dialogue_second)
	await MainDialogue.finished

	tween = create_tween()
	tween.tween_property(pokemon_sprite, "modulate:a", 0, 0.5)
	tween.tween_property(oak_sprite, "modulate:a", 1, 0.5)
	await tween.finished

	MainDialogue.run_dialogue(dialogue_third)
	await MainDialogue.finished

	tween = create_tween()
	tween.tween_property(oak_sprite, "modulate:a", 0, 0.5)
	await tween.finished

	MainDialogue.run_dialogue(dialogue_fourth)
	await MainDialogue.finished

	PlayerData.gender = gender_choice.last_choice
	var player_sprite: TextureRect = boy_sprite if PlayerData.gender == PlayerData.MALE else girl_sprite
	tween = create_tween()
	tween.tween_property(player_sprite, "modulate:a", 1, 0.5)
	await tween.finished

	_open_name_input()


func _open_name_input() -> void:
	MainDialogue.run_dialogue(dialogue_fifth)
	await MainDialogue.finished

	var name_input: TextInput = TextInput.create({"length": PlayerData.MAX_PLAYER_NAME, "label": "What is your name?"})
	TransitionManager.play_in(TransitionManager.TransitionTypes.FADE)
	await TransitionManager.finished
	add_child(name_input)
	TransitionManager.play_out()
	await TransitionManager.finished
	name_input.submitted.connect(_name_inputted.bind(name_input), CONNECT_ONE_SHOT)


func _name_inputted(submission: String, name_input: TextInput) -> void:
	if submission.is_empty():
		submission = PlayerData.DEFAULT_MALE_NAME if PlayerData.gender == PlayerData.MALE else PlayerData.DEFAULT_FEMALE_NAME

	TransitionManager.play_in(TransitionManager.TransitionTypes.FADE)
	await TransitionManager.finished
	name_input.queue_free()
	TransitionManager.play_out()
	await TransitionManager.finished

	PlayerData.player_name = submission

	MainDialogue.run_dialogue(dialogue_sixth)
	await MainDialogue.finished

	if name_confirm.last_choice:
		_open_name_input()
	else:
		MainDialogue.run_dialogue(dialogue_seventh)
		await MainDialogue.finished
		_go_to_world()
