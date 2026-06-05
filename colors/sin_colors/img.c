/* See LICENSE file for copyright and license details. */
#include <err.h>
#include <stdio.h>

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

#include "colors.h"

void
parseimg(char *f, void (*fn)(int, int, int))
{
	int width, height, channels;
	unsigned char *data = stbi_load(f, &width, &height, &channels, 0);

	if (!data) {
		errx(1, "failed to open or decode image: %s", f);
	}

	for (int y = 0; y < height; y++) {
		for (int x = 0; x < width; x++) {
			unsigned char *p = data + (y * width + x) * channels;
			// Skip transparent pixels
			if (channels == 4 && p[3] == 0) {
				continue;
			}
			fn(p[0], p[1], p[2]);
		}
	}

	stbi_image_free(data);
}
