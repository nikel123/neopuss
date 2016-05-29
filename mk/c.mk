CC ?= gcc
CCFLAGS ?= -mtune=native -march=native -O2 -Wall

%.o: %.c mk/c.mk config.mk
	$(CC) $(CFLAGS) -c '$<' -o '$@'

%: %.o mk/c.mk config.mk
	$(CC) $(CFLAGS) $(LDFLAGS) $(filter %.o,$^) $(LIBS) -o '$@'
