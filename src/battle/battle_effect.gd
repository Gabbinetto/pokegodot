class_name BattleEffect extends Resource

## An in-battle effect.
##
## An effect that occurs in battle, being that of a move, item or ability.

const BATTLE_EFFECTS_PATH: String = "res://src/battle/battle_effects/"


func _init(_attributes: Dictionary[String, Variant] = {}) -> void:
	SignalRouter.battle_step.connect(apply)


func apply(_battle: Battle, _step: Battle.BattleSteps, _data: Dictionary[String, Variant]) -> void:
	print_debug(_step)
	match _step:
		Battle.BattleSteps.AFTER_DAMAGE_CALC:
			print_debug(_data.damage.random)


static func get_effect(id: String) -> GDScript:
	if FileAccess.file_exists(BATTLE_EFFECTS_PATH + id + ".gd"):
		return load(BATTLE_EFFECTS_PATH + id + ".gd")
	else:
		return
