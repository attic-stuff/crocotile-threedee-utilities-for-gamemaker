/**
 * parent container of data for crocotile gridmaps
 * @param {Struct} gridmap_json_object the json gridmap from croc
 * @param {Real} one_meter the number of pixels equal to one meter, as set in crocotile
 * @param {Real} z_direction which direction your upvector goes on z, 1 or -1
 */
function crocotile_threedee_gridmap(gridmap_json_object, one_meter, z_direction) constructor {
	
	self.tile_size_x = gridmap_json_object.size.x * one_meter;
	self.tile_size_y = gridmap_json_object.size.y * one_meter;
	self.tile_size_z = gridmap_json_object.size.z * one_meter;	
	self.dimension_on_x = gridmap_json_object.dimensions.x;
	self.dimension_on_y = gridmap_json_object.dimensions.z;
	self.dimension_on_z = gridmap_json_object.dimensions.y;
	self.z_direction = z_direction;
	self.world_position_container = { x : 0, y : 0, z: 0 };
}

/**
 * container of data for crocotile gridmap, arranged in a list format, where each 
 * @param {Struct} gridmap_json_object the json gridmap from croc
 * @param {Real} one_meter the number of pixels equal to one meter, as set in crocotile
 * @param {Real} z_direction which direction your upvector goes on z, 1 or -1
 */
function crocotile_threedee_gridmap_list(gridmap_json_object, one_meter, z_direction) : crocotile_threedee_gridmap(gridmap_json_object, one_meter, z_direction) constructor {	
	self.tile_list = [];
	array_foreach(gridmap_json_object.cells, function(value, index) {
		array_push(self.tile_list,  {
			tile_cell_x : value[0],
			tile_cell_y : value[2],
			tile_cell_z : value[1],
			tile_cell_index : value[3]
		})
	});
	static extract_world_position = function(tile_data_index) {
		self.world_position_container.x = self.tile_list[tile_data_index].tile_cell_x * self.tile_size_x;
		self.world_position_container.y = self.tile_list[tile_data_index].tile_cell_y * self.tile_size_y;
		self.world_position_container.z = self.tile_list[tile_data_index].tile_cell_z * self.tile_size_z * self.z_direction;
		return self.world_position_container;
	}
}

/**
 * container of data for crocotile gridmap, arranged in a grid[x][[y][z] format
 * @param {Struct} gridmap_json_object the json gridmap from croc
 * @param {Real} one_meter the number of pixels equal to one meter, as set in crocotile
 * @param {Real} z_direction which direction your upvector goes on z, 1 or -1
 */
function crocotile_threedee_gridmap_grid(gridmap_json_object, one_meter, z_direction) : crocotile_threedee_gridmap(gridmap_json_object, one_meter, z_direction) constructor {	
	self.offset_on_x = gridmap_json_object.min.x * -1;
	self.offset_on_y = gridmap_json_object.min.z * -1;
	self.offset_on_z = gridmap_json_object.min.y * -1;
	self.tile_grid = array_create(self.dimension_on_x);
	for (var one = 0; one < self.dimension_on_x; one += 1) {
		self.tile_grid[one] = array_create(self.dimension_on_y);
		for (var two = 0; two < self.dimension_on_y; two += 1) {
			self.tile_grid[one][two] = array_create(self.dimension_on_z);
		}
	}
	array_foreach(gridmap_json_object.cells, function(value, index) {
		var tile_cell_x = value[0] + self.offset_on_x;
		var tile_cell_y = value[2] + self.offset_on_y;
		var tile_cell_z = value[1] + self.offset_on_z;
		self.tile_grid[tile_cell_x][tile_cell_y][tile_cell_z] = value[3];
	});
	static extract_world_position = function(tile_cell_x, tile_cell_y, tile_cell_z) {
		self.world_position_container.x = (tile_cell_x - self.offset_on_x) * self.tile_size_x;
		self.world_position_container.y = (tile_cell_y - self.offset_on_y) * self.tile_size_y;
		self.world_position_container.z = (tile_cell_z - self.offset_on_z) * self.tile_size_z * z_direction;
		return self.world_position_container;
	}
	
}

/**
 * create a container of data for crocotile gridmap
 * @param {String} file_name the name of the text file containing the gridmap
 * @param {Real} one_meter the number of pixels equal to one meter, as set in crocotile
 * @param {Bool} as_list whether or not to return the data as a list or a grid
 */
function crocotile_threedee_parse_gridmap_file_z_up(file_name, one_meter = 16, as_list = true) {
	var gridmap_file = buffer_load(file_name);
	var gridmap_text = buffer_read(gridmap_file, buffer_text);
	var gridmap_json_object = json_parse(gridmap_text);
	buffer_delete(gridmap_file);
	var gridmap_object = undefined;
	if (as_list == true) {
		gridmap_object = new crocotile_threedee_gridmap_list(gridmap_json_object, one_meter, 1);
	} else {
		gridmap_object = new crocotile_threedee_gridmap_grid(gridmap_json_object, one_meter, 1);
	}
	return gridmap_object;
}

/**
 * creates a stack of tilemaps for gridmap data
 * @param {Struct.crocotile_threedee_gridmap_list} gridmap_object the list type gridmap object to use
 * @param {Asset.GMTileSet} tile_set the tilset used for the tilemaps
 */
function crocotile_threedee_create_tilemap_stack_from_list(gridmap_object, tile_set) {
	var tilemap_stack = array_create_ext(gridmap_object.dimension_on_z, method({tile_set, gridmap_object}, function(index) {
	var layer_identity = layer_create(index * gridmap_object.tile_size_z);
	var tilemap_identity = layer_tilemap_create(layer_identity, 0, 0, tile_set, gridmap_object.dimension_on_x, gridmap_object.dimension_on_y);
		return { layer_identity, tilemap_identity };
	}));
	return tilemap_stack;
}

/**
 * fills tilemaps with tiles from the gridmap
 * @param {Struct.crocotile_threedee_gridmap_list} gridmap_object the list type gridmap object to use
 * @param {Array} tilemap_stack the stack of tilemaps
 * @param {Real} [offset_on_x] optional tilemap offset
 * @param {Real} [offset_on_y] optional tilemap offset
 */
function crocotile_threedee_populate_tilemap_stack_from_list(gridmap_object, tilemap_stack, offset_on_x = 0, offset_on_y = 0) {
	var enclosure = { tilemap_stack, offset_on_x, offset_on_y, gridmap_object }
	array_foreach(gridmap_object.tile_list, method(enclosure, function(this_tile, index) {
		var this_tilemap = tilemap_stack[this_tile.tile_cell_z].tilemap_identity;
		var old_tilemap_width = tilemap_get_width(this_tilemap);
		var old_tilemap_height = tilemap_get_height(this_tilemap);
		var new_tilemap_width = offset_on_x + gridmap_object.dimension_on_x;
		var new_tilemap_height = offset_on_y + gridmap_object.dimension_on_y;
		if (old_tilemap_width < new_tilemap_width) {
			tilemap_set_width(this_tilemap, new_tilemap_width);	
		}
		if (old_tilemap_height < new_tilemap_height) {
			tilemap_set_height(this_tilemap, new_tilemap_height);	
		}
		tilemap_set(this_tilemap, this_tile.tile_cell_index, offset_on_x + this_tile.tile_cell_x, offset_on_y + this_tile.tile_cell_y);
	}));
}