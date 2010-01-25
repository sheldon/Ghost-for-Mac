SHELL = /bin/sh
SYSTEM = $(shell uname)
C++ = g++
CC = gcc
DFLAGS =
OFLAGS = -Os
LFLAGS = -L. -L/home/ghost/boost/boost_1_41_0/stage/lib -lboost_system -lboost_program_options -lboost_filesystem -Lbncsutil -lbncsutil
CFLAGS =


CFLAGS += $(OFLAGS) $(DFLAGS) -I. -I/home/ghost/boost/boost_1_41_0 -Ibncsutil

OBJS = wc3hasher.o connection.o hasher.o
PROGS = ./wc3hasher

all: $(OBJS) $(COBJS) $(PROGS)

./wc3hasher: $(OBJS)
	$(C++) -o ./wc3hasher $(OBJS) $(COBJS) $(LFLAGS)

clean:
	rm -f $(OBJS) $(PROGS)

$(OBJS): %.o: %.cpp
	$(C++) -o $@ $(CFLAGS) -c $<

#./wc3hasher++: $(OBJS)

#all: $(PROGS)

connection.o: connection.h hasher.h wc3hasher.h
hasher.o: hasher.h
wc3hasher.o: connection.h wc3hasher.h hasher.h
