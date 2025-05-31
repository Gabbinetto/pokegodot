extends Node

## Pokegodot's Flags singleton
##
## Singleton that stores all the flags of the game as it's properties.[br]
## For a flag to be stored in the save file, it's name has to start with [constant PREFIX],
## which by default is [code]f_[/code].[br]
## Flags don't necessarily have to be boolean values, despite the name. They can be numbers,
## strings or any other serializable value. [br]
## [b]Non-serializable values need to be handled
## by the match statements in [method as_save_data] and [method from_save_data][/b].

const PREFIX: String = "f_"


var f_intro_done: bool = false
var f_badges: Array[bool] = [
	false, false, false, false,
	false, false, false, false,
]


func as_save_data() -> Dictionary[String, Variant]:
	var output: Dictionary[String, Variant] = {}
	for property: Dictionary[String, Variant] in get_property_list():
		if not property.name.begins_with(PREFIX):
			continue
		match property.name:
			_:
				output.set(property.name, get(property.name))

	print(output)

	return output


func from_save_data(data: Dictionary[String, Variant]) -> void:
	for key: String in data:
		if not key.begins_with(PREFIX):
			continue

		match key:
			_:
				set(key, data[key])
