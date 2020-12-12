all:
	zip -r Bobble.lutro ./*

clean:
	@$(RM) -f *.lutro

.PHONY: all clean
