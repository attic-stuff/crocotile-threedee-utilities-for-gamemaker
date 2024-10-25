/**
 * calculate flat normals for a threedee model
 * @param {Id.Buffer} raw_vbo_buffer the raw buffer of data for this model
 * @param {Id.VertexFormat} vertex_format the vertex format being used for this model
 * @param {Real} normals_attribute_number the index in the vertex format elements for the normals attribute
 */
function crocotile_threedee_calculate_flat_normals(raw_vbo_buffer, vertex_format, normals_attribute_number) {
	var raw_vbo_buffer_size = buffer_get_size(raw_vbo_buffer);
	var vertex_format_info = vertex_format_get_info(vertex_format);
	var vertex_format_stride = vertex_format_info.stride;
	var vertex_normals_offset = vertex_format_info.elements[normals_attribute_number].offset;
	var increment = vertex_format_stride * 3;
	buffer_seek(raw_vbo_buffer, buffer_seek_start, 0);
	for (var iteration = 0; iteration < raw_vbo_buffer_size; iteration += increment) {
		var vertex_a = vector_three_create_vector(
			buffer_peek(raw_vbo_buffer, iteration + 0 + 0,  buffer_f32),
			buffer_peek(raw_vbo_buffer, iteration + 0 + 4,  buffer_f32),
			buffer_peek(raw_vbo_buffer, iteration + 0 + 8,  buffer_f32)
		);
		
		var vertex_b = vector_three_create_vector(
			buffer_peek(raw_vbo_buffer, iteration + vertex_format_stride + 0,  buffer_f32),
			buffer_peek(raw_vbo_buffer, iteration + vertex_format_stride + 4,  buffer_f32),
			buffer_peek(raw_vbo_buffer, iteration + vertex_format_stride + 8,  buffer_f32)
		);
		
		var vertex_c = vector_three_create_vector(
			buffer_peek(raw_vbo_buffer, iteration + (2 * vertex_format_stride) + 0,  buffer_f32),
			buffer_peek(raw_vbo_buffer, iteration + (2 * vertex_format_stride) + 4,  buffer_f32),
			buffer_peek(raw_vbo_buffer, iteration + (2 * vertex_format_stride) + 8,  buffer_f32)
		);
		
		var component_a = vector_three_math_subtraction(vertex_b, vertex_a);
		var component_b = vector_three_math_subtraction(vertex_c, vertex_a);
		var cross_product = vector_three_math_crossproduct(component_a, component_b);
		var vertex_normals = vector_three_math_normalize(cross_product);
		
		buffer_poke(raw_vbo_buffer, iteration + vertex_normals_offset + 0,  buffer_f32, vertex_normals. X);
		buffer_poke(raw_vbo_buffer, iteration + vertex_normals_offset + 4,  buffer_f32, vertex_normals. Y);
		buffer_poke(raw_vbo_buffer, iteration + vertex_normals_offset + 8,  buffer_f32, vertex_normals. Z);

		buffer_poke(raw_vbo_buffer, iteration + vertex_format_stride + vertex_normals_offset + 0,  buffer_f32, vertex_normals. X);
		buffer_poke(raw_vbo_buffer, iteration + vertex_format_stride + vertex_normals_offset + 4,  buffer_f32, vertex_normals. Y);
		buffer_poke(raw_vbo_buffer, iteration + vertex_format_stride + vertex_normals_offset + 8,  buffer_f32, vertex_normals. Z);

		buffer_poke(raw_vbo_buffer, iteration + (2 * vertex_format_stride) + vertex_normals_offset + 0,  buffer_f32, vertex_normals. X);
		buffer_poke(raw_vbo_buffer, iteration + (2 * vertex_format_stride) + vertex_normals_offset + 4,  buffer_f32, vertex_normals. Y);
		buffer_poke(raw_vbo_buffer, iteration + (2 * vertex_format_stride) + vertex_normals_offset + 8,  buffer_f32, vertex_normals. Z);
		
	}
}

/**
 * reverse the vertex order for a threedee model
 * @param {Id.Buffer} raw_vbo_buffer the raw buffer of data for this model
 * @param {Id.VertexFormat} vertex_format the vertex format being used for this model
 */
