Bobble.love:
	zip -9 -r Bobble.love ./*

Bobble.lutro:
	zip -9 -r Bobble.lutro ./*

Bobble.app: Bobble.love
	cp -r /Applications/love.app ./Bobble.app
	cp Bobble.love Bobble.app/Contents/Resources/

webapp: Bobble.love
	love-js Bobble.love example -t Bobble --memory 67108864

serve: webapp
	python3 -m http.server 8000 --directory example

clean:
	@$(RM) -f Bobble.love
	@$(RM) -f Bobble.lutro
	@$(RM) -rf Bubble.app
	@$(RM) -rf Bobble/
	@$(RM) -rf example

.PHONY: all clean
