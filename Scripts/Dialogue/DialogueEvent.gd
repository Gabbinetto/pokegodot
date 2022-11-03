extends Resource
class_name DialogueEvent

signal event_finished

func run(_dialogue : Dialogue):
	pass

func is_type(type : String): return type == 'DialogueEvent'

func input(_event : InputEvent, _dialogue : Dialogue):
	pass
