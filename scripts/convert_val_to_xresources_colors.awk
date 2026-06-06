#!/usr/bin/awk -f

# convert_val_to_xresources_colors.awk
# Usage: awk -v ratio=1 [-v show_name=1] -f convert_val_to_xresources_colors.awk [file]

BEGIN {
	if (ratio == "") {
		print "Usage: awk -v ratio=1 [-v show_name=1] -f convert_val_to_xresources_colors.awk [file]" > "/dev/stderr"
		exit 1
	}
	colors[0] = "background"
	colors[1] = "foreground"
	for (i = 0; i < 16; i++) {
		colors[2+i] = "color" i
	}
	col_index = 0
}

{
	red = $1
	green = $2
	blue = $3

	r_val = -(( -red - ratio ) * 255 / (2.0 * ratio))
	g_val = -(( -green - ratio ) * 255 / (2.0 * ratio))
	b_val = -(( -blue - ratio ) * 255 / (2.0 * ratio))

	if (r_val < 0) r_val = 0; if (r_val > 255) r_val = 255;
	if (g_val < 0) g_val = 0; if (g_val > 255) g_val = 255;
	if (b_val < 0) b_val = 0; if (b_val > 255) b_val = 255;

	hexcode = sprintf("#%02x%02x%02x", r_val, g_val, b_val)

	if (show_name) {
		print "*" colors[col_index] ": " hexcode
	} else {
		print hexcode
	}
	col_index++
}
