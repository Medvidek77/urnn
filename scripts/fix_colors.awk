#!/usr/bin/awk -f

# fix_colors.awk
# Takes a list of hex colors (e.g. #ff0000) and ensures exactly 10 colors are output,
# filling in missing ones by averaging them in CIELAB space if necessary.
# Usage: awk -f fix_colors.awk [args...]

function rgb_to_xyz(r, g, b,    r_lin, g_lin, b_lin, x, y, z) {
	r_lin = r / 255.0
	g_lin = g / 255.0
	b_lin = b / 255.0

	r_lin = (r_lin > 0.04045) ? (((r_lin + 0.055) / 1.055) ^ 2.4) : (r_lin / 12.92)
	g_lin = (g_lin > 0.04045) ? (((g_lin + 0.055) / 1.055) ^ 2.4) : (g_lin / 12.92)
	b_lin = (b_lin > 0.04045) ? (((b_lin + 0.055) / 1.055) ^ 2.4) : (b_lin / 12.92)

	x = r_lin * 0.4124 + g_lin * 0.3576 + b_lin * 0.1805
	y = r_lin * 0.2126 + g_lin * 0.7152 + b_lin * 0.0722
	z = r_lin * 0.0193 + g_lin * 0.1192 + b_lin * 0.9505

	return x " " y " " z
}

function fxyz(t) {
	return (t > 0.008856) ? (t ^ (1.0 / 3.0)) : (7.787 * t + 16.0 / 116.0)
}

function xyz_to_lab(x, y, z,    l, a, b) {
	# D65 white point
	l = 116.0 * fxyz(y / 1.0) - 16.0
	a = 500.0 * (fxyz(x / 0.9505) - fxyz(y / 1.0))
	b = 200.0 * (fxyz(y / 1.0) - fxyz(z / 1.0890))
	return l " " a " " b
}

function lab_to_xyz(l, a, b,    delta, fy, fx, fz, x, y, z) {
	delta = 6.0 / 29.0
	fy = (l + 16.0) / 116.0
	fx = fy + (a / 500.0)
	fz = fy - (b / 200.0)

	x = (fx > delta) ? (0.9505 * (fx ^ 3)) : ((fx - 16.0 / 116.0) * 3 * (delta ^ 2) * 0.9505)
	y = (fy > delta) ? (1.0 * (fy ^ 3)) : ((fy - 16.0 / 116.0) * 3 * (delta ^ 2) * 1.0)
	z = (fz > delta) ? (1.0890 * (fz ^ 3)) : ((fz - 16.0 / 116.0) * 3 * (delta ^ 2) * 1.0890)
	return x " " y " " z
}

function xyz_to_rgb(x, y, z,    r_lin, g_lin, b_lin, r, g, b) {
	r_lin = x * 3.2406 - y * 1.5372 - z * 0.4986
	g_lin = -x * 0.9689 + y * 1.8758 + z * 0.0415
	b_lin = x * 0.0557 - y * 0.2040 + z * 1.0570

	r_lin = (r_lin <= 0.0031308) ? (12.92 * r_lin) : (1.055 * (r_lin ^ (1.0 / 2.4)) - 0.055)
	g_lin = (g_lin <= 0.0031308) ? (12.92 * g_lin) : (1.055 * (g_lin ^ (1.0 / 2.4)) - 0.055)
	b_lin = (b_lin <= 0.0031308) ? (12.92 * b_lin) : (1.055 * (b_lin ^ (1.0 / 2.4)) - 0.055)

	if (r_lin < 0) r_lin = 0; if (r_lin > 1) r_lin = 1;
	if (g_lin < 0) g_lin = 0; if (g_lin > 1) g_lin = 1;
	if (b_lin < 0) b_lin = 0; if (b_lin > 1) b_lin = 1;

	r = int(r_lin * 255.0 + 0.5)
	g = int(g_lin * 255.0 + 0.5)
	b = int(b_lin * 255.0 + 0.5)

	return sprintf("%02x%02x%02x", r, g, b)
}

