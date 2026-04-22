class_name BattleClient extends UIStackElement

signal base_cancel_selected

enum Screens {
	NONE,
	BASE,
	FIGHT,
	TARGET_SELECT,
	DIALOGUE,
}

const DEFAULT_CLIENT_SCENE: PackedScene = preload("res://src/battle/battle_client.tscn")
const BOY_SPRITEFRAMES: SpriteFrames = preload("res://assets/resources/battle_back_sprites/boy.tres")
const GIRL_SPRITEFRAMES: SpriteFrames = preload("res://assets/resources/battle_back_sprites/girl.tres")

@export_group("Setting")
@export var background: TextureRect
@export var player_ground: TextureRect
@export var enemy_ground: TextureRect
@export_group("Sprites")
@export var sprites: Array[PokemonBodySprite] = [null, null, null, null]
@export var ally_trainer_sprites: Array[AnimatedSprite2D] = []
@export var enemy_trainer_sprites: Array[Sprite2D] = []
@export_group("Databoxes", "databox_")
@export var databox_singles_container: Control
@export var databox_doubles_container: Control
@export var databox_ally_single: Databox
@export var databox_enemy_single: Databox
@export var databox_allies_double: Array[Databox]
@export var databox_enemies_double: Array[Databox]
@export_group("Battle screens")
@export var message_background: TextureRect
@export var all_screens: Array[CanvasItem]
@export_subgroup("Base screen")
@export var base_screen: Control
@export var fight_button: BaseButton
@export var pokemon_button: BaseButton
@export var bag_button: BaseButton
@export var run_button: BaseButton
@export var base_cancel_button: BaseButton
@export_subgroup("Fight screen")
@export var fight_screen: Control
@export var move_buttons: Array[MoveButton]
@export var fight_cancel_button: BaseButton
@export var info_box: Control
@export var info_pp: Label
@export var info_type: TextureRect
@export_subgroup("Target selection screen")
@export var target_screen: Control
@export var target_buttons: Array[Button] ## Target buttons when choosing a target in double battles. Should select the allies first, then the foes.
@export var target_cancel_button: BaseButton
@export_subgroup("Dialogues")
@export var selection_dialogue: Dialogue
@export var selection_dialogue_manager: DialogueManager
@export var battle_dialogue: Dialogue
@export var battle_dialogue_manager: DialogueManager

var double_battle: bool = false
var active_databoxes: Array[Databox] = [null, null, null, null]
var last_move_buttons: Dictionary[int, MoveButton]
var last_selected_pokemon: Pokemon
var current_screen: Screens:
	get:
		var node: CanvasItem
		for screen: CanvasItem in all_screens:
			if screen.visible:
				node = screen
		match node:
			base_screen: return Screens.BASE
			fight_screen: return Screens.FIGHT
			target_screen: return Screens.TARGET_SELECT
			battle_dialogue: return Screens.DIALOGUE
			_: return Screens.NONE
var pokemon_states: Array[Dictionary] = [{}, {}, {}, {}]

var _event_queue: Array[Dictionary] = []
var _event_running: bool = false


func _ready() -> void:
	SignalRouter.battle_client_received.connect(_on_battle_data_received)

	base_screen.visibility_changed.connect(_on_base_visible)
	fight_button.pressed.connect(show_screen.bind(Screens.FIGHT))
	pokemon_button.pressed.connect(prompt_selection.bind(true, true))
	run_button.pressed.connect(func(): pass) # TODO: handle run
	base_cancel_button.pressed.connect(base_cancel_selected.emit)

	fight_screen.visibility_changed.connect(_on_fight_visible)
	fight_cancel_button.pressed.connect(_on_fight_cancel)

	target_screen.visibility_changed.connect(_on_target_visible.call_deferred)
	target_cancel_button.pressed.connect(show_screen.bind(Screens.FIGHT))
	for button: BaseButton in target_buttons:
		button.pressed.connect(func(): pass) # TODO: handle target selection

	for button: MoveButton in move_buttons:
		button.focus_entered.connect(_on_move_focus.bind(button))
		button.focus_exited.connect(_on_move_unfocus)
		button.pressed.connect(_on_move_pressed.bind(button))

	_on_base_visible.call_deferred()


func _process(_delta: float) -> void:
	if _event_running || _event_queue.is_empty():
		return
	var event: Dictionary = _event_queue.pop_front()
	_run_event(event)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if current_screen == Screens.BASE and base_cancel_button.visible:
			base_cancel_button.pressed.emit()
		elif current_screen == Screens.FIGHT:
			fight_cancel_button.pressed.emit()


func _on_battle_data_received(data: Dictionary[String, Variant]) -> void:
	match data["type"]:
		"event":
			_event_queue.push_back(data["event"])
		"setup":
			var state: Dictionary[String, Variant] = data["turn_state"]
			pokemon_states.assign(state["pokemons"])
			_sync_sprites()
			# Setup databoxes
			if double_battle:
				active_databoxes.assign(databox_allies_double + databox_enemies_double)
			else:
				active_databoxes[0] = databox_ally_single
				active_databoxes[1] = null
				active_databoxes[2] = databox_enemy_single
				active_databoxes[3] = null
			_sync_databoxes()
		_:
			printerr("Unhandled data type: %s" % [data["type"]])


func _run_event(event: Dictionary) -> void:
	_event_running = true

	match event["type"]:
		"text":
			await show_text(event["text"]).finished
		_:
			printerr("Unhandled event type: %s" % [event["type"]])

	_event_running = false


