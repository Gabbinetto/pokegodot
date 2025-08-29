@tool
class_name Item extends Resource

## Pokegodot's Item class.
##
## This resource represents in-game items. They are identified by their location in the
## items [constant RESOURCES_PATH] and by their [member Resource.resource_name], which acts as an ID. [br]
## To define a new item, create a resource in [constant RESOURCE_PATH]. For new, custom functionality, create a script inheriting this class first.[br][br]
## [b]It's very important to set [member Resource.resource_name] as the [i]resource file name without the extension[/i] in the inspector as other scripts will identify and find items by that property.


const RESOURCES_PATH: String = "res://assets/resources/items/" ## The path where item resources are stored.

@export var name: String = "Unnamed" ## The item's name.
@export var plural_name: String = "Unnamed" ## The item's plural name.
@export_multiline var description: String = "???" ## The item's description.
@export var texture: Texture2D ## The item's texture.
@export var pocket: Bag.Pockets = Bag.Pockets.ITEMS ## The bag pocket in which the item goes into.
@export_range(0, 1000000, 1, "or_greater") var price: int = 0 ## The price when the item is bought.
@export_range(0, 1000000, 1, "or_greater") var sell_price: int = 0 ## The price the item it's sold at. If 0, can't be sold.
@export var bp_price: int = 0 ## The price in battle points the item is bought at.
@export var consumable: bool = false ## If the item is consumed on use.
@export var trashable: bool = true ## If the item can be trashed.
@export var can_use_in_bag: bool = false ## Whether the item can be used from the bag.
@export var can_use_in_battle: bool = false ## Whether the item can be used in battle.
@export var can_be_held: bool = true ## If a [Pokemon] can hold the item.
@export var flags: Array[String] = [] ## Flags (Such as Fling strength).
@export var show_quantity: bool = true ## If the item quantity is shown in the bag.

var held_effect: BattleEffect ## The item's effect when held by a [Pokemon]. [br] Has to be set via code.
var can_be_sold: bool: ## Shorthand to check if the item can be sold.[br] See [member sell_price].
	get: return sell_price > 0
var id: String: ## Shorthand to get [Resource.resource_name]. Useful for coherence with other scripts and to avoid mistakingly changing it.
	get: return resource_name


## Returns the text shown in the bag to use the item. [br]
## By default it's "Use", but for items like the Bicycle, it returns "Walk" when riding the bike.
func get_use_text() -> String:
	return "Use"


## Effect when used from the bag. Virtual.
func bag_use() -> void:
	pass


## Effect when used in battle. Virtual.
func battle_use() -> void:
	pass


## Duplicates the item along with [member held_effect] if not null. 
func copy() -> Item:
	var copied: Item = duplicate()
	if copied.held_effect:
		copied.held_effect = copied.held_effect.duplicate()
	return copied


## Returns the item resource in [constant RESOURCE_PATH] given the [member id].
@warning_ignore("shadowed_variable")
static func get_item(id: String) -> Item:
	if not id.get_extension() in ["tres", "res"]:
		id += ".tres"
	return Utils.load_no_error(RESOURCES_PATH.path_join(id))


## Gets the item resource in [constant RESOURCE_PATH] given the [member id] and returns a [method copy] of it.
@warning_ignore("shadowed_variable")
static func copy_from_id(id: String) -> Item:
	var item: Item = Item.get_item(id)
	if item:
		return item.copy()
	else:
		return null