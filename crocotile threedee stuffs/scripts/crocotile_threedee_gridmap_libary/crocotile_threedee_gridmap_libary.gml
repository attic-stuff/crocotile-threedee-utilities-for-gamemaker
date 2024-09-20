/**
 * parent container of data for crocotile gridmaps
 * @param {Struct} gridmap_json_object the json gridmap from croc
 * @param {Real} one_meter the number of pixels equal to one meter, as set in crocotile
 * @param {Real} z_direction which direction your upvector goes on z, 1 or -1
 */
function crocotile_threedee_grid_map(grid_map_json_object, one_meter, z_direction) constructor {
	
	self.tile_size_x = grid_map_json_object.size.x * one_meter;
	self.tile_size_y = grid_map_json_object.size.y * one_meter;
	self.tile_size_z = grid_map_json_object.size.z * one_meter;	
	self.dimension_on_x = grid_map_json_object.dimensions.x;
	self.dimension_on_y = grid_map_json_object.dimensions.z;
	self.dimension_on_z = grid_map_json_object.dimensions.y;
	self.z_direction = z_direction;
	self.world_position_container = { x : 0, y : 0, z: 0 };
}

/**
 * container of data for crocotile gridmap, arranged in a list format, where each 
 * @param {Struct} gridmap_json_object the json gridmap from croc
 * @param {Real} one_meter the number of pixels equal to one meter, as set in crocotile
 * @param {Real} z_direction which direction your upvector goes on z, 1 or -1
 */
function crocotile_threedee_grid_map_list(grid_map_json_object, one_meter, z_direction) : crocotile_threedee_grid_map(grid_map_json_object, one_meter, z_direction) constructor {	
	self.tile_list = array_create(self.dimension_on_x * self.dimension_on_y * self.dimension_on_z);
	array_foreach(grid_map_json_object.cells, function(value, index) {
		self.tile_list[index] = {
			tile_cell_x : value[0],
			tile_cell_y : value[2],
			tile_cell_z : value[1],
			tile_cell_index : value[3]
		}
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
function crocotile_threedee_grid_map_grid(grid_map_json_object, one_meter, z_direction) : crocotile_threedee_grid_map(grid_map_json_object, one_meter, z_direction) constructor {	
	self.offset_on_x = grid_map_json_object.min.x * -1;
	self.offset_on_y = grid_map_json_object.min.z * -1;
	self.offset_on_z = grid_map_json_object.min.y * -1;
	self.tile_grid = array_create(self.dimension_on_x);
	for (var one = 0; one < self.dimension_on_x; one += 1) {
		self.tile_grid[one] = array_create(self.dimension_on_y);
		for (var two = 0; two < self.dimension_on_y; two += 1) {
			self.tile_grid[one][two] = array_create(self.dimension_on_z);
		}
	}
	array_foreach(grid_map_json_object.cells, function(value, index) {
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
 * @param {Real} z_direction which direction your upvector goes on z, 1 or -1
 */
function crocotile_threedee_parse_grid_map_file_z_up(file_name, one_meter = 16, as_list = true, z_direction = 1) {
	var grid_map_file = buffer_load(file_name);
	var grid_map_text = buffer_read(grid_map_file, buffer_text);
	var grid_map_json_object = json_parse(grid_map_text);
	buffer_delete(grid_map_file);
	var grid_map_object = undefined;
	if (as_list == true) {
		grid_map_object = new crocotile_threedee_grid_map_list(grid_map_json_object, one_meter, z_direction);
	} else {
		grid_map_object = new crocotile_threedee_grid_map_grid(grid_map_json_object, one_meter, z_direction);
	}
	return grid_map_object;
}