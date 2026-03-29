CFLAGS = -std=gnu17 -pedantic -Wall -Wextra -Wmissing-prototypes -O2 -pipe
DEPEND = depend.mk

.PHONY: all clean depend

include $(DEPEND)

clean:
	rm -f $(DEPEND)

depend: $(DEPEND)

$(DEPEND): *.c
	for file in $^; do all_files="$$all_files $(HOME)/bin/$${file%.c}"; done; echo "all:$$all_files" > $@

$(HOME)/bin/%: %.c
	$(CC) $(CFLAGS) -o $@ $<