function crocotile_threedee_reverse_vertex_order(raw_vbo_buffer, vertex_format) {
	var vertex_stride = vertex_format_get_info(vertex_format).stride;
	var raw_vbo_buffer_size = buffer_get_size(raw_vbo_buffer);
	var new_raw_vbo_buffer = buffer_create(raw_vbo_buffer_size, buffer_fixed, 1);
	buffer_seek(raw_vbo_buffer, buffer_seek_start, 0);
	var head_position = 1;
	while (buffer_tell(raw_vbo_buffer) < raw_vbo_buffer_size) {
		buffer_seek(new_raw_vbo_buffer, buffer_seek_start, raw_vbo_buffer_size - (head_position * vertex_stride));	
		buffer_write(new_raw_vbo_buffer, buffer_f32, buffer_read(raw_vbo_buffer, buffer_f32));
		buffer_write(new_raw_vbo_buffer, buffer_f32, buffer_read(raw_vbo_buffer, buffer_f32));
		buffer_write(new_raw_vbo_buffer, buffer_f32, buffer_read(raw_vbo_buffer, buffer_f32));
		buffer_write(new_raw_vbo_buffer, buffer_f32, buffer_read(raw_vbo_buffer, buffer_f32));
		buffer_write(new_raw_vbo_buffer, buffer_f32, buffer_read(raw_vbo_buffer, buffer_f32));
		buffer_write(new_raw_vbo_buffer, buffer_f32, buffer_read(raw_vbo_buffer, buffer_f32));
		buffer_write(new_raw_vbo_buffer, buffer_u32, buffer_read(raw_vbo_buffer, buffer_u32));
		buffer_write(new_raw_vbo_buffer, buffer_f32, buffer_read(raw_vbo_buffer, buffer_f32));
		buffer_write(new_raw_vbo_buffer, buffer_f32, buffer_read(raw_vbo_buffer, buffer_f32));
		head_position += 1;
	}
	buffer_copy(new_raw_vbo_buffer, 0, raw_vbo_buffer_size, raw_vbo_buffer,  0);
	buffer_delete(new_raw_vbo_buffer);
}

/**
 * undoes the transform used to correct a model for +z up use!
 * @param {Id.Buffer} raw_vbo_buffer the raw buffer of data for this model
 * @param {Id.VertexFormat} vertex_format the vertex format being used for this model
 */
function crocotile_threedee_uncorrect_from_plus_z_up(raw_vbo_buffer, vertex_format) {
	static uncorrect_transform = matrix_multiply(
		matrix_build(0, 0, 0, 0, 0, 0, 1, 1, -1),
		matrix_build(0, 0, 0, -90, 0, 0, 1, 1, 1)
	);
	buffer_seek(raw_vbo_buffer, buffer_seek_start, 0);
	var raw_vbo_buffer_size = buffer_get_size(raw_vbo_buffer);
	var vertex_stride = vertex_format_get_info(vertex_format).stride;
	for (var iteration = 0; iteration < raw_vbo_buffer_size; iteration += vertex_stride) {		
		var x_position = buffer_peek(raw_vbo_buffer, iteration + 0, buffer_f32);
		var y_position = buffer_peek(raw_vbo_buffer, iteration + 4, buffer_f32);
		var z_position = buffer_peek(raw_vbo_buffer, iteration + 8, buffer_f32);
		var v_texcoord = buffer_peek(raw_vbo_buffer, iteration + 32, buffer_f32);
		var transform = matrix_transform_vertex(uncorrect_transform, x_position, y_position, z_position);		
		buffer_poke(raw_vbo_buffer, iteration + 0, buffer_f32, transform[0]);
		buffer_poke(raw_vbo_buffer, iteration + 4, buffer_f32, transform[1]);
		buffer_poke(raw_vbo_buffer, iteration + 8, buffer_f32, transform[2]);
		buffer_poke(raw_vbo_buffer, iteration + 32, buffer_f32, 1 - v_texcoord);
	}
	crocotile_threedee_reverse_vertex_order(raw_vbo_buffer, vertex_format);
}

/**
 * writes a raw buffer of vbo data to an obj file
 * @param {Id.Buffer} raw_vbo_buffer the raw buffer of data for this model
 * @param {String} obj_name the name attribute for this obj, also used as the filename
 * @param {String} [material_name] the name attribute for this obj's material file
 */
