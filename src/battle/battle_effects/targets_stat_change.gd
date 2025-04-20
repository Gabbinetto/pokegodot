extends BattleEffect

# Attributes: Dictionary with Stat name as string and boost amount as value

func apply(battle: Battle, step: Battle.BattleSteps, data: Dictionary[String, Variant]) -> void:
	match step:
		Battle.BattleSteps.AFTER_MOVE_ANIMATION:
			for target: BattlePokemon in data.targets:
				target.add_boosts(attributes)
