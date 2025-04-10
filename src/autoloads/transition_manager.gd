extends CanvasLayer

signal finished

enum TransitionTypes {
	FADE,
	WILD_BATTLE
}

const PATHS: Dictionary[TransitionTypes, String] = {
	TransitionTypes.FADE: "res://src/transitions/fade.tscn",
	TransitionTypes.WILD_BATTLE: "res://src/transitions/wild_battle.tscn",
}

var transition: Transition


func play_in(type: TransitionTypes, params: Dictionary[String, Variant] = {}) -> void:
	if transition:
		push_error("Wait for a transition to finish before starting a new one.")
		return
	set_meta("last_input_enabled", Globals.player.input_enabled)
	set_meta("last_event_input_enabled", Globals.event_input_enabled)
	Globals.player.input_enabled = false
	Globals.player.input_direction = Vector2.ZERO
	Globals.event_input_enabled = false
	var path: String = PATHS.get(type, "")
	if not path:
		push_error("Transition type %s doesn't exist." % type)
		return
	transition = load(path).instantiate()
	transition.params = params
	transition.finished.connect(finished.emit, CONNECT_ONE_SHOT)
	add_child(transition)
	transition.grab_focus()
	transition.play_in()


func play_out() -> void:
	if not transition:
		push_error("To play out, a transition has to play in first.")
		return
	transition.play_out()
	
	await transition.finished

	if is_instance_valid(transition):
		transition.queue_free()
	transition = null

	Globals.player.input_enabled = get_meta("last_input_enabled", true)
	Globals.event_input_enabled = get_meta("last_event_input_enabled", true)

	remove_meta("last_input_enabled")
	remove_meta("last_input_enabled")

	finished.emit()
