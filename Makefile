all:
	zip -r Bobble.lutro ./*

clean:
	@$(RM) -f Bubble.lutro
	@$(RM) -rf Bobble/

.PHONY: all clean