function crocotile_threedee_write_buffer_to_obj_file(raw_vbo_buffer, obj_name, material_name = "0") {
	static read_vertex = function(raw_buffer) {	
		var x_position = buffer_read(raw_buffer, buffer_f32);
		var y_position = buffer_read(raw_buffer, buffer_f32);
		var z_position = buffer_read(raw_buffer, buffer_f32);
		var x_normal = buffer_read(raw_buffer, buffer_f32);
		var y_normal = buffer_read(raw_buffer, buffer_f32);
		var z_normal = buffer_read(raw_buffer, buffer_f32);
		var r_color = buffer_read(raw_buffer, buffer_u8) / 255;
		var g_color = buffer_read(raw_buffer, buffer_u8) / 255;
		var b_color = buffer_read(raw_buffer, buffer_u8) / 255;
		var a_color = ((buffer_read(raw_buffer, buffer_u8) / 255) * 100) / 100;
		var u_texture = buffer_read(raw_buffer, buffer_f32);
		var v_texture = buffer_read(raw_buffer, buffer_f32);
		
		var v = $"v {string_format_trimmed(x_position, 20, 20)} {string_format_trimmed(y_position, 20, 20)} {string_format_trimmed(z_position, 20, 20)} {string_format(r_color, 1, 20)} {string_format(g_color, 1, 20)} {string_format(b_color, 1, 20)} {string_format(a_color, 1, 20)}";
		var vt = $"vt {string_format(u_texture, 1, 20)} {string_format(v_texture, 1, 20)}";
		var vn = $"vn {string_format(x_normal, 1, 20)} {string_format(y_normal, 1, 20)} {string_format(z_normal, 1, 20)}";
		return { v, vt, vn };
	}
	
	var vertex_positions = ds_list_create();
	var vertex_texture_coordinates = ds_list_create();
	var vertex_normals = ds_list_create();
	var triangle_faces = ds_list_create();
	
	var raw_vbo_buffer_size = buffer_get_size(raw_vbo_buffer);
	buffer_seek(raw_vbo_buffer, buffer_seek_start, 0);
	
	while (buffer_tell(raw_vbo_buffer) < raw_vbo_buffer_size) {
		
		var tell = buffer_tell(raw_vbo_buffer);
		
		var point_a = read_vertex(raw_vbo_buffer);
		var point_b = read_vertex(raw_vbo_buffer);
		var point_c = read_vertex(raw_vbo_buffer);	
	
		var point_a_vertex_positions_index = int64(ds_list_add_if(vertex_positions, point_a.v) + 1);
		var point_b_vertex_positions_index = int64(ds_list_add_if(vertex_positions, point_b.v) + 1);
		var point_c_vertex_positions_index = int64(ds_list_add_if(vertex_positions, point_c.v) + 1);		
	
		var point_a_vertex_texture_coordinates_index = int64(ds_list_add_if(vertex_texture_coordinates, point_a.vt) + 1);
		var point_b_vertex_texture_coordinates_index = int64(ds_list_add_if(vertex_texture_coordinates, point_b.vt) + 1);
		var point_c_vertex_texture_coordinates_index = int64(ds_list_add_if(vertex_texture_coordinates, point_c.vt) + 1);
	
		var point_a_vertex_normals_index = int64(ds_list_add_if(vertex_normals, point_a.vn) + 1);
		var point_b_vertex_normals_index = int64(ds_list_add_if(vertex_normals, point_b.vn) + 1);
		var point_c_vertex_normals_index = int64(ds_list_add_if(vertex_normals, point_c.vn) + 1);	
	
		var f = "f "
		f += $"{point_a_vertex_positions_index}/{point_a_vertex_texture_coordinates_index}/{point_a_vertex_normals_index} ";
		f += $"{point_b_vertex_positions_index}/{point_b_vertex_texture_coordinates_index}/{point_b_vertex_normals_index} ";
		f += $"{point_c_vertex_positions_index}/{point_c_vertex_texture_coordinates_index}/{point_c_vertex_normals_index}";
		ds_list_add(triangle_faces, f);
	}
	
	var obj_file = buffer_create(1, buffer_grow, 1);
	buffer_write(obj_file, buffer_text, $"o Default\n");
	
	var list_length = 0;
	
	list_length = ds_list_size(vertex_positions);
	for (var index = 0; index < list_length; index += 1) {
		buffer_write(obj_file, buffer_text, vertex_positions[| index] + "\n");	
	}
	
	list_length = ds_list_size(vertex_texture_coordinates);
	for (var index = 0; index < list_length; index += 1) {
		buffer_write(obj_file, buffer_text, vertex_texture_coordinates[| index] + "\n");	
	}
	
	list_length = ds_list_size(vertex_normals);
	for (var index = 0; index < list_length; index += 1) {
		buffer_write(obj_file, buffer_text, vertex_normals[| index] + "\n");
	}
	
	buffer_write(obj_file, buffer_text, $"g {obj_name}\nusemtl {materials_name}\n");

	list_length = ds_list_size(triangle_faces);
	for (var index = 0; index < list_length; index += 1) {
		buffer_write(obj_file, buffer_text, triangle_faces[| index] + "\n");
	}
	
	buffer_save(obj_file, $"{obj_name}.obj");
	
	buffer_delete(obj_file);
	
	ds_list_destroy(vertex_positions);
	ds_list_destroy(vertex_texture_coordinates);
	ds_list_destroy(vertex_normals);
	ds_list_destroy(triangle_faces);
	
	return true;
}

