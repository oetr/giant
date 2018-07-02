#  window
COMMON_SOURCES += $(COMMON_DIR)/src/plot/trace_display_window.cpp
COMMON_SOURCES += $(COMMON_DIR)/src/plot/trace_display_window_manager.cpp

LDFLAGS += `fltk-config --ldflags`

INCLUDEDIRS += 
