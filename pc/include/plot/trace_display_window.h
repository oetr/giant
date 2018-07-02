#ifndef __trace_display_window__
#define __trace_display_window__

// C++ includes
#include <FL/Fl.H>
#include <FL/Fl_Double_Window.H>
#include <FL/fl_draw.h>
#include <FL/Fl_Box.h>
#include <FL/Fl_Button.h>
#include <iostream>

// C includes
#include <sys/types.h>
#include <cmath>
#include <cstdio>
#include <sys/time.h>

// Project includes
#include <dbgstream.h>
#include <value_locked.h>
#include <dsp.h>
#include <util.h>

/**
 * @brief Box widget to draw a trace onto
 */
class trace_display_box : public Fl_Box
{
	public:
		/**
		 * Constructor
		 * @param x X-position
		 * @param y Y-position
		 * @param w Width of widget
		 * @param h Height of widget
		 * @param label Optional label
		 */
		trace_display_box(int x, int y, int w, int h, const char* label = 0);
		
		/**
		 * Destructor
		 */
		~trace_display_box();
		
		/**
		 * Set data to draw
		 * @param t_draw Reference to timeseries to draw
		 * @param hold Do not clear window when plotting and cycle through colors
		 */
		void setData(const timeseries_t& t_draw, const bool hold = false);
		
		/**
		 * Set region to highlight
		 * @param begin First point to highlight
		 * @param count Last point to highlight
		 */
		void setHighlightRegion(const unsigned int begin, const unsigned int end);
		
		/**
		 * Set y-range
		 * @param y_range Range value to set
		 */
		void setYRange(const double y_range);
		
		/**
		 * Get y-range
		 * @return Range value
		 */
		double getYRange();
		
		/**
		 * Zoom
		 * @param in Zoom in if true, otherwise zoom out
		 */
		void zoom(const bool in);
	
		/**
		 * Widget drawing method
		 */
		void draw();
	protected:
		/**
		 * Timeseries to draw
		 */
		timeseries_t t;
		
		/**
		 * Current y range
		 */
		double y_range;
		
		/**
		 * Do not clear window when plotting and cycle through colors
		 */
		bool hold;
		
		/**
		 * Number of traces plotted
		 */
		unsigned int hold_count;
		
		/**
		 * Lock for timeseries
		 */
		value_locked<bool> t_lock;
		
		/**
		 * Highlight region start 
		 */
		unsigned int highlight_start;
		
		/**
		 * Highlight region end
		 */
		unsigned int highlight_end;
	private:
};

/**
 * @brief Class to display trace
 * Bases on fltk, which is available as cygwin package
 */
class trace_display_window : public Fl_Double_Window
{
	public:
		/**
		 * Constructor
		 * @param x X-position
		 * @param y Y-position
		 * @param w Width of widget
		 * @param h Height of widget
		 * @param l Optional window title
		 */
		trace_display_window(int x, int y, int w, int h, const char *l = 0);
		
		/**
		 * Destructor
		 */
		~trace_display_window();
		
		/**
		 * Get plot widget
		 * @return Reference to plot box
		 */
		trace_display_box& box() {
			return display_widget;
		};
		
		/**
		 * Zoom in callback
		 */
		static void zoom_in_static(Fl_Widget* w, void* u);
		
		/**
		 * Zoom out callback
		 */
		static void zoom_out_static(Fl_Widget* w, void* u);
	protected:
		/**
		 * Display widget
		 */
		trace_display_box display_widget;
		
		/**
		 * y-axis zoom buttons
		 */
		Fl_Button zoom_in, zoom_out;
	private:

};
#endif // __trace_display_window__
