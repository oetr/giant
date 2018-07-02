#ifndef __trace_display_window_manager__
#define __trace_display_window_manager__

// C++ includes
#include <FL/Fl.H>

// C includes
#include <sys/types.h>
#include <cmath>
#include <cstdio>
#include <sys/time.h>
#include <iostream>

// Project includes
#include <dbgstream.h>
#include <value_locked.h>
#include <dsp.h>
#include <dbg.h>
#include <plot/trace_display_window.h>

/**
 * @brief Manager class for trace windows
 * Bases on fltk, which is available as cygwin package
 */
class trace_display_window_manager
{
	public:
		trace_display_window_manager();
		~trace_display_window_manager();
		
		/**
		 * Start main window thread
		 */
		bool start();
		
		/**
		 * Stop main window thread
		 */
		bool stop();
		
		/**
		 * Main thread function
		 */
		static void* thread_func(void * u);
		
		/**
		 * Create named trace display window
		 * @param name Name of new window
		 * @param x x-coordinate
		 * @param y y-coordinate
		 * @param w Width of window
		 * @param h Height of window
		 * @return Pointer to new trace_display_window
		 */
		trace_display_window* createWindow(const std::string name,
			const unsigned int x, const unsigned int y, const unsigned int w, const unsigned int h);
	protected:
		/**
		 * Thread state
		 */
		value_locked<bool> running;
		
		/**
		 * List of windows
		 */
		std::vector<trace_display_window*> windows;
	private:

};
#endif // __trace_display_window_manager__
