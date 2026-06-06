#!/usr/bin/awk -f

# convert_hex_to_val.awk
# Usage: awk -v ratio=1 -f convert_hex_to_val.awk [file]
# Converts color hex code to red, green, blue percentage over the ratio.

function hex_to_ratio(hex, ratio) {
	if (substr(hex, 1, 1) == "#") {
		hex = substr(hex, 2)
	}
	r_hex = substr(hex, 1, 2)
	g_hex = substr(hex, 3, 2)
	b_hex = substr(hex, 5, 2)

	r_val = (index("0123456789abcdef", substr(tolower(r_hex), 1, 1)) - 1) * 16 + (index("0123456789abcdef", substr(tolower(r_hex), 2, 1)) - 1)
	g_val = (index("0123456789abcdef", substr(tolower(g_hex), 1, 1)) - 1) * 16 + (index("0123456789abcdef", substr(tolower(g_hex), 2, 1)) - 1)
	b_val = (index("0123456789abcdef", substr(tolower(b_hex), 1, 1)) - 1) * 16 + (index("0123456789abcdef", substr(tolower(b_hex), 2, 1)) - 1)

	red = -(ratio - ((r_val/255)*2*ratio))
	green = -(ratio - ((g_val/255)*2*ratio))
	blue = -(ratio - ((b_val/255)*2*ratio))

	return red " " green " " blue
}

BEGIN {
	if (ratio == "") {
		print "Usage: awk -v ratio=1 -f convert_hex_to_val.awk [file]" > "/dev/stderr"
		exit 1
	}
	srand()
}

{
	avail_cols[NR] = $0
}

END {
	size = NR
	num_col_left = 10 - size
	for (i = 1; i <= num_col_left; i++) {
		to_add = int(rand() * size) + 1
		avail_cols[size + i] = avail_cols[to_add]
	}

	out = ""
	for (i = 1; i <= 10; i++) {
		if (i > size + num_col_left) break
		out = out hex_to_ratio(avail_cols[i], ratio) " "
	}
	# print without trailing newline
	printf "%s", out
}
