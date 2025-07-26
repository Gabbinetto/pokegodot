class_name EncounterPool extends Resource


@export var _list: Array[MapEncounter] = [null]
var _iterator: int = 0


func _init(iter: Array[MapEncounter] = []) -> void:
	_list.assign(iter)


func _iter_init(_iter: Array) -> bool:
	_iterator = 0
	return _iterator < _list.size()


func _iter_next(_iter: Array) -> bool:
	_iterator += 1
	return _iterator < _list.size()


func _iter_get(_iter: Variant) -> Variant:
	return _list[_iterator]


func array() -> Array[MapEncounter]:
	return _list


func at(index: int) -> MapEncounter:
	return _list[index]


func set_at(index: int, value: MapEncounter) -> void:
	_list[index] = value


func pick_random() -> MapEncounter:
	return _list[
		Globals.rng.rand_weighted(
			_list.map(func(encounter: MapEncounter): return encounter.chance)
		)
	]
