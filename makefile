SRCEXT := sh
SRCDIR := .
SOURCES := $(shell find $(SRCDIR) -type f -name *.$(SRCEXT))

DST := $(shell echo $(SOURCES) | sed -e 's/\.$(SRCEXT)//')

all: copy

copy:
	@cp lib.sh lib

clean:
	@rm -rf $(DST)
