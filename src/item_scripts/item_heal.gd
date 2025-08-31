@tool
class_name ItemHeal extends Item

@export var heal_amount: int = 0 ## The amount of HP to heal.
@export var heal_max: bool = false ## If true, ignore [member heal_amount] and heal HP to the max.
@export var heal_status: bool = false ## If true, also heal status effects.


func _validate_property(property: Dictionary) -> void:
	if property.name == "heal_amount":
		if heal_max:
			property.usage &= ~PROPERTY_USAGE_EDITOR
		else:
			property.usage |= PROPERTY_USAGE_EDITOR


func bag_use() -> void:
	var party: PartyMenu = await PartyMenu.open(null, {"select": true})

	party.pokemon_selected.connect(
		func(pokemon: Pokemon):
			# TODO: Add animations in the party screen
			if pokemon.hp == pokemon.max_hp:
				return
			if consumable:
				Bag.remove_item(id)
			party.closed.emit()
	)


func battle_use() -> void:
	var battle: Battle = Globals.current_battle
	battle.ui.pokemon_selected.connect(_on_pokemon_selected, CONNECT_ONE_SHOT)
	battle.ui.pokemon_selection_closed.connect(
		func():
			if battle.ui.pokemon_selected.is_connected(_on_pokemon_selected):
				battle.ui.pokemon_selected.disconnect(_on_pokemon_selected), CONNECT_ONE_SHOT
	)
	battle.ui.prompt_selection()


func _on_pokemon_selected(pokemon: Pokemon) -> void:
	var battle: Battle = Globals.current_battle
	var battle_pokemon: BattlePokemon = battle.pokemons[battle.get_slot(pokemon)]
	heal(battle_pokemon)
	battle.animate_hp(
		battle.ui.used_databoxes[battle.get_slot(battle_pokemon)]
	)
	if consumable:
		Bag.remove_item(id)


func heal(target: Variant) -> void:
	if target is Pokemon:
		target.hp += heal_amount if not heal_max else target.max_hp - target.hp
	elif target is BattlePokemon:
		target.apply_heal(heal_amount if not heal_max else target.max_hp - target.hp)
	else:
		printerr("Chosen target is not a Pokemon or BattlePokemon.")