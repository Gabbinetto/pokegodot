import json
from os import path


class PBSParser:
    def __init__(self, directory_path: str) -> None:

        self.directory = directory_path
        self.data = {}

        self.data["pokemon"] = self.__default_parse("pokemon.txt")
        self.data["abilities"] = self.__default_parse("abilities.txt")
        self.data["items"] = self.__default_parse("items.txt")
        self.data["types"] = self.__default_parse("types.txt")
        self.data["forms"] = self.__forms_parse("pokemon_forms.txt")

    def __default_parse(self, filename: str):

        data = {}

        last_parsed = ""
        with open(path.join(self.directory, filename), "r") as f:
            lines = f.readlines()
            for line in lines:
                if (
                    "# See the documentation on the wiki to learn how to edit this file."
                    in line
                    or line.startswith("#-")
                    or not line
                ):
                    continue

                if line.startswith("["):
                    last_parsed = line.replace("[", "").replace("]", "").strip()
                    data[last_parsed] = {}
                    continue

                key, value = [i.strip() for i in line.split(" = ")]
                # If the value is a number, convert it to float
                try:
                    value = float(value)
                    if value.is_integer():
                        value = int(value)
                except:
                    pass
                data[last_parsed][key] = value

        return data

    def __forms_parse(self, filename: str):

        data = {}

        last_parsed = ""
        with open(path.join(self.directory, filename), "r") as f:
            lines = f.readlines()
            for line in lines:
                if (
                    "# See the documentation on the wiki to learn how to edit this file."
                    in line
                    or line.startswith("#-")
                    or not line
                ):
                    continue

                if line.startswith("["):
                    last_parsed = (
                        line.replace("[", "").replace("]", "").strip()
                    ).replace(",", "_")
                    data[last_parsed] = {}
                    continue

                key, value = [i.strip() for i in line.split(" = ")]
                # If the value is a number, convert it to float
                try:
                    value = float(value)
                    if value.is_integer():
                        value = int(value)
                except:
                    pass
                data[last_parsed][key] = value

        return data

    def save(self):
        with open("PBS.json", "w") as f:
            json.dump(self.data, f, indent=2)


if __name__ == "__main__":
    parser = PBSParser(path.join("..", "PBS"))
    parser.save()
