/*
 * returns a formatted string without the leading spaces
 * @param {Real} value the value to format
 * @param {Real} total the total digits to the left of the decimal
 * @param {Real} decimal_places the number of digits to the right of the decimal
 */
function string_format_trimmed(value, total, decimal_places) {
	return string_trim(string_format(value, total, decimal_places));
}

/**
 * pushes something to an array if that something doesnt already exist on the array
 * @param {Array} array the array to push to
 * @param {Any} value the value to push to the array
 */
function array_push_if(array, value) {
	var index = array_get_index(array, value);
	if (index == -1) {
		array_push(array, value);
		return array_length(array) - 1;
	}
	return index;
}

/**
 * pushes something to an ds list if that something doesnt already exist on the ds_list
 * @param {Id.DsList} ds_list the array to push to
 * @param {Any} value the value to push to the ds list
 */
function ds_list_add_if(ds_list, value) {
	var index = ds_list_find_index(ds_list, value);	
	if (index == -1) {
		ds_list_add(ds_list, value);
		return ds_list_size(ds_list) - 1;
	}
	return index;
}