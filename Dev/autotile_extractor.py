from PIL import Image
import os

TILES_SIZE = 32
COLUMNS = 8
ROWS = 6


# Follows this image: https://essentialsdocs.fandom.com/wiki/Tilesets?file=LargeAutotile.png
def split_autotile(image: Image) -> Image:
    new_image: Image = Image.new("RGBA", (TILES_SIZE * COLUMNS, TILES_SIZE * ROWS))

    central_tile = image.crop(
        (TILES_SIZE, TILES_SIZE * 2, TILES_SIZE * 2, TILES_SIZE * 3)
    )
    inner_tile = image.crop((TILES_SIZE * 2, 0, TILES_SIZE * 3, TILES_SIZE))
    corner_tile = image.crop((0, 0, TILES_SIZE, TILES_SIZE))

    for i in range(ROWS):
        for j in range(COLUMNS):
            new_image.paste(central_tile, (TILES_SIZE * j, TILES_SIZE * i))
    # Inners
    inner_top_left = inner_tile.crop((0, 0, TILES_SIZE // 2, TILES_SIZE // 2))
    inner_top_right = inner_tile.crop((TILES_SIZE // 2, 0, TILES_SIZE, TILES_SIZE // 2))
    inner_bottom_left = inner_tile.crop(
        (0, TILES_SIZE // 2, TILES_SIZE // 2, TILES_SIZE)
    )
    inner_bottom_right = inner_tile.crop(
        (TILES_SIZE // 2, TILES_SIZE // 2, TILES_SIZE, TILES_SIZE)
    )

    new_image.paste(inner_top_left, (TILES_SIZE, 0))  # Tile 1,0
    new_image.paste(  # Tile 2,0
        inner_top_right,
        (TILES_SIZE * 2 + TILES_SIZE // 2, 0),
    )
    new_image.paste(inner_top_left, (TILES_SIZE * 3, 0))  # Tile 3,0
    new_image.paste(  # Tile 3,0
        inner_top_right,
        (TILES_SIZE * 3 + TILES_SIZE // 2, 0),
    )
    new_image.paste(  # Tile 4,0
        inner_bottom_right,
        (TILES_SIZE * 4 + TILES_SIZE // 2, TILES_SIZE // 2),
    )
    new_image.paste(  # Tile 5,0
        inner_top_left,
        (TILES_SIZE * 5, 0),
    )
    new_image.paste(  # Tile 5,0
        inner_bottom_right,
        (TILES_SIZE * 5 + TILES_SIZE // 2, TILES_SIZE // 2),
    )
    new_image.paste(inner_top_right, (TILES_SIZE * 6 + TILES_SIZE // 2, 0))  # Tile 6,0
    new_image.paste(
        inner_bottom_right, (TILES_SIZE * 6 + TILES_SIZE // 2, TILES_SIZE // 2)
    )  # Tile 6,0
    new_image.paste(inner_top_left, (TILES_SIZE * 7, 0))  # Tile 7,0
    new_image.paste(inner_top_right, (TILES_SIZE * 7 + TILES_SIZE // 2, 0))  # Tile 7,0
    new_image.paste(
        inner_bottom_right, (TILES_SIZE * 7 + TILES_SIZE // 2, TILES_SIZE // 2)
    )  # Tile 7,0
    new_image.paste(inner_bottom_left, (0, TILES_SIZE + TILES_SIZE // 2))  # Tile 0,1
    new_image.paste(
        inner_bottom_left, (TILES_SIZE, TILES_SIZE + TILES_SIZE // 2)
    )  # Tile 1,1
    new_image.paste(inner_top_left, (TILES_SIZE, TILES_SIZE))  # Tile 1,1
    new_image.paste(
        inner_bottom_left, (TILES_SIZE * 2, TILES_SIZE + TILES_SIZE // 2)
    )  # Tile 2,1
    new_image.paste(
        inner_top_right, (TILES_SIZE * 2 + TILES_SIZE // 2, TILES_SIZE)
    )  # Tile 2,1
    new_image.paste(
        inner_bottom_left, (TILES_SIZE * 3, TILES_SIZE + TILES_SIZE // 2)
    )  # Tile 3,1
    new_image.paste(
        inner_top_right, (TILES_SIZE * 3 + TILES_SIZE // 2, TILES_SIZE)
    )  # Tile 3,1
    new_image.paste(inner_top_left, (TILES_SIZE * 3, TILES_SIZE))  # Tile 3,1
    new_image.paste(
        inner_bottom_left, (TILES_SIZE * 4, TILES_SIZE + TILES_SIZE // 2)
    )  # Tile 4,1
    new_image.paste(
        inner_bottom_right,
        (TILES_SIZE * 4 + TILES_SIZE // 2, TILES_SIZE + TILES_SIZE // 2),
    )  # Tile 4,1
    new_image.paste(
        inner_bottom_left, (TILES_SIZE * 5, TILES_SIZE + TILES_SIZE // 2)
    )  # Tile 5,1
    new_image.paste(
        inner_bottom_right,
        (TILES_SIZE * 5 + TILES_SIZE // 2, TILES_SIZE + TILES_SIZE // 2),
    )  # Tile 5,1
    new_image.paste(inner_top_left, (TILES_SIZE * 5, TILES_SIZE))  # Tile 5,1
    new_image.paste(
        inner_bottom_left, (TILES_SIZE * 6, TILES_SIZE + TILES_SIZE // 2)
    )  # Tile 6,1
    new_image.paste(
        inner_bottom_right,
        (TILES_SIZE * 6 + TILES_SIZE // 2, TILES_SIZE + TILES_SIZE // 2),
    )  # Tile 6,1
    new_image.paste(
        inner_top_right, (TILES_SIZE * 6 + TILES_SIZE // 2, TILES_SIZE)
    )  # Tile 6,1
    new_image.paste(
        inner_bottom_left, (TILES_SIZE * 7, TILES_SIZE + TILES_SIZE // 2)
    )  # Tile 7,1
    new_image.paste(
        inner_bottom_right,
        (TILES_SIZE * 7 + TILES_SIZE // 2, TILES_SIZE + TILES_SIZE // 2),
    )  # Tile 7,1
    new_image.paste(
        inner_top_right, (TILES_SIZE * 7 + TILES_SIZE // 2, TILES_SIZE)
    )  # Tile 7,1
    new_image.paste(inner_top_left, (TILES_SIZE * 7, TILES_SIZE))  # Tile 7,1

    # Edges
    left_edge = image.crop((0, TILES_SIZE * 2, TILES_SIZE, TILES_SIZE * 3))
    top_edge = image.crop((TILES_SIZE, TILES_SIZE, TILES_SIZE * 2, TILES_SIZE * 2))
    right_edge = image.crop(
        (TILES_SIZE * 2, TILES_SIZE * 2, TILES_SIZE * 3, TILES_SIZE * 3)
    )
    bottom_edge = image.crop(
        (TILES_SIZE, TILES_SIZE * 3, TILES_SIZE * 2, TILES_SIZE * 4)
    )
    # - Left edges
    new_image.paste(left_edge, (0, TILES_SIZE * 2))  # Tile 0,2
    new_image.paste(left_edge, (TILES_SIZE, TILES_SIZE * 2))  # Tile 1,2
    new_image.paste(
        inner_top_right, (TILES_SIZE + TILES_SIZE // 2, TILES_SIZE * 2)
    )  # Tile 1,2
    new_image.paste(left_edge, (TILES_SIZE * 2, TILES_SIZE * 2))  # Tile 2,2
    new_image.paste(
        inner_bottom_right,
        (TILES_SIZE * 2 + TILES_SIZE // 2, TILES_SIZE * 2 + TILES_SIZE // 2),
    )  # Tile 2,2
    new_image.paste(left_edge, (TILES_SIZE * 3, TILES_SIZE * 2))  # Tile 3,2
    new_image.paste(
        inner_top_right, (TILES_SIZE * 3 + TILES_SIZE // 2, TILES_SIZE * 2)
    )  # Tile 3,2
    new_image.paste(
        inner_bottom_right,
        (TILES_SIZE * 3 + TILES_SIZE // 2, TILES_SIZE * 2 + TILES_SIZE // 2),
    )  # Tile 3,2
    # - Top edges
    new_image.paste(top_edge, (TILES_SIZE * 4, TILES_SIZE * 2))  # Tile 4,2
    new_image.paste(top_edge, (TILES_SIZE * 5, TILES_SIZE * 2))  # Tile 5,2
    new_image.paste(
        inner_bottom_right,
        (TILES_SIZE * 5 + TILES_SIZE // 2, TILES_SIZE * 2 + TILES_SIZE // 2),
    )  # Tile 5,2
    new_image.paste(top_edge, (TILES_SIZE * 6, TILES_SIZE * 2))  # Tile 6,2
    new_image.paste(
        inner_bottom_left,
        (TILES_SIZE * 6, TILES_SIZE * 2 + TILES_SIZE // 2),
    )  # Tile 6,2
    new_image.paste(top_edge, (TILES_SIZE * 7, TILES_SIZE * 2))  # Tile 7,2
    new_image.paste(
        inner_bottom_left,
        (TILES_SIZE * 7, TILES_SIZE * 2 + TILES_SIZE // 2),
    )  # Tile 7,2
    new_image.paste(
        inner_bottom_right,
        (TILES_SIZE * 7 + TILES_SIZE // 2, TILES_SIZE * 2 + TILES_SIZE // 2),
    )  # Tile 7,2
    # - Right tiles
    new_image.paste(right_edge, (0, TILES_SIZE * 3))  # Tile 0,3
    new_image.paste(right_edge, (TILES_SIZE, TILES_SIZE * 3))  # Tile 1,3
    new_image.paste(
        inner_bottom_left, (TILES_SIZE, TILES_SIZE * 3 + TILES_SIZE // 2)
    )  # Tile 1,3
    new_image.paste(right_edge, (TILES_SIZE * 2, TILES_SIZE * 3))  # Tile 2,3
    new_image.paste(inner_top_left, (TILES_SIZE * 2, TILES_SIZE * 3))  # Tile 2,3
    new_image.paste(right_edge, (TILES_SIZE * 3, TILES_SIZE * 3))  # Tile 3,3
    new_image.paste(inner_top_left, (TILES_SIZE * 3, TILES_SIZE * 3))  # Tile 3,3
    new_image.paste(
        inner_bottom_left, (TILES_SIZE * 3, TILES_SIZE * 3 + TILES_SIZE // 2)
    )  # Tile 3,3
    # - Bottom edges
    new_image.paste(bottom_edge, (TILES_SIZE * 4, TILES_SIZE * 3))  # Tile 4,3
    new_image.paste(bottom_edge, (TILES_SIZE * 5, TILES_SIZE * 3))  # Tile 5,3
    new_image.paste(inner_top_left, (TILES_SIZE * 5, TILES_SIZE * 3))  # Tile 5,3
    new_image.paste(bottom_edge, (TILES_SIZE * 6, TILES_SIZE * 3))  # Tile 6,3
    new_image.paste(
        inner_top_right, (TILES_SIZE * 6 + TILES_SIZE // 2, TILES_SIZE * 3)
    )  # Tile 6,3
    new_image.paste(bottom_edge, (TILES_SIZE * 7, TILES_SIZE * 3))  # Tile 7,3
    new_image.paste(inner_top_left, (TILES_SIZE * 7, TILES_SIZE * 3))  # Tile 7,3
    new_image.paste(
        inner_top_right, (TILES_SIZE * 7 + TILES_SIZE // 2, TILES_SIZE * 3)
    )  # Tile 7,3
    # Corners and narrow paths
    corner_top_left = corner_tile.crop((0, 0, TILES_SIZE // 2, TILES_SIZE // 2))
    corner_top_right = corner_tile.crop(
        (TILES_SIZE // 2, 0, TILES_SIZE, TILES_SIZE // 2)
    )
    corner_bottom_left = corner_tile.crop(
        (0, TILES_SIZE // 2, TILES_SIZE // 2, TILES_SIZE)
    )
    corner_bottom_right = corner_tile.crop(
        (TILES_SIZE // 2, TILES_SIZE // 2, TILES_SIZE, TILES_SIZE)
    )

    new_image.paste(left_edge, (0, TILES_SIZE * 4))  # Tile 0,4
    new_image.paste(
        right_edge.crop((TILES_SIZE // 2, 0, TILES_SIZE, TILES_SIZE)),
        (TILES_SIZE // 2, TILES_SIZE * 4),
    )  # Tile 0,4
    new_image.paste(bottom_edge, (TILES_SIZE, TILES_SIZE * 4))  # Tile 1,4
    new_image.paste(
        top_edge.crop((0, 0, TILES_SIZE, TILES_SIZE // 2)), (TILES_SIZE, TILES_SIZE * 4)
    )  # Tile 1,4
    new_image.paste(
        image.crop((0, TILES_SIZE, TILES_SIZE, TILES_SIZE * 2)),
        (TILES_SIZE * 2, TILES_SIZE * 4),
    )  # Tile 2,4
    new_image.paste(
        image.crop((0, TILES_SIZE, TILES_SIZE, TILES_SIZE * 2)),
        (TILES_SIZE * 3, TILES_SIZE * 4),
    )  # Tile 3,4
    new_image.paste(
        inner_bottom_right,
        (TILES_SIZE * 3 + TILES_SIZE // 2, TILES_SIZE * 4 + TILES_SIZE // 2),
    )  # Tile 3,4
    new_image.paste(
        image.crop((TILES_SIZE * 2, TILES_SIZE, TILES_SIZE * 3, TILES_SIZE * 2)),
        (TILES_SIZE * 4, TILES_SIZE * 4),
    )  # Tile 4,4
    new_image.paste(
        image.crop((TILES_SIZE * 2, TILES_SIZE, TILES_SIZE * 3, TILES_SIZE * 2)),
        (TILES_SIZE * 5, TILES_SIZE * 4),
    )  # Tile 5,4
    new_image.paste(
        inner_bottom_left, (TILES_SIZE * 5, TILES_SIZE * 4 + TILES_SIZE // 2)
    )  # Tile 5,4
    new_image.paste(
        image.crop((TILES_SIZE * 2, TILES_SIZE * 3, TILES_SIZE * 3, TILES_SIZE * 4)),
        (TILES_SIZE * 6, TILES_SIZE * 4),
    )  # Tile 6,4
    new_image.paste(
        image.crop((TILES_SIZE * 2, TILES_SIZE * 3, TILES_SIZE * 3, TILES_SIZE * 4)),
        (TILES_SIZE * 7, TILES_SIZE * 4),
    )  # Tile 7,4
    new_image.paste(inner_top_left, (TILES_SIZE * 7, TILES_SIZE * 4))  # Tile 7,4
    new_image.paste(
        image.crop((0, TILES_SIZE * 3, TILES_SIZE, TILES_SIZE * 4)), (0, TILES_SIZE * 5)
    )  # Tile 0,5
    new_image.paste(
        image.crop((0, TILES_SIZE * 3, TILES_SIZE, TILES_SIZE * 4)),
        (TILES_SIZE, TILES_SIZE * 5),
    )  # Tile 1,5
    new_image.paste(
        inner_top_right, (TILES_SIZE + TILES_SIZE // 2, TILES_SIZE * 5)
    )  # Tile 1,5
    new_image.paste(
        new_image.crop((0, TILES_SIZE * 4, TILES_SIZE, TILES_SIZE * 5)),
        (TILES_SIZE * 2, TILES_SIZE * 5),
    )  # Tile 2,5
    new_image.paste(
        corner_tile.crop((0, 0, TILES_SIZE, TILES_SIZE // 2)),
        (TILES_SIZE * 2, TILES_SIZE * 5),
    )  # Tile 2,5
    new_image.paste(
        new_image.crop((TILES_SIZE, TILES_SIZE * 4, TILES_SIZE * 2, TILES_SIZE * 5)),
        (TILES_SIZE * 3, TILES_SIZE * 5),
    )  # Tile 3,5
    new_image.paste(
        corner_tile.crop((0, 0, TILES_SIZE // 2, TILES_SIZE)),
        (TILES_SIZE * 3, TILES_SIZE * 5),
    )  # Tile 3,5
    new_image.paste(
        new_image.crop((0, TILES_SIZE * 4, TILES_SIZE, TILES_SIZE * 5)),
        (TILES_SIZE * 4, TILES_SIZE * 5),
    )  # Tile 4,5
    new_image.paste(
        corner_tile.crop((0, TILES_SIZE // 2, TILES_SIZE, TILES_SIZE)),
        (TILES_SIZE * 4, TILES_SIZE * 5 + TILES_SIZE // 2),
    )  # Tile 4,5
    new_image.paste(
        new_image.crop((TILES_SIZE, TILES_SIZE * 4, TILES_SIZE * 2, TILES_SIZE * 5)),
        (TILES_SIZE * 5, TILES_SIZE * 5),
    )  # Tile 5,5
    new_image.paste(
        corner_tile.crop((TILES_SIZE // 2, 0, TILES_SIZE, TILES_SIZE)),
        (TILES_SIZE * 5 + TILES_SIZE // 2, TILES_SIZE * 5),
    )  # Tile 5,5
    new_image.paste(corner_tile, (TILES_SIZE * 6, TILES_SIZE * 5))  # Tile 6,5
    new_image.paste(
        image.crop((TILES_SIZE, 0, TILES_SIZE * 2, TILES_SIZE)),
        (TILES_SIZE * 7, TILES_SIZE * 5),
    )  # Tile 7,5

    return new_image


if __name__ == "__main__":
    output_folder: str = "ProcessedAutotiles"
    if not os.path.exists(output_folder):
        os.mkdir(output_folder)

    PATH: str = os.path.join("..", "Graphics", "Autotiles")
    print(os.walk(PATH))
    filenames = next(os.walk(PATH), (None, None, []))[2]
    for file in filenames:
        if file[-3:] != "png":
            continue
        image = Image.open(os.path.join(PATH, file))
        if image.size == (96, 128):
            split_autotile(image).save(os.path.join(output_folder, file))
