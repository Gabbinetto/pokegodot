extends Node


enum Sets {
	CAVE_1,
	CAVE_1_ICE,
	CAVE_1_WATER,
	CAVE_2,
	CAVE_2_ICE,
	CAVE_2_WATER,
	CAVE_3,
	CAVE_3_ICE,
	CAVE_3_WATER,
	CHAMPION_1,
	CHAMPION_2,
	CITY,
	CITY_EVENING,
	CITY_NIGHT,
	DISTORTION,
	ELITE_1,
	ELITE_2,
	ELITE_3,
	ELITE_4,
	ELITE_5,
	ELITE_6,
	ELITE_7,
	ELITE_8,
	FIELD,
	FIELD_EVENING,
	FIELD_NIGHT,
	FOREST,
	FOREST_EVENING,
	FOREST_NIGHT,
	GRASS,
	GRASS_EVENING,
	GRASS_NIGHT,
	INDOOR_1,
	INDOOR_2,
	INDOOR_3,
	ROCKY,
	ROCKY_EVENING,
	ROCKY_NIGHT,
	SAND,
	SAND_EVENING,
	SAND_NIGHT,
	SNOW,
	SNOW_EVENING,
	SNOW_NIGHT,
	UNDERWATER,
	WATER,
}

const BASES_PATH: String = "res://assets/graphics/battlebacks/bases/"
const BACKGROUNDS_PATH: String = "res://assets/graphics/battlebacks/backgrounds/"
const MESSAGES_PATH: String = "res://assets/graphics/battlebacks/messages/"

var loaded_sets: Dictionary[Sets, Set] = {
	Sets.CAVE_1: Set.new("cave1", "cave1", "cave1"),
	Sets.CAVE_1_ICE: Set.new("cave1_ice", "cave1", "cave1"),
	Sets.CAVE_1_WATER: Set.new("cave1_water", "cave1", "cave1"),
	Sets.CAVE_2: Set.new("cave2", "cave2", "cave2"),
	Sets.CAVE_2_ICE: Set.new("cave2_ice", "cave2", "cave2"),
	Sets.CAVE_2_WATER: Set.new("cave2_water", "cave2", "cave2"),
	Sets.CAVE_3: Set.new("cave3", "cave3", "cave3"),
	Sets.CAVE_3_ICE: Set.new("cave3_ice", "cave3", "cave3"),
	Sets.CAVE_3_WATER: Set.new("cave3_water", "cave3", "cave3"),
	Sets.CHAMPION_1: Set.new("champion1", "champion1", "champion1"),
	Sets.CHAMPION_2: Set.new("champion2", "champion2", "champion2"),
	Sets.CITY: Set.new("city", "city", "city"),
	Sets.CITY_EVENING: Set.new("city", "city_eve", "city"),
	Sets.CITY_NIGHT: Set.new("city", "city_night", "city"),
	Sets.DISTORTION: Set.new("distortion", "distortion", "distortion"),
	Sets.ELITE_1: Set.new("elite1", "elite1", "elite1"),
	Sets.ELITE_2: Set.new("elite2", "elite2", "elite2"),
	Sets.ELITE_3: Set.new("elite3", "elite3", "elite3"),
	Sets.ELITE_4: Set.new("elite4", "elite4", "elite4"),
	Sets.ELITE_5: Set.new("elite5", "elite5", "elite5"),
	Sets.ELITE_6: Set.new("elite6", "elite6", "elite6"),
	Sets.ELITE_7: Set.new("elite7", "elite7", "elite7"),
	Sets.ELITE_8: Set.new("elite8", "elite8", "elite8"),
	Sets.FIELD: Set.new("field", "field", "field"),
	Sets.FIELD_EVENING: Set.new("field_eve", "field_eve", "field"),
	Sets.FIELD_NIGHT: Set.new("field_night", "field_night", "field"),
	Sets.FOREST: Set.new("forest", "forest", "forest"),
	Sets.FOREST_EVENING: Set.new("forest", "forest_eve", "forest"),
	Sets.FOREST_NIGHT: Set.new("forest", "forest_night", "forest"),
	Sets.GRASS: Set.new("grass", "field", "field"),
	Sets.GRASS_EVENING: Set.new("grass_eve", "field_eve", "field"),
	Sets.GRASS_NIGHT: Set.new("grass_night", "field_night", "field"),
	Sets.INDOOR_1: Set.new("indoor1", "indoor1", "indoor1"),
	Sets.INDOOR_2: Set.new("indoor2", "indoor2", "indoor2"),
	Sets.INDOOR_3: Set.new("indoor3", "indoor3", "indoor3"),
	Sets.ROCKY: Set.new("rocky", "rocky", "rocky"),
	Sets.ROCKY_EVENING: Set.new("rocky_eve", "rocky_eve", "rocky"),
	Sets.ROCKY_NIGHT: Set.new("rocky_night", "rocky_night", "rocky"),
	Sets.SAND: Set.new("sand", "rocky", "rocky"),
	Sets.SAND_EVENING: Set.new("sand_eve", "rocky_eve", "rocky"),
	Sets.SAND_NIGHT: Set.new("sand_night", "rocky_night", "rocky"),
	Sets.SNOW: Set.new("snow", "snow", "snow"),
	Sets.SNOW_EVENING: Set.new("snow_eve", "snow_eve", "snow"),
	Sets.SNOW_NIGHT: Set.new("snow_night", "snow_night", "snow"),
	Sets.UNDERWATER: Set.new("underwater", "underwater", "underwater"),
	Sets.WATER: Set.new("water", "water", "water"),
}


class Set:
	var background: Texture
	var message: Texture
	var player_base: Texture
	var enemy_base: Texture

	func _init(_base: String, _background: String, _message: String) -> void:

		var base: Texture = load(BASES_PATH + _base.replace(".png", "") + ".png")
		player_base = AtlasTexture.new()
		player_base.atlas = base
		player_base.region = Rect2(Vector2(0, 0), Vector2(512, 64))
		enemy_base = AtlasTexture.new()
		enemy_base.atlas = base
		enemy_base.region = Rect2(Vector2(0, 64), Vector2(256, 128))


		background = load(BACKGROUNDS_PATH + _background.replace(".png", "") + ".png")
		message = load(MESSAGES_PATH + _message.replace(".png", "") + ".png")
