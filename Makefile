all:
	zip -9 -r Bobble.love ./*

clean:
	@$(RM) -f Bubble.love
	@$(RM) -rf Bobble/

.PHONY: all clean
