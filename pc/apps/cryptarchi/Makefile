CC = gcc
CPP = g++
CFLAGS = -c -Wall -O3

ifneq (,$(findstring CYGWIN,$(shell uname)))
  USING_CYGWIN = true
endif

ifneq (,$(findstring MINGW,$(shell uname)))
  USING_CYGWIN = true
endif

OUTPUT_DIR = .

# include common stuff
COMMON_DIR = ../../
-include $(COMMON_DIR)/common.mk

# add own sources

# code files => object files
CPP_OBJECTS = $(COMMON_SOURCES:.cpp=.o)
C_OBJECTS = $(COMMON_SOURCES_C:.c=.o)

DEPS = $(COMMON_SOURCES:%.cpp=%.d) $(COMMON_SOURCES_C:%.c=%.d)
CFLAGS += -MD

ifdef USING_CYGWIN
	CFLAGS += -DWIN32
	LDFLAGS += -lfftw3 -lusb
	#COPY_DLLS = cp $(DLLS) $(OUTPUT_DIR)
	CLEANUP_DLLS = rm -f $(OUTPUT_DIR)/*.dll
else
	CFLAGS += -DWIN32 
	LDFLAGS += -lusb -lfftw3
endif

.SUFFIXES: .cpp .c .cpp.o .c.o

first : all

# include makefiles for executables
-include main.mk

# include dependencies
-include $(DEPS)

all: $(EXECUTABLES)
	$(COPY_DLLS)

.c.o:	
	@echo $<
	@$(CC) $(INCLUDEDIRS) $(CFLAGS) $< -o $@
	
.cpp.o:
	@echo $<
	@$(CPP) $(INCLUDEDIRS) $(CFLAGS) $< -o $@

clean:
	rm -f $(C_OBJECTS) $(CPP_OBJECTS) $(CLEANUP) $(DEPS)
	$(CLEANUP_DLLS)


