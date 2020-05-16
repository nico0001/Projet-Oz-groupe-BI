all : main.oza
main.oza : main.oz Reader.ozf Parse.ozf Dict.ozf
	ozc -c main.oz -o main.oza
%.ozf : %.oz
	ozc -c $< -o $@
run : main.oza
	ozengine main.oza
clean :
	rm -f *.oza *.ozf