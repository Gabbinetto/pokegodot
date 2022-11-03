extends DialogueEvent
class_name DialogueTextEvent

@export_multiline var text : = ''
@export var needs_input : = true ## Does this event need the player to press something to advance?
@export var delay_if_no_input : = 4.0

var tween : Tween

func run(dialogue : Dialogue):
	dialogue.window.visible = true
	dialogue.label.text = text
	dialogue.label.visible_ratio = 0.0
	
	tween = dialogue.create_tween()
	tween.tween_property(dialogue.label, 'visible_ratio', 1.0, text.length() * GameVariables.text_speed)
	
	await tween.finished
	dialogue.arrow.visible = true
	

func input(event : InputEvent, dialogue : Dialogue):
	if event.is_action_pressed('A') or event.is_action_pressed('B'):
		if dialogue.label.visible_ratio < 1.0:
			skip(dialogue)
		else:
			emit_signal('event_finished')
			dialogue.arrow.visible = false

func skip(dialogue : Dialogue):
	dialogue.label.visible_ratio = 1.0
	if tween.is_running():
		tween.custom_step(INF)

func is_type(type : String): return type == 'DialogueTextEvent' or super(type)
