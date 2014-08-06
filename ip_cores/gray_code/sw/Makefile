SRCS = gray gray_long

RANLIB=ranlib

CFLAGS		= -Wall -DDEBUG -D_GNU_SOURCE -g -I. -I../$(INCDIR)
CFLAGS		+= 
#CFLAGS      += -I../lib
LDLIBS		= -lrt

all: $(SRCS:.c=)

.PHONY: all sources clean

%.o:     %.c
	$(CC) $(CFLAGS) -o $@ -c $<

sources: $(SRCS) $(SCRIPTS)

gray: gray.c

gray_long: gray_long.c

clean:
	$(RM) *.o *.a *.bak  $(SRCS:.c=)
