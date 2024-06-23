/* window setup */
window_set_size(512, 512);
surface_resize(application_surface, 512, 512);

/* threedee camera doo dads */
view_matrix = matrix_build_lookat(64, 64, 48, 0, 0, 0, 0, 0, 1);
projection_matrix = matrix_build_projection_perspective_fov(-60, -512/512, 1, 512);
identity_matrix = matrix_build_identity();
threedee_camera = camera_create();
camera_set_view_mat(threedee_camera, view_matrix);
camera_set_proj_mat(threedee_camera, projection_matrix);
gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);
gpu_set_cullmode(cull_counterclockwise);

/* load a model! */
if (file_exists("viewcube.obj") == true and file_exists("texture_1.png") == true) {
	var raw_kyle = crocotile_threedee_parse_obj_file("viewcube.obj");
	crocotile_threedee_correct_to_plus_z_up(raw_kyle, crocotile_threedee_default_format);
	crocotile_threedee_calculate_flat_normals(raw_kyle, crocotile_threedee_default_format, 1)
	kyle_vbo = vertex_create_buffer_from_buffer(raw_kyle, crocotile_threedee_default_format);
	buffer_delete(raw_kyle);
	kyle_sprite = sprite_add("texture_1.png", 0, false, false, 0, 0);
	kyle_texture_pointer = sprite_get_texture(kyle_sprite, 0);
} else {
	show_message("no model or texture found in included files. bailing!");
	game_end();
}

/* rotate a model */
z_rotation = 0;