func _sync_sprites() -> void:
	for i in range(pokemon_states.size()):
		var pokemon: Dictionary[String, Variant]
		pokemon.assign(pokemon_states[i])
		if pokemon:
			sprites[i].id = pokemon["id"]
			sprites[i].form_number = pokemon["form_number"]
			sprites[i].shiny = pokemon["shiny"]
			sprites[i].gender = pokemon["gender"]
			sprites[i].back_sprite = i < int(pokemon_states.size() / 2.0)
		else:
			sprites[i].id = ""

func _sync_databoxes() -> void:
	for i in range(pokemon_states.size()):
		var pokemon: Dictionary[String, Variant]
		pokemon.assign(pokemon_states[i])
		if pokemon and active_databoxes[i]:
			var databox: Databox = active_databoxes[i]
			databox.show()
			databox.pokemon_id = pokemon["id"]
			databox.form_number = pokemon["form_number"]
			databox.pokemon_name = pokemon["name"]
			databox.gender = pokemon["gender"]
			databox.level = pokemon["level"]
			databox.experience = pokemon["experience"]
			databox.hp = pokemon["hp"]
			databox.max_hp = pokemon["max_hp"]
			databox.refresh()

## Grab focus on the fight button when visible
func _on_base_visible() -> void:
	if not base_screen.visible:
		return
	fight_button.grab_focus.call_deferred()


func _on_fight_visible() -> void:
	if not fight_screen.visible:
		return
	var last_move_button: MoveButton = null # TODO: get last move button for current pokemon
	if last_move_button and last_move_button.visible:
		last_move_button.grab_focus.call_deferred()
	else:
		move_buttons.front().grab_focus.call_deferred()

func _on_fight_cancel() -> void:
	show_screen(Screens.BASE)

func _on_move_focus(button: MoveButton) -> void:
	last_move_buttons[0] = button # TODO: handle last move button for current pokemon
	info_box.show()
	info_pp.text = "PP: %d/%d" % [0, 0] # TODO: handle pps
	info_type.texture = Types.ICONS[button.move.type]


func _on_move_unfocus() -> void:
	if get_viewport().gui_get_focus_owner() in move_buttons:
		return
	info_box.hide()


# TODO: handle move selection
func _on_move_pressed(button: MoveButton) -> void:
	pass


func _on_target_visible() -> void:
	if not target_screen.visible:
		return

	var selection_order: Array[BaseButton]
	@warning_ignore("integer_division")
	selection_order.assign(
		target_buttons.slice(target_buttons.size() / 2) + target_buttons.slice(0, target_buttons.size() / 2)
	)

	for button: Button in selection_order:
		if not button.disabled:
			button.grab_focus.call_deferred()
			break


func show_text(text: String) -> Dialogue:
	battle_dialogue_manager.starting_sequence.text = text
	battle_dialogue.run_dialogue(battle_dialogue_manager)
	return battle_dialogue


func show_selection_text(text: String) -> Dialogue:
	selection_dialogue_manager.starting_sequence.text = text
	selection_dialogue.run_dialogue(selection_dialogue_manager)
	return selection_dialogue


func prompt_selection(can_cancel: bool = true, switch_out: bool = false) -> void:
	var options: Dictionary[String, Variant] = {"team": PlayerData.team, "in_battle": true, "can_cancel": can_cancel}
	if switch_out:
		options["select_text"] = "Switch in"
	var party: PartyMenu = PartyMenu.build(options)
	party.data_sent.connect(func(data: Variant): pass) # TODO: handle data sent
	TransitionManager.play_in(TransitionManager.TransitionTypes.FADE)
	await TransitionManager.finished
	UIStack.push(party)
	party.closed.connect(pokemon_button.grab_focus.call_deferred, CONNECT_ONE_SHOT)
	TransitionManager.play_out()
	await TransitionManager.finished


## Shows [param screen] while hiding all other commands.
func show_screen(screen: Screens) -> void:
	var node: CanvasItem
	match screen:
		Screens.BASE:
			node = base_screen
			fight_button.grab_focus.call_deferred()
		Screens.FIGHT:
			node = fight_screen
		Screens.TARGET_SELECT:
			node = target_screen
		Screens.DIALOGUE:
			node = battle_dialogue

	for child: CanvasItem in all_screens:
		if child == node:
			child.show()
		else:
			child.hide()


func close() -> void:
	TransitionManager.play_in(TransitionManager.TransitionTypes.FADE)
	await TransitionManager.finished
	UIStack.pop()
	TransitionManager.play_out()
	await TransitionManager.finished

	if Globals.game_world.process_mode == Globals.game_world.PROCESS_MODE_DISABLED:
		Globals.game_world.process_mode = Globals.game_world.PROCESS_MODE_INHERIT



static func build(options: Dictionary[String, Variant] = {}) -> UIStackElement:
	var battle_client: BattleClient = DEFAULT_CLIENT_SCENE.instantiate()

	# Battle settings
	battle_client.double_battle = options.get("double_battle", false)

	# Set battle graphics
	# If no battleback is provided, fetch the first one available
	var battleback: Battlebacks.Set = Battlebacks.loaded_sets.get(options.get("battleback", Battlebacks.Sets.values()[0]))
	battle_client.background.texture = battleback.background
	battle_client.player_ground.texture = battleback.player_base
	battle_client.enemy_ground.texture = battleback.enemy_base

	return battle_client
