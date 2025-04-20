class_name BattleEffect extends Resource

## An in-battle effect.
##
## An effect that occurs in battle, being that of a move, item or ability.

const BATTLE_EFFECTS_PATH: String = "res://src/battle/battle_effects/"

var owner: Variant
var chance: float = 100.0
var attributes: Dictionary[String, Variant] = {}


func _init(_owner: Variant, _chance: float = 100.0, _attributes: Dictionary[String, Variant] = {}) -> void:
	owner = _owner
	chance = _chance
	attributes = _attributes


func apply(battle: Battle, step: Battle.BattleSteps, data: Dictionary[String, Variant]) -> void:
	if Globals.rng.randf_range(0.0, 100.0) <= chance:
		_effect(battle, step, data)


func _effect(_battle: Battle, _step: Battle.BattleSteps, _data: Dictionary[String, Variant]) -> void:
	pass


func enable() -> void:
	SignalRouter.battle_step.connect(apply)


func disable() -> void:
	SignalRouter.battle_step.disconnect(apply)


static func get_effect(id: String) -> GDScript:
	if id.get_extension() != "gd":
		id += ".gd"
	return load(BATTLE_EFFECTS_PATH + id)
