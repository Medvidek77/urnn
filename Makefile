# Top-level BSD Makefile

all:
	@$(MAKE) -C network
	@$(MAKE) -C colors/sin_colors

clean:
	@$(MAKE) -C network clean
	@$(MAKE) -C colors/sin_colors clean