/**
 * converts an obj file from crocotile into a raw buffer
 * @param {String} file_name the file name, including path, to convert
 * @param {Function} [callback] a function to operate on the collection of obj data if you do not want a regular buffer
 */
function crocotile_threedee_parse_obj_file(file_name, callback = crocotile_threedee_default_obj_parsing_callback)  {
	
	static split_up_triangle_faces = function(triangle_face_collection) {
		var collection = string_split(triangle_face_collection, "/");
		array_foreach(collection, method({collection}, function(value,  index) {
			collection[index] = real(value) - 1;
		}));
		return collection;
	}
	
	var vertex_positions = [];
	var vertex_normals = [];
	var vertex_colors = [];
	var vertex_texture_coords = [];
	var triangle_faces = [];
	
	var obj_file = file_text_open_read(file_name);
	
	while (file_text_eof(obj_file) == false) {
		var this_line = file_text_readln(obj_file);
		var data_collection = string_split(this_line, " ");
		
		if (data_collection[0] ==  "v" or data_collection[0] == "vt" or data_collection[0] =="vn") {
			array_foreach(data_collection, method({data_collection}, function(value, index) {
				if (index > 0) {
					data_collection[index] = real(value);	
				}
			}));
		}
		if (data_collection[0] == "v") {
			array_push(vertex_positions, vector_three_create_vector(data_collection[1], data_collection[2], data_collection[3]));
			array_push(vertex_colors, crocotile_threedee_create_color(data_collection[4], data_collection[5], data_collection[6], data_collection[7]));
		}
		
		if (data_collection[0] == "vt") {
			array_push(vertex_texture_coords, vector_three_create_vector(data_collection[1], data_collection[2], -1));	
		}			
	
		if (data_collection[0] ==  "vn") {
			array_push(vertex_normals, vector_three_create_vector(data_collection[1], data_collection[2], data_collection[3]));
		}
		
		if (data_collection[0] == "f") {
			var point_a = split_up_triangle_faces(data_collection[1]);	
			var point_b = split_up_triangle_faces(data_collection[2]);
			var point_c = split_up_triangle_faces(data_collection[3]);
			array_push(triangle_faces, point_a, point_b, point_c);
		}
	}
	file_text_close(obj_file);
	return callback(vertex_positions, vertex_normals, vertex_colors, vertex_texture_coords, triangle_faces);
}

/**
 * the default callback method for parsing crocotile3d obj files. returns a raw buffer of data
 * @param {Array<Struct>} vertex_positions the array of each vertex position
 * @param {Array<Struct>} vertex_normals the array of each vertex normal
 * @param {Array<Struct>} vertex_colors the array of each vertex color
 * @param {Array<Struct>} vertex_texture_coords the array of texture uvs
 * @param {Array<Array<String>>} triangle_faces the array of triangle faces
 * @returns {Id.Buffer}
 */
