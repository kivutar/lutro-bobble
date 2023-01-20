lutro:
	zip -9 -r Bobble.lutro ./*

love:
	zip -9 -r Bobble.love ./*

wasm:
	python3 ~/emsdk/upstream/emscripten/tools/file_packager.py Bobble.data --preload ./* --js-output=Bobble.js

clean:
	@$(RM) -f Bobble.*

.PHONY: all clean
