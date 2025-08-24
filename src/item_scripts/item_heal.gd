@tool
class_name ItemHeal extends Item

@export var heal_amount: int = 0


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


func heal(target: Variant) -> void:
	if target is Pokemon:
		target.hp += heal_amount
	elif target is BattlePokemon:
		target.apply_heal(heal_amount)
	else:
		printerr("Chosen target is not a Pokemon or BattlePokemon.")