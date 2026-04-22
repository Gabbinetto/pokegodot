extends BattleEffect

# Attributes: Dictionary with Stat name as string and boost amount as value

func apply(_battle: BattleServer, step: BattleServer.BattleSteps, data: Dictionary[String, Variant]) -> void:
	match step:
		BattleServer.BattleSteps.AFTER_DAMAGE_APPLIED:
			for target: BattlePokemon in data.targets:
				target.add_boosts(attributes)
