#macro X x
#macro Y y
#macro Z depth

function vector_three_create_vector(X, Y, Z) {
	gml_pragma("forceinline");
	return { X, Y, Z };
}

function vector_three_math_subtraction(a, b) {
	gml_pragma("forceinline");
	return {
		X : a. X - b. X,
		Y : a. Y - b. Y,
		Z : a. Z - b. Z
	}
}

function vector_three_math_crossproduct(a, b) {
	gml_pragma("forceinline");	
	return {
		X : a. Y * b. Z - b. Y * a. Z,
		Y : a. Z * b. X - b. Z * a. X,
		Z : a. X * b. Y - b. X * a. Y
	}
}

function vector_three_math_normalize(a) {
	gml_pragma("forceinline");
	var length = sqrt(a. X * a. X + a. Y * a. Y + a. Z * a. Z);
	if (length <= 0) {
		return a;	
	}
	var normal = 1 / length;
	return {
		X : a. X * normal,
		Y : a. Y * normal,
		Z : a. Z * normal
	}
}

function vector_three_math_transform(a, mat) {
	gml_pragma("forceinline");
	var transform = matrix_transform_vertex(mat, a. X,  a. Y,  a. Z);
	with (a) {
		X = transform[0];
		Y = transform[1];
		Z = transform[2];
	}	
	return a;
}