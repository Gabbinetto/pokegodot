extends Node

## Bag autoload
##
## Singleton representing the bag. Has functionality to add, remove and set
## the number of items in the bag. [Item]s are stored by their [b]id[/b], they
## aren't stored as resources.


enum Pockets {
	ITEMS,
	MEDICINE,
	POKEBALLS,
	MACHINES,
	BERRIES,
	MAIL,
	BATTLE_ITEMS,
	KEY_ITEMS,
}

const MAX_ITEM_AMOUNT: int = 999
const POCKET_NAMES: Dictionary[Pockets, String] = {
	Pockets.ITEMS: "Items",
	Pockets.MEDICINE: "Medicine",
	Pockets.POKEBALLS: "Poke Balls",
	Pockets.MACHINES: "TMs & HMs",
	Pockets.BERRIES: "Berries",
	Pockets.MAIL: "Mail",
	Pockets.BATTLE_ITEMS: "Battle Items",
	Pockets.KEY_ITEMS: "Key Items",
}

var _items: Dictionary[String, int] = {}


func _iter_get(iter: Variant) -> Variant:
	return iter


func _iter_init(iter: Array) -> bool:
	iter[0] = _items.keys()[0]
	return _items.keys().find(iter[0]) < _items.size()


func _iter_next(iter: Array) -> bool:
	var index: int = _items.keys().find(iter[0]) + 1
	if index >= _items.size():
		return false
	iter[0] = _items.keys()[index]
	return true


func get_amount(id: String) -> int:
	return _items.get(id, 0)


func has_item(id: String) -> bool:
	return get_amount(id) > 0


func add_item(id: String, amount: int = 1) -> void:
	_items[id] = min(_items.get(id, 0) + amount, MAX_ITEM_AMOUNT)


func set_item(id: String, amount: int) -> void:
	if amount == 0:
		_items.erase(id)
		return
	_items[id] = clampi(0, amount, 999)


func remove_item(id: String, amount: int = 1) -> void:
	if not _items.has(id):
		return
	
	_items[id] = max(0, _items[id] - amount)
	if _items[id] <= 0:
		_items.erase(id)


func get_pocket(pocket: Pockets) -> Array[String]:
	var out: Array[String]
	out.assign(_items.keys().filter(func(item: String):
		return Item.get_item(item).pocket == pocket
	))
	return out
