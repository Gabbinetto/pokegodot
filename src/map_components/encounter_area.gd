class_name EncounterArea extends Area2D


@export var encounters: Array[MapEncounter]
@export_range(0.0, 1.0, 0.01) var encounter_chance: float = 0.2


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _pick_random() -> MapEncounter:
	return encounters[
		Globals.rng.rand_weighted(
			encounters.map(func(encounter: MapEncounter): return encounter.chance)
		)
	]


func _on_area_entered(area: Area2D) -> void:
	if area != Globals.player.area or encounters.is_empty():
		return
	
	if Globals.player.is_moving:
		await Globals.player.stopped_moving
	
	if Globals.rng.randf() <= encounter_chance:
		var encounter: MapEncounter = _pick_random()
		var level: int = Globals.rng.randi_range(encounter.min_level, encounter.max_level)
		var pokemon: Pokemon = Pokemon.generate(encounter.id, encounter.form, {"level": level})
		Battle.start_battle(
			{"enemy_trainers": Battle.TrainerBattleInfo.make_wild(pokemon)}
		)
