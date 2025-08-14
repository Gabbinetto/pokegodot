class_name BattleUI extends Node

signal move_selected(move: PokemonMove)
signal pokemon_selected
signal run_selected


enum Screens {
	NONE,
	BASE,
	FIGHT,
	TARGET_SELECT,
	DIALOGUE,
}


@export var battle: Battle
@export var message_background: TextureRect
@export var all_screens: Array[CanvasItem]
@export var databox_ally_single: Databox
@export var databox_enemy_single: Databox
@export_group("Base screen")
@export var base_screen: Control
@export var fight_button: BaseButton
@export var pokemon_button: BaseButton
@export var bag_button: BaseButton
@export var run_button: BaseButton
@export_group("Fight screen")
@export var fight_screen: Control
@export var move_buttons: Array[MoveButton]
@export var fight_cancel_button: BaseButton
@export var info_box: Control
@export var info_pp: Label
@export var info_type: TextureRect
@export_group("Target selection screen")
@export var target_screen: Control
@export var target_buttons: Array[Button] ## Target buttons when choosing a target in double battles. Should select the allies first, then the foes.
@export var target_cancel_button: BaseButton
@export_group("Dialogues")
@export var selection_dialogue: Dialogue
@export var selection_dialogue_manager: DialogueManager
@export var battle_dialogue: Dialogue
@export var battle_dialogue_manager: DialogueManager

var used_databoxes: Array[Databox] = [null, null, null, null]
var last_move_button: MoveButton
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

func _ready() -> void:
	
	base_screen.visibility_changed.connect(_on_base_visible)
	fight_button.pressed.connect(show_screen.bind(Screens.FIGHT))
	pokemon_button.pressed.connect(prompt_switch)
	run_button.pressed.connect(run_selected.emit)
	
	fight_screen.visibility_changed.connect(_on_fight_visible)
	fight_cancel_button.pressed.connect(_on_fight_cancel)
	
	target_screen.visibility_changed.connect(_on_target_visible)
	target_cancel_button.pressed.connect(show_screen.bind(Screens.FIGHT))
	
	for button: MoveButton in move_buttons:
		button.focus_entered.connect(_on_move_focus.bind(button))
		button.focus_exited.connect(_on_move_unfocus)
		button.pressed.connect(_on_move_pressed.bind(button))

	_on_base_visible.call_deferred()


## Shows [param screen] while hiding all other commands.
func show_screen(screen: Screens) -> void:
	var node: CanvasItem
	match screen:
		Screens.BASE:
			node = base_screen
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


## Shows the current pokemon's moves in the move buttons.
func refresh_move_buttons() -> void:
	for i: int in 4:
		if i + 1 > battle.current_pokemon.pokemon.moves.size():
			move_buttons[i].hide()
		else:
			move_buttons[i].show()
			move_buttons[i].move = battle.current_pokemon.pokemon.moves[i]


## Assigns the current pokemon to the databoxes and hides them if needed.
func refresh_databoxes() -> void:
	if battle.double_battle:
		pass
	else:
		used_databoxes.fill(null)
		used_databoxes[0] = databox_ally_single
		used_databoxes[2] = databox_enemy_single
		
		databox_ally_single.show()
		databox_ally_single.enabled = true
		databox_ally_single.pokemon = battle.ally_pokemon.front().pokemon

		databox_enemy_single.show()
		databox_enemy_single.enabled = true
		databox_enemy_single.pokemon = battle.enemy_pokemon.front().pokemon


## Update the target buttons with the current pokemon on the field.
func refresh_target_buttons() -> void:
	for i: int in battle.pokemons.size():
		target_buttons[i].text = battle.pokemons[i].name if battle.pokemons[i] else ""


func prompt_switch(can_cancel: bool = true) -> void:
	var party: PartyMenu = PartyMenu.create(PlayerData.team, {"in_battle": true, "can_cancel": can_cancel})
	party.pokemon_selected.connect(_on_pokemon_selected.bind(party))
	party.closed.connect(_on_party_closed.bind(party))
	TransitionManager.play_in(TransitionManager.TransitionTypes.FADE)
	await TransitionManager.finished
	add_child(party)


func _on_pokemon_selected(pokemon: Pokemon, party: PartyMenu) -> void:
	if pokemon.hp <= 0:
		return
	await _on_party_closed(party)
	last_selected_pokemon = pokemon
	pokemon_selected.emit(pokemon)


func _on_party_closed(party: PartyMenu) -> void:
	TransitionManager.play_in(TransitionManager.TransitionTypes.FADE)
	await TransitionManager.finished
	party.queue_free()
	await party.tree_exited
	TransitionManager.play_out()
	await TransitionManager.finished
	if base_screen.visible:
		pokemon_button.grab_focus.call_deferred()


## Grab focus on the fight button when visible
func _on_base_visible() -> void:
	if not base_screen.visible:
		return
	fight_button.grab_focus.call_deferred()


func _on_move_focus(button: MoveButton) -> void:
	last_move_button = button
	info_box.show()
	info_pp.text = "PP: %d/%d" % [button.move.pp, button.move.total_pp]
	info_type.texture = Types.ICONS[button.move.type]


func _on_move_unfocus() -> void:
	if get_viewport().gui_get_focus_owner() in move_buttons:
		return
	info_box.hide()


func _on_move_pressed(button: MoveButton) -> void:
	move_selected.emit(button.move)


func _on_fight_visible() -> void:
	if not fight_screen.visible:
		return
	if last_move_button and last_move_button.visible:
		last_move_button.grab_focus.call_deferred()
	else:
		move_buttons.front().grab_focus.call_deferred()


func _on_fight_cancel() -> void:
	if battle.current_pokemon_index > 0:
		battle.current_pokemon_index -= 1
		return
	show_screen(Screens.BASE)


func _on_target_visible() -> void:
	if not target_screen.visible:
		return
	for button: Button in target_buttons:
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





func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if current_screen == Screens.FIGHT:
			fight_cancel_button.pressed.emit()
