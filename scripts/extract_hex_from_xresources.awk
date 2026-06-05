#!/usr/bin/awk -f

# extract_hex_from_xresources.awk

BEGIN {
	colors_idx["background"] = 0
	colors_idx["foreground"] = 1
	for (i = 0; i < 16; i++) {
		colors_idx["color" i] = 2 + i
	}
}

{
	for (c in colors_idx) {
		if ($0 ~ c "[ \t]*:") {
			match($0, /#[0-9a-fA-F]{6}/)
			if (RSTART > 0) {
				val = tolower(substr($0, RSTART+1, 6))
				colors[colors_idx[c]] = val
			}
		}
	}
}

END {
	for (i = 0; i < 18; i++) {
		print colors[i]
	}
}
