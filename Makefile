VERSION = 0.0

CXX = g++ -std=gnu++2a $(COLOR)

CXXFLAGS = $(OPT) $(DEBUG)
OPT = -Og
DEBUG = -g
PLUGINDIR = $(shell $(CXX) -print-file-name=plugin)
INCLUDES = -I$(PLUGINDIR)/include
DEFINES = -DVERSION=\"$(VERSION)\"
WARN = -Wall
#LTO = -flto
COLOR = -fdiagnostics-color=auto

LDFLAGS = $(LTO)
LIBS =

ALL = astprint
ALLBIN = $(addsuffix .so,$(ALL))

astprint_SRCS = astprint.cc
astprint_OBJS = $(astprint_SRCS:.cc=.o)

.PHONY: all clean check
all: $(ALLBIN)

.cc.o:
	$(CXX) $(CXXFLAGS) $(LTO) $(DEFINES) $(WARN) $(INCLUDES) -c -fPIC -fno-rtti -o $@ $<

define SORULE
$(1).so: $$($(1)_OBJS)
	$(CXX) -shared -o $$@ $$(LDFLAGS) $$^ $$(LIBS)
endef

$(foreach o,$(ALL),$(eval $(call SORULE,$o)))

clean:
	-rm -f $(ALLBIN) $(foreach a,$(ALL),$($(a)_OBJS))

check: all
	$(CXX) -fplugin=$$PWD/astprint.so -fplugin-arg-astprint-sds=3 -c test1.cc
