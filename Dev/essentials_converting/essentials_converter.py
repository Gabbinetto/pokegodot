from typing import Self
from enum import StrEnum, IntEnum
from PIL import Image
import json
import shutil
import os
import copy


BASE_PATH: str = os.path.join("essentials", "PBS")
GEN_9_CONTENT: str = os.path.join(BASE_PATH, "Gen 9 backup")
VANILLA_PBS_CONTENT: str = os.path.join(BASE_PATH, "Gen 8 backup")
GRAPHICS_PATH: str = os.path.join("essentials", "Graphics")
POKEMON_SPRITES_PATH: str = os.path.join(GRAPHICS_PATH, "Pokemon")
BATTLEBACKS_PATH: str = os.path.join(GRAPHICS_PATH, "Battlebacks")
OUTPUT_PATH: str = "output"


class Files(StrEnum):
    ABILITIES = "abilities.txt"
    ITEMS = "items.txt"
    MOVES = "moves.txt"
    POKEMON = "pokemon.txt"
    FORMS = "pokemon_forms.txt"
    TYPES = "types.txt"


class GrowthRates(IntEnum):
    FAST = 0
    MEDIUM_FAST = 1
    SLOW = 2
    MEDIUM_SLOW = 3
    ERRATIC = 4
    FLUCTUATING = 5


class Types(IntEnum):
    NORMAL = 0
    FIGHTING = 1
    FLYING = 2
    POISON = 3
    GROUND = 4
    ROCK = 5
    BUG = 6
    GHOST = 7
    STEEL = 8
    QMARKS = 9
    FIRE = 10
    WATER = 11
    GRASS = 12
    ELECTRIC = 13
    PSYCHIC = 14
    ICE = 15
    DRAGON = 16
    DARK = 17
    FAIRY = 18


class PokemonProperties(StrEnum):
    """Based on https://essentialsdocs.fandom.com/wiki/Defining_a_species"""

    # Pokemon properties
    NAME = "Name"
    FORM_NAME = "FormName"
    TYPES = "Types"
    BASE_STATS = "BaseStats"
    GENDER_RATIO = "GenderRatio"
    GROWTH_RATE = "GrowthRate"
    BASE_EXP = "BaseExp"
    EVS = "EVs"
    CATCH_RATE = "CatchRate"
    HAPPINESS = "Happiness"
    ABILITIES = "Abilities"
    HIDDEN_ABILITIES = "HiddenAbilities"
    MOVES = "Moves"
    TUTOR_MOVES = "TutorMoves"
    EGG_MOVES = "EggMoves"
    EGG_GROUPS = "EggGroups"
    HATCH_STEPS = "HatchSteps"
    INCENSE = "Incense"
    OFFSPRING = "Offspring"
    HEIGHT = "Height"
    WEIGHT = "Weight"
    COLOR = "Color"
    SHAPE = "Shape"
    HABITAT = "Habitat"
    CATEGORY = "Category"
    POKEDEX = "Pokedex"
    GENERATION = "Generation"
    FLAGS = "Flags"
    WILD_ITEM_COMMON = "WildItemCommon"
    WILD_ITEM_UNCOMMON = "WildItemUncommon"
    WILD_ITEM_RARE = "WildItemRare"
    EVOLUTIONS = "Evolutions"
    # Forms properties TODO: Implement
    MEGA_STONE = "MegaStone"
    MEGA_MOVE = "MegaMove"
    MEGA_MESSAGE = "MegaMessage"
    UNMEGA_FORM = "UnmegaForm"
    POKEDEX_FORM = "PokedexForm"


STATS = ["HP", "ATTACK", "DEFENSE", "SPECIAL_ATTACK", "SPECIAL_DEFENSE", "SPEED"]
GENDER_RATIOS: dict[str, float] = {
    # Numerator for the fraction that calculates the probability of being female out of 8, so for example Always female is 8/8
    "AlwaysMale": 0.0,
    "FemaleOneEighth": 1.0,
    "Female25Percent": 2.0,
    "Female50Percent": 4.0,
    "Female75Percent": 6.0,
    "FemaleSevenEighths": 7.0,
    "AlwaysFemale": 8.0,
    "Genderless": -1.0,  # Special case
}