function crocotile_threedee_default_obj_parsing_callback(vertex_positions, vertex_normals, vertex_colors, vertex_texture_coords, triangle_faces) {
	var number_of_vertices = array_length(triangle_faces);
	var raw_vbo_buffer_size = vertex_format_get_info(crocotile_threedee_default_format).stride * number_of_vertices;
	var raw_vbo_buffer = buffer_create(raw_vbo_buffer_size, buffer_fixed, 1);
	for (var iteration = 0; iteration < number_of_vertices; iteration += 1) {
		var this_vertex = triangle_faces[iteration];
		var position_attribute = vertex_positions[this_vertex[0]];
		var normals_attribute = vertex_normals[this_vertex[2]];
		var colors_attribute = vertex_colors[this_vertex[0]];
		var texture_coordinate_attribute = vertex_texture_coords[this_vertex[1]];
		
		buffer_write(raw_vbo_buffer, buffer_f32, position_attribute. X);
		buffer_write(raw_vbo_buffer, buffer_f32, position_attribute. Y);
		buffer_write(raw_vbo_buffer, buffer_f32, position_attribute. Z);
		
		buffer_write(raw_vbo_buffer, buffer_f32, normals_attribute. X);
		buffer_write(raw_vbo_buffer, buffer_f32, normals_attribute. Y);
		buffer_write(raw_vbo_buffer, buffer_f32, normals_attribute. Z);
		
		var u32_color = colors_attribute.R + (colors_attribute.G << 8) + (colors_attribute.B << 16) + (colors_attribute.A << 24);
		buffer_write(raw_vbo_buffer, buffer_u32, u32_color);
		
		buffer_write(raw_vbo_buffer, buffer_f32, texture_coordinate_attribute. X);
		buffer_write(raw_vbo_buffer, buffer_f32, texture_coordinate_attribute. Y);	
	}
	buffer_seek(raw_vbo_buffer, buffer_seek_start, 0);
	return raw_vbo_buffer;	
}

/**
 * utility function used only for parsing crocotile objs
 * @param {Real} red red component
 * @param {Real} green green component
 * @param {Real} blue blue component
 * @param {Real} alpha alpha component
 */
function crocotile_threedee_create_color(red, green, blue, alpha) {
	var R = red * 255;
	var G = green * 255;
	var B = blue * 255;
	var A = ((alpha * 100) / 100) * 255;
	return { R, G, B, A };
}

/**
 * corrects a crocotile model to conform to a +zup camera!
 * @param {Id.Buffer} raw_vbo_buffer the raw buffer of data for this model
 * @param {Id.VertexFormat} vertex_format the vertex format being used for this model
 */
function crocotile_threedee_correct_to_plus_z_up(raw_vbo_buffer, vertex_format) {
	static correct_transform = matrix_multiply(
		matrix_build(0, 0, 0, 90, 0, 0, 1, 1, 1),
		matrix_build(0, 0, 0, 0, 0, 0, 1, 1, -1)
	);
	buffer_seek(raw_vbo_buffer, buffer_seek_start, 0);
	var raw_vbo_buffer_size = buffer_get_size(raw_vbo_buffer);
	var vertex_stride = vertex_format_get_info(vertex_format).stride;
	for (var iteration = 0; iteration < raw_vbo_buffer_size; iteration += vertex_stride) {		
		var x_position = buffer_peek(raw_vbo_buffer, iteration + 0, buffer_f32);
		var y_position = buffer_peek(raw_vbo_buffer, iteration + 4, buffer_f32);
		var z_position = buffer_peek(raw_vbo_buffer, iteration + 8, buffer_f32);
		var v_texcoord = buffer_peek(raw_vbo_buffer, iteration + 32, buffer_f32);
		var transform = matrix_transform_vertex(correct_transform, x_position, y_position, z_position);		
		buffer_poke(raw_vbo_buffer, iteration + 0, buffer_f32, transform[0]);
		buffer_poke(raw_vbo_buffer, iteration + 4, buffer_f32, transform[1]);
		buffer_poke(raw_vbo_buffer, iteration + 8, buffer_f32, transform[2]);
		buffer_poke(raw_vbo_buffer, iteration + 32, buffer_f32, 1 - v_texcoord);
	}
	crocotile_threedee_reverse_vertex_order(raw_vbo_buffer, vertex_format);
}
	
#macro crocotile_threedee_default_format global.vertexformatdefaultthreedeeforcrocotile
vertex_format_begin() {
	vertex_format_add_position_3d();
	vertex_format_add_normal();
	vertex_format_add_color();
	vertex_format_add_texcoord();
	crocotile_threedee_default_format = vertex_format_end();
}