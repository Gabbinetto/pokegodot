class_name Species extends Resource

const STATS: Dictionary = {
    "HP": "HP",
    "ATTACK": "ATTACK",
    "DEFENSE": "DEFENSE",
    "SPECIAL_ATTACK": "SPECIAL_ATTACK",
    "SPECIAL_DEFENSE": "SPECIAL_DEFENSE",
    "SPEED": "SPEED",
}


var id: String = ""
var name: String = "Unnamed"
var form_number: int = 0
var form_name: String = ""
var types: Array[Types.Enum] = []
var base_stats: Dictionary = {
    STATS.HP: 1,
    STATS.ATTACK: 1,
    STATS.DEFENSE: 1,
    STATS.SPECIAL_ATTACK: 1,
    STATS.SPECIAL_DEFENSE: 1,
    STATS.SPEED: 1,
}
var gender_ratio: float = 4.0
var growth_rate: String = "Medium" # TODO: Review
var base_exp: int = 0
var evs: Dictionary = {
    STATS.HP: 0,
    STATS.ATTACK: 0,
    STATS.DEFENSE: 0,
    STATS.SPECIAL_ATTACK: 0,
    STATS.SPECIAL_DEFENSE: 0,
    STATS.SPEED: 0,
}
var catch_rate: int = 255
var base_happiness: int = 70
var abilities: Array[String] = []
var hidden_abilities: Array[String] = []
var moves: Array[Dictionary] = []
var tutor_moves: Array[String] = []
var egg_moves: Array[String] = []
var egg_groups: Array[String] = []
var hatch_steps: int = 1
var incense: String = ""
var offspring: Array[Dictionary] = []
var info: Dictionary = {
    "height": 0.0,
    "weight": 0.0,
    "color": "Red",
    "shape": "Head",
    "habitat": "",
    "category": "???",
    "description": "???",
    "generation": 0,
}
var flags: Array[String] = []
var items: Dictionary = {
    "common": "",
    "uncommon": "",
    "rare": "",
}
var evolutions: Array[Dictionary] = []


func _init(_id: String, _form_number: int = 0) -> void:
    id = _id
    form_number = form_number

    var data: Dictionary
    for form: Dictionary in DB.pokemon.get(id).forms:
        if form.form_number == form_number:
            data = form.duplicate(true)
            break
    
    # Array properties have to be assigned manually because Godot is silly
    for type: int in data.types:
        types.append(type as Types.Enum)
    data.erase("types")
    abilities = data.abilities as Array[String]
    data.erase("abilities")
    hidden_abilities = data.hidden_abilities as Array[String]
    data.erase("hidden_abilities")
    moves = data.moves as Array[Dictionary]
    data.erase("moves")
    tutor_moves = data.tutor_moves as Array[String]
    data.erase("tutor_moves")
    egg_moves = data.egg_moves as Array[String]
    data.erase("egg_moves")
    egg_groups = data.egg_groups as Array[String]
    data.erase("egg_groups")
    offspring = data.offspring as Array[Dictionary]
    data.erase("offspring")


    for key in data:
        set(key, data[key])