POKEMON_TEMPLATE: dict[str] = {
    "name": "Unnamed",
    "form_number": 0,
    "form_name": "",
    "types": [],
    "base_stats": {stat: 1 for stat in STATS},
    "gender_ratio": 4.0,
    "growth_rate": "Medium",
    "base_exp": 0,
    "evs": {stat: 0 for stat in STATS},
    "catch_rate": 255,
    "base_happiness": 70,
    "abilities": [],
    "hidden_abilities": [],
    "moves": [],
    "tutor_moves": [],
    "egg_moves": [],
    "egg_groups": [],
    "egg_cycles": 1,
    "incense": "",
    "offspring": [],
    "info": {
        "height": 0.0,
        "weight": 0.0,
        "color": "Red",
        "shape": "Head",
        "habitat": "",
        "category": "???",
        "description": "???",
        "generation": 0,
    },
    "flags": [],
    "items": {
        "common": "",
        "uncommon": "",
        "rare": "",
    },
    "evolutions": [],
}


class EssentialsConverter:
    @staticmethod
    def merge_pbs() -> None:
        """Merge vanilla files with gen 9 files"""
        files: list[str] = [item.replace(".txt", "") for item in Files]

        for file_name in files:
            file_content: str = ""

            with open(
                os.path.join(VANILLA_PBS_CONTENT, file_name + ".txt"),
                "r",
                encoding="utf-8",
            ) as f:
                file_content += f.read()

            if file_name == "pokemon":
                file_name = "pokemon_base"
            gen_9_file: str = os.path.join(GEN_9_CONTENT, file_name + "_Gen_9_Pack.txt")

            if os.path.exists(gen_9_file):
                with open(gen_9_file, "r", encoding="utf-8") as f:
                    lines: list[str] = f.readlines()
                    lines.pop(0)
                    file_content += "".join(lines)

            if file_name == "pokemon_base":
                file_name = "pokemon"

            with open(
                os.path.join(BASE_PATH, file_name + ".txt"), "w", encoding="utf-8"
            ) as f:
                f.write(file_content)

    def __init__(self):
        self.buffer: list[list[str]] = []

        self.pokemon: dict[str, dict[str]] = {}

        # Create an output path
        os.makedirs(OUTPUT_PATH, exist_ok=True)
        if not os.path.exists(os.path.join(OUTPUT_PATH, ".gdignore")):
            # Create a .gdignore file as Godot is pretty slow while importing
            # so its best to avoid any unnecessary importing of files
            open(os.path.join(OUTPUT_PATH, ".gdignore"), "w").close()

    def __get_pair(self, line: str) -> tuple[str, str]:
        return tuple(line.split(" = "))

    def open(self, file: Files) -> Self:
        self.buffer.clear()

        lines: list[str] = []
        with open(os.path.join(BASE_PATH, file), "r", encoding="utf-8") as f:
            lines = list(
                map(lambda line: line.strip(), f.readlines())
            )  # Read lines without trailing whitespaces
        lines.pop(0)  # Remove the first line that mentions the documentations

        data_section: list[str] = []

        for line in lines:
            if line.startswith("#"):
                if len(data_section) > 0:
                    self.buffer.append(data_section)
                    data_section = []
                continue

            data_section.append(line)
        self.buffer.append(data_section)

        return self

    def fetch_pokemon(self) -> Self:

        for index, pokemon_data in enumerate(self.buffer):
            pokemon: dict[str] = copy.deepcopy(POKEMON_TEMPLATE)

            id: str = ""
            form_number: int = 0

            for item in pokemon_data:
                if item.startswith("["):
                    id = item.strip("[]")
                    if "," in id:
                        id, form_number = id.split(",")
                        form_number = int(form_number)
                        if form_number > 0:
                            forms: list[dict[str]] = self.pokemon[id]["forms"]
                            base_form: dict[str] = [
                                form for form in forms if form.get("form_number") == 0
                            ][0]
                            pokemon = copy.deepcopy(base_form)
                    continue

                pokemon["form_number"] = form_number

                key, value = self.__get_pair(item)

                # region Properties
                match key:
                    case PokemonProperties.NAME:
                        pokemon["name"] = value
                    case PokemonProperties.FORM_NAME:
                        pokemon["form_name"] = value
                    case PokemonProperties.TYPES:
                        pokemon["types"] = [
                            Types[pkmn_type] for pkmn_type in value.split(",")
                        ]
                    case PokemonProperties.BASE_STATS:
                        pokemon["base_stats"] = {
                            stat: int(stat_value)
                            for stat, stat_value in zip(STATS, value.split(","))
                        }
                    case PokemonProperties.GENDER_RATIO:
                        pokemon["gender_ratio"] = GENDER_RATIOS.get(value)
                    case PokemonProperties.GROWTH_RATE:
                        pokemon["growth_rate"] = {
                            "Fast": GrowthRates.FAST,
                            "Medium": GrowthRates.MEDIUM_FAST,
                            "Slow": GrowthRates.SLOW,
                            "Parabolic": GrowthRates.MEDIUM_SLOW,
                            "Erratic": GrowthRates.ERRATIC,
                            "Fluctuating": GrowthRates.FLUCTUATING,
                        }.get(value, GrowthRates.FAST)
                    case PokemonProperties.BASE_EXP:
                        pokemon["base_exp"] = int(value)
                    case PokemonProperties.EVS:
                        evs: list[str] = value.split(",")
                        for i in range(0, len(evs), 2):
                            pokemon["evs"][evs[i]] = int(evs[i + 1])
                    case PokemonProperties.CATCH_RATE:
                        pokemon["catch_rate"] = int(value)
                    case PokemonProperties.HAPPINESS:
                        pokemon["base_happiness"] = int(value)
                    case PokemonProperties.ABILITIES:
                        pokemon["abilities"] = value.split(",")
                    case PokemonProperties.HIDDEN_ABILITIES:
                        pokemon["hidden_abilities"] = value.split(",")
                    case PokemonProperties.MOVES:
                        moves: list[str] = value.split(",")
                        pokemon["moves"].clear()
                        for i in range(0, len(moves), 2):
                            pokemon["moves"].append(
                                {
                                    "level": int(
                                        moves[i]
                                    ),  # 0 if on evolution, -1 if only through reminder
                                    "id": moves[i + 1],
                                }
                            )
                        pokemon["moves"].sort(key=lambda move: move["level"])
                    case PokemonProperties.TUTOR_MOVES:
                        pokemon["tutor_moves"] = sorted(value.split(","))
                    case PokemonProperties.EGG_MOVES:
                        pokemon["egg_moves"] = sorted(value.split(","))
                    case PokemonProperties.EGG_GROUPS:
                        pokemon["egg_groups"] = value.split(",")
                    case PokemonProperties.HATCH_STEPS:
                        pokemon["egg_cycles"] = int(value) // 256
                    case PokemonProperties.INCENSE:
                        pokemon["incense"] = value  # TODO: Review
                    case PokemonProperties.OFFSPRING:
                        offsprings = value.split(",")
                        pokemon["offspring"] = [
                            {"id": offspring, "form_number": 0}
                            for offspring in offsprings
                        ]
                    case PokemonProperties.HEIGHT:
                        pokemon["info"]["height"] = float(value)
                    case PokemonProperties.WEIGHT:
                        pokemon["info"]["weight"] = float(value)
                    case PokemonProperties.COLOR:
                        pokemon["info"]["color"] = value  # TODO: Review
                    case PokemonProperties.SHAPE:
                        pokemon["info"]["shape"] = value  # TODO: Review
                    case PokemonProperties.HABITAT:
                        pokemon["info"]["habitat"] = value  # TODO: Review
                    case PokemonProperties.CATEGORY:
                        pokemon["info"]["category"] = value
                    case PokemonProperties.POKEDEX:
                        pokemon["info"]["description"] = value
                    case PokemonProperties.GENERATION:
                        pokemon["info"]["generation"] = int(value)
                    case PokemonProperties.FLAGS:
                        pokemon["flags"] = value.split(",")
                    case PokemonProperties.WILD_ITEM_COMMON:
                        pokemon["items"]["common"] = value
                    case PokemonProperties.WILD_ITEM_UNCOMMON:
                        pokemon["items"]["uncommon"] = value
                    case PokemonProperties.WILD_ITEM_RARE:
                        pokemon["items"]["rare"] = value
                    case PokemonProperties.EVOLUTIONS:
                        pass  # TODO
            # endregion

            # region Filter properties for alternate forms
            if form_number > 0:
                form_properties: dict[str] = {}
                forms: list[dict[str]] = self.pokemon[id]["forms"]
                base_form: dict[str] = [
                    form for form in forms if form.get("form_number") == 0
                ][0]
                # Get only the properties that change from the base form
                for key in [
                    key
                    for key, value in pokemon.items()
                    if value != base_form.get(key, None)
                ]:
                    form_properties[key] = pokemon[key]
                pokemon = form_properties
            # endregion

            if self.pokemon.get(id, None) is None:
                self.pokemon[id] = {
                    "number": index + 1,
                    "forms": [pokemon],
                }
            else:
                self.pokemon[id]["forms"].append(pokemon)

        return self

    def save(self, **kwargs) -> Self:
        if kwargs.get("pokemon"):
            with open(
                os.path.join(OUTPUT_PATH, "pokemon.json"), "w", encoding="utf-8"
            ) as f:
                json.dump(self.pokemon, f, indent=2)

        return self

    def load(self, **kwargs) -> Self:
        if kwargs.get("pokemon"):
            with open(
                os.path.join(OUTPUT_PATH, "pokemon.json"), "r", encoding="utf-8"
            ) as f:
                self.pokemon = json.load(f)

    def generate_sprites_folder(self, stop_at: int = 0) -> Self:
        if stop_at == 0:
            stop_at = len(self.pokemon) + 1

        self.__extract_pokemon_sprite("", default=True)

        for key in list(self.pokemon.keys())[:stop_at]:
            for form in self.pokemon[key]["forms"]:
                self.__extract_pokemon_sprite(key, form["form_number"])
                print(key, form["form_number"], "done")

        return self

    def __extract_pokemon_sprite(
        self, id: str, form: int = 0, default: bool = False
    ) -> None:
        SPRITES_FOLDER: str = os.path.join(
            OUTPUT_PATH, "pokemon_sprites", "_default" if default else f"{id}_{form}"
        )
        os.makedirs(SPRITES_FOLDER, exist_ok=True)

        image_name: str = f"{id}.png" if form == 0 else f"{id}_{form}.png"
        female_image_name: str = (
            f"{id}_female.png" if form == 0 else f"{id}_{form}_female.png"
        )
        footprint_image_name: str = f"{id}.png"
        if default:
            image_name = "000.png"
            female_image_name = "000_female.png"  # Unused, for consistency
            footprint_image_name = (
                "000.png"  # Nonexistant in base Essentials, for consistency
            )

        # Front 192x192
        if os.path.exists(os.path.join(POKEMON_SPRITES_PATH, "Front", image_name)):
            shutil.copy2(
                os.path.join(POKEMON_SPRITES_PATH, "Front", image_name),
                os.path.join(SPRITES_FOLDER, "front_n_m.png"),
            )
        if os.path.exists(
            os.path.join(POKEMON_SPRITES_PATH, "Front", female_image_name)
        ):
            shutil.copy2(
                os.path.join(POKEMON_SPRITES_PATH, "Front", female_image_name),
                os.path.join(SPRITES_FOLDER, "front_n_f.png"),
            )
        if os.path.exists(
            os.path.join(POKEMON_SPRITES_PATH, "Front shiny", image_name)
        ):
            shutil.copy2(
                os.path.join(POKEMON_SPRITES_PATH, "Front shiny", image_name),
                os.path.join(SPRITES_FOLDER, "front_s_m.png"),
            )
        if os.path.exists(
            os.path.join(POKEMON_SPRITES_PATH, "Front shiny", female_image_name)
        ):
            shutil.copy2(
                os.path.join(POKEMON_SPRITES_PATH, "Front shiny", female_image_name),
                os.path.join(SPRITES_FOLDER, "front_s_f.png"),
            )

        # Back 288x288
        if os.path.exists(os.path.join(POKEMON_SPRITES_PATH, "Back", image_name)):
            shutil.copy2(
                os.path.join(POKEMON_SPRITES_PATH, "Back", image_name),
                os.path.join(SPRITES_FOLDER, "back_n_m.png"),
            )
        if os.path.exists(
            os.path.join(POKEMON_SPRITES_PATH, "Back", female_image_name)
        ):
            shutil.copy2(
                os.path.join(POKEMON_SPRITES_PATH, "Back", female_image_name),
                os.path.join(SPRITES_FOLDER, "back_n_f.png"),
            )
        if os.path.exists(os.path.join(POKEMON_SPRITES_PATH, "Back shiny", image_name)):
            shutil.copy2(
                os.path.join(POKEMON_SPRITES_PATH, "Back shiny", image_name),
                os.path.join(SPRITES_FOLDER, "back_s_m.png"),
            )
        if os.path.exists(
            os.path.join(POKEMON_SPRITES_PATH, "Back shiny", female_image_name)
        ):
            shutil.copy2(
                os.path.join(POKEMON_SPRITES_PATH, "Back shiny", female_image_name),
                os.path.join(SPRITES_FOLDER, "back_s_f.png"),
            )

        # Icons
        if os.path.exists(os.path.join(POKEMON_SPRITES_PATH, "Icons", image_name)):
            shutil.copy2(
                os.path.join(POKEMON_SPRITES_PATH, "Icons", image_name),
                os.path.join(SPRITES_FOLDER, "icon_n.png"),
            )
        if os.path.exists(
            os.path.join(POKEMON_SPRITES_PATH, "Icons shiny", image_name)
        ):
            shutil.copy2(
                os.path.join(POKEMON_SPRITES_PATH, "Icons shiny", image_name),
                os.path.join(SPRITES_FOLDER, "icon_s.png"),
            )
        # Footprint
        if os.path.exists(
            os.path.join(POKEMON_SPRITES_PATH, "Footprints", footprint_image_name)
        ):
            shutil.copy2(
                os.path.join(POKEMON_SPRITES_PATH, "Footprints", footprint_image_name),
                os.path.join(SPRITES_FOLDER, "footprint.png"),
            )

    def extract_battlebacks(self) -> Self:
        output: str = os.path.join(OUTPUT_PATH, "battlebacks")

        bases: list[str] | set[str] = []
        backgrounds: list[str] | set[str] = []
        messages: list[str] | set[str] = []

        join_parts = lambda parts: parts[0] if len(parts) <= 2 else "_".join(parts[:-1])

        with os.scandir(BATTLEBACKS_PATH) as dir:
            for entry in dir:
                if not entry.is_file():
                    continue
                filename: str = entry.name
                file_parts: list[str] = filename.split("_")
                match file_parts[-1]:
                    case "base0.png" | "base1.png":
                        bases.append(join_parts(file_parts))
                    case "bg.png":
                        backgrounds.append(join_parts(file_parts))
                    case "message.png":
                        messages.append(join_parts(file_parts))

        # Get rid of duplicates
        bases = set(bases)
        backgrounds = set(backgrounds)
        messages = set(messages)

        # Bases
        # Merge bases into one image
        os.makedirs(os.path.join(OUTPUT_PATH, "battlebacks", "bases"), exist_ok=True)
        for base in bases:
            image: Image = merge_images_vertically(
                os.path.join(BATTLEBACKS_PATH, base + "_base0.png"),
                os.path.join(BATTLEBACKS_PATH, base + "_base1.png"),
            )
            image.save(os.path.join(OUTPUT_PATH, "battlebacks", "bases", f"{base}.png"))

        # Backgrounds
        os.makedirs(
            os.path.join(OUTPUT_PATH, "battlebacks", "backgrounds"), exist_ok=True
        )
        for background in backgrounds:
            shutil.copy2(
                os.path.join(BATTLEBACKS_PATH, background + "_bg.png"),
                os.path.join(
                    OUTPUT_PATH, "battlebacks", "backgrounds", f"{background}.png"
                ),
            )
        # Message boxes
        os.makedirs(os.path.join(OUTPUT_PATH, "battlebacks", "messages"), exist_ok=True)
        for message in messages:
            shutil.copy2(
                os.path.join(BATTLEBACKS_PATH, message + "_message.png"),
                os.path.join(OUTPUT_PATH, "battlebacks", "messages", f"{message}.png"),
            )

        return self


def merge_images_vertically(image1_path, image2_path) -> Image:
    # Open the two images
    image1 = Image.open(image1_path)
    image2 = Image.open(image2_path)

    # Calculate the width and total height of the new image
    total_width = max(image1.width, image2.width)
    total_height = image1.height + image2.height

    # Create a new blank image with the calculated dimensions
    merged_image = Image.new("RGBA", (total_width, total_height))

    # Paste the first image at the top
    merged_image.paste(image1, (0, 0))

    # Paste the second image right below the first
    merged_image.paste(image2, (0, image1.height))

    return merged_image


if __name__ == "__main__":
    EssentialsConverter.merge_pbs()
    converter: EssentialsConverter = EssentialsConverter()
    converter.open(Files.POKEMON).fetch_pokemon()
    converter.open(Files.FORMS).fetch_pokemon()
    converter.save(pokemon=True)
    # converter.generate_sprites_folder(3)
