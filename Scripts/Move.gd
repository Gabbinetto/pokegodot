class_name Move extends Resource

enum Categories {Physical, Special, Status}

# Move data
var id: String = ""
var name: String = "Unnamed"
var type: String = "NONE"
var category: Categories = Categories.Status
var power: int = 0
var accuracy: int = 100
var base_pp: = 5
var target: String = "None"
var priority: int = 0
var function_code: String = "None"
var flags: PackedStringArray = []
var effect_chance: int = 0
var description: String = "???"

# Move instance data
var pp_ups: int = 0:
	set(value):
		pp_ups = clampi(value, 0, 3)

func _init(id: String) -> void:
	self.id = id
	var data: Dictionary = Global.moves.get(self.id)
	name = data.get("Name", name)
	type = data.get("Type", type)
	category = Categories[data.get("Category", category)]
	power = data.get("Power", power)
	accuracy = data.get("Accuracy", accuracy)
	base_pp = data.get("TotalPP", base_pp)
	target = data.get("Target", target)
	priority = data.get("Priority", priority)
	function_code = data.get("FunctionCode", function_code)
	flags = data.get("Flags", "").split(",")
	effect_chance = data.get("EffectChance", effect_chance)
	description = data.get("Description", description)