function hex_to_lab(hex,    r, g, b, xyz, xyz_arr, lab) {
	r = (index("0123456789abcdef", substr(tolower(hex), 1, 1)) - 1) * 16 + (index("0123456789abcdef", substr(tolower(hex), 2, 1)) - 1)
	g = (index("0123456789abcdef", substr(tolower(hex), 3, 1)) - 1) * 16 + (index("0123456789abcdef", substr(tolower(hex), 4, 1)) - 1)
	b = (index("0123456789abcdef", substr(tolower(hex), 5, 1)) - 1) * 16 + (index("0123456789abcdef", substr(tolower(hex), 6, 1)) - 1)
	xyz = rgb_to_xyz(r, g, b)
	split(xyz, xyz_arr, " ")
	lab = xyz_to_lab(xyz_arr[1], xyz_arr[2], xyz_arr[3])
	return lab
}

function lab_to_hex(l, a, b,    xyz, xyz_arr, rgb) {
	xyz = lab_to_xyz(l, a, b)
	split(xyz, xyz_arr, " ")
	rgb = xyz_to_rgb(xyz_arr[1], xyz_arr[2], xyz_arr[3])
	return rgb
}

BEGIN {
	n_colors = 0
	for (i = 1; i < ARGC; i++) {
		if (ARGV[i] != "") {
			n_colors++
			val = ARGV[i]
			if (substr(val, 1, 1) == "#") {
				val = substr(val, 2)
			}
			colors[n_colors] = tolower(val)
		}
	}

	if (n_colors == 0) {
		print "Usage: awk -f fix_colors.awk [colors...]" > "/dev/stderr"
		exit 1
	}

	if (n_colors > 10) {
		n_colors = 10
	} else if (n_colors < 10) {
		mid_l = 0; mid_a = 0; mid_b = 0
		for (i = 1; i <= n_colors; i++) {
			lab = hex_to_lab(colors[i])
			split(lab, lab_arr, " ")
			mid_l += lab_arr[1]
			mid_a += lab_arr[2]
			mid_b += lab_arr[3]
		}
		mid_l /= n_colors
		mid_a /= n_colors
		mid_b /= n_colors

		new_hex = lab_to_hex(mid_l, mid_a, mid_b)

		while (n_colors != 10) {
			n_colors++
			colors[n_colors] = new_hex
		}
	}

	# Sort the colors numerically by hex value
	for (i = 1; i <= n_colors; i++) {
		# bubble sort for simplicity (n is small)
		for (j = 1; j < n_colors; j++) {
			v1 = (index("0123456789abcdef", substr(tolower(colors[j]), 1, 1)) - 1) * 1048576 + (index("0123456789abcdef", substr(tolower(colors[j]), 2, 1)) - 1) * 65536 + (index("0123456789abcdef", substr(tolower(colors[j]), 3, 1)) - 1) * 4096 + (index("0123456789abcdef", substr(tolower(colors[j]), 4, 1)) - 1) * 256 + (index("0123456789abcdef", substr(tolower(colors[j]), 5, 1)) - 1) * 16 + (index("0123456789abcdef", substr(tolower(colors[j]), 6, 1)) - 1)
			v2 = (index("0123456789abcdef", substr(tolower(colors[j+1]), 1, 1)) - 1) * 1048576 + (index("0123456789abcdef", substr(tolower(colors[j+1]), 2, 1)) - 1) * 65536 + (index("0123456789abcdef", substr(tolower(colors[j+1]), 3, 1)) - 1) * 4096 + (index("0123456789abcdef", substr(tolower(colors[j+1]), 4, 1)) - 1) * 256 + (index("0123456789abcdef", substr(tolower(colors[j+1]), 5, 1)) - 1) * 16 + (index("0123456789abcdef", substr(tolower(colors[j+1]), 6, 1)) - 1)
			if (v1 > v2) {
				temp = colors[j]
				colors[j] = colors[j+1]
				colors[j+1] = temp
			}
		}
	}

	out = ""
	for (i = 1; i <= n_colors; i++) {
		out = out "#" colors[i] " "
	}
	printf "%s", out
}
