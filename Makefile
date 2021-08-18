Bobble.lutro:
	zip -9 -r Bobble.lutro ./*

Bobble.js:
	python3 ~/emsdk/upstream/emscripten/tools/file_packager.py Bobble.data --preload ./* --js-output=Bobble.js

clean:
	@$(RM) -f Bobble.*

.PHONY: all clean
