# Make a CSV file of moves with their FunctionCode, to keep track of what moves to implement
import sys


def make_list(path: str) -> None:

    lines: list[str]
    new_lines: list[str] = []

    buffer: list[str] = []

    with open(path, "r", encoding="utf-8") as f:
        lines = list(map(lambda string: string.strip(), f.readlines()))

    lines.pop(0)

    for line in lines:
        if line.startswith("#-"):
            new_lines.append(",".join(buffer) + "\n")
            buffer.clear()
        elif line.startswith("["):
            id = line.strip("[]")
            buffer.append(id)
        else:
            print(line)
            key, value = line.split(" = ")
            if key == "Name" or key == "FunctionCode":
                buffer.append(value)

    new_lines = list(filter(lambda item: bool(item.strip()), new_lines))

    # Sort
    new_lines.sort(key=lambda line: line.split(",")[-1])

    with open("moves_list.csv", "w", encoding="utf-8") as f:
        f.writelines(new_lines)


if __name__ == "__main__":
    path: str
    if len(sys.argv) > 1:
        path = sys.argv[1]
    else:
        path = input("Moves PBS file path: ")

    make_list(path)
