class_name EncounterArea extends Area2D


@export var elevation: int = 0
@export var pool: EncounterPool
@export_range(0.0, 1.0, 0.01) var encounter_chance: float = 0.2
@export var battleback: Battlebacks.Sets


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if area != Globals.player.area or not pool:
		return

	if Globals.player.is_moving:
		await Globals.player.stopped_moving

	if Globals.rng.randf() <= encounter_chance:
		var encounter: MapEncounter = pool.pick_random()
		var level: int = Globals.rng.randi_range(encounter.min_level, encounter.max_level)
		var pokemon: Pokemon = Pokemon.generate(encounter.id, encounter.form, {"level": level})
		Battle.start_battle(
			{
				"enemy_trainers": BattleTrainer.make_wild(pokemon),
				"battleback": battleback
			}
		)
