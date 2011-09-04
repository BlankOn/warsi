PROGRAM = warsi

SRC = main.vala warsi-window.vala warsi-database.vala

PKGS = --pkg atk --pkg gdk-x11-3.0 --pkg gdk-3.0 --pkg gtk+-3.0 --pkg unique-3.0 --pkg sqlite3 --pkg gee-1.0

VALAC = valac

BUILD_ROOT = 1

all:
	@$(VALAC) $(SRC) -o $(PROGRAM) --vapidir=vapi $(PKGS)

release: clean
	@$(VALAC) -X -O2 $(SRC) -o main_release $(PKGS)

clean:
	@rm -v -rf *~ *.c $(PROGRAM)
