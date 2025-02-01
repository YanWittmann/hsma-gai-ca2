class_name TileMapLayerAccess
extends Node

var tilemap_types: TileMapTileTypes = TileMapTileTypes.new()
#
var tilemap: TileMapLayer = null
var sid: int              = 0


func setup() -> void:
    pass


func get_cells_by_type(
    atlas_coords: Vector2i,
    center: Vector2i = Vector2i(-1, -1), max_distance: int = 99999999,
    record: bool = true
) -> Array[Vector2i]:
    var tiles_with_type: Array[Vector2i] = tilemap.get_used_cells_by_id(sid, atlas_coords)
    if max_distance < 99999999:
        var filtered_tiles: Array[Vector2i] = []
        for tile in tiles_with_type:
            if TilemapNavigation.is_within_radius(center, tile, max_distance, record):
                filtered_tiles.append(tile)
        return filtered_tiles
    return tiles_with_type


const ANY_DISTANCE: int = 99999999


func get_cells_by_type_collection(
    atlas_coords: Array[Vector2i],
    center: Vector2i = Vector2i(-1, -1), max_distance: int = 99999999
) -> Array[Vector2i]:
    var tiles_with_type: Array[Vector2i] = []
    for coords in atlas_coords:
        tiles_with_type.append_array(get_cells_by_type(coords))
    if max_distance < 99999999:
        var filtered_tiles: Array[Vector2i] = []
        for tile in tiles_with_type:
            if TilemapNavigation.is_within_radius(center, tile, max_distance, true):
                filtered_tiles.append(tile)
        return filtered_tiles
    return tiles_with_type


func get_cells_by_custom_data(field_name: String, custom_data: Variant) -> Array[Vector2i]:
    var tiles_with_custom_data: Array = []
    for coords in tilemap.get_used_cells():
        var tile_data: TileData = tilemap.get_cell_tile_data(coords)
        if tile_data.get_custom_data(field_name) == custom_data:
            tiles_with_custom_data.append(coords)
    return tiles_with_custom_data


func get_custom_data(coords: Vector2i, field_name: String, default_value: Variant) -> Variant:
    var tile_data: TileData = tilemap.get_cell_tile_data(coords)
    if not tile_data:
        return default_value
    return tile_data.get_custom_data(field_name)


func get_cells(positions: Array[Vector2i]) -> Array[TileData]:
    var tiles: Array = []
    for coords in positions:
        tiles.append(tilemap.get_cell_tile_data(coords))
    return tiles


func get_cell(position: Vector2i) -> TileData:
    return tilemap.get_cell_tile_data(position)


func get_cell_atlas_coords(position: Vector2i) -> Vector2i:
    if not get_cell(position):
        return tilemap_types.NO_TILE_FOUND
    return tilemap.get_cell_atlas_coords(position)


func set_cell(position: Vector2i, atlas_coords: Vector2i) -> void:
    tilemap.set_cell(position, sid, atlas_coords)


func clear_cell(position: Vector2i) -> void:
    tilemap.set_cell(position, -1)


func clear_cells() -> void:
    for coords in tilemap.get_used_cells():
        tilemap.set_cell(coords, -1)


func local_to_cell(global_position: Vector2) -> Vector2i:
    return tilemap.local_to_map(global_position)


func cell_to_local(cell_position: Vector2i) -> Vector2:
    return tilemap.map_to_local(cell_position)


func fill_area(start: Vector2i, end: Vector2i, atlas_coords: Vector2i) -> void:
    for x in range(start.x, end.x + 1):
        for y in range(start.y, end.y + 1):
            tilemap.set_cell(Vector2i(x, y), sid, atlas_coords)


func fill_circle(center: Vector2i, radius: int, atlas_coords: Vector2i) -> void:
    for x in range(center.x - radius, center.x + radius + 1):
        for y in range(center.y - radius, center.y + radius + 1):
            if center.distance_to(Vector2i(x, y)) <= radius:
                tilemap.set_cell(Vector2i(x, y), sid, atlas_coords)


func fill_ellipse(center: Vector2i, radius_x: int, radius_y: int, atlas_coords: Vector2i) -> void:
    for x in range(center.x - radius_x, center.x + radius_x + 1):
        for y in range(center.y - radius_y, center.y + radius_y + 1):
            if (pow(x - center.x, 2) / pow(radius_x, 2) + pow(y - center.y, 2) / pow(radius_y, 2)) <= 1:
                tilemap.set_cell(Vector2i(x, y), sid, atlas_coords)


func get_cell_texture(coord: Vector2i) -> Texture:
    var source: TileSetAtlasSource = tilemap.tile_set.get_source(sid) as TileSetAtlasSource
    var rect: Rect2i               = source.get_tile_texture_region(coord)
    var image: Image               = source.texture.get_image()
    var tile_image: Image          = image.get_region(rect)
    return ImageTexture.create_from_image(tile_image)
