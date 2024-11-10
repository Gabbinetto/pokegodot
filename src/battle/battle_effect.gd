class_name BattleEffect extends Resource


const BATTLE_EFFECTS_PATH: String = "res://src/battle/battle_effects/"


func _init(_attributes: Dictionary = {}) -> void:
    pass


static func get_effect(id: String) -> BattleEffect:
    return load(BATTLE_EFFECTS_PATH + id + ".gd")
