#include <plot/trace_display_window_manager.h>

trace_display_window::trace_display_window(int x, int y, int w, int h, const char* l) :
	Fl_Double_Window(x, y, w, h, l), display_widget(10, 35, w - 20, h - 45, ""), 
	zoom_in(10, 10, 20, 20, "+"), zoom_out(35, 10, 20, 20, "-")
{
	add_resizable(display_widget);
	add(zoom_in);
	add(zoom_out);
	
	zoom_in.callback(trace_display_window::zoom_in_static, this);
	zoom_out.callback(trace_display_window::zoom_out_static, this);
	
	//fl_color(220, 220, 220);
}

trace_display_window::~trace_display_window()
{
}

void trace_display_window::zoom_in_static(Fl_Widget* w, void* u)
{
	trace_display_window* win = reinterpret_cast<trace_display_window*>(u);
	
	if(win) {
		win->box().zoom(true);
	}
}

void trace_display_window::zoom_out_static(Fl_Widget* w, void* u)
{
	trace_display_window* win = reinterpret_cast<trace_display_window*>(u);
	
	if(win) {
		win->box().zoom(false);
	}
}

trace_display_box::trace_display_box(int x, int y, int w, int h, const char* label) : Fl_Box(x, y, w, h, label),
	y_range(0), hold(false), hold_count(0), highlight_start(0), highlight_end(0)
{
	color(FL_WHITE);
}

trace_display_box::~trace_display_box()
{
}

void trace_display_box::draw()
{
	t_lock.acquire();
	
	const int x_spacing= 5;
	const int y_spacing = 5;
	const int y_zero = h()/2 + y();
	const int x_offset = x() + x_spacing;
	const int y_offset = y() + y_spacing;
	
	if(hold == false || hold_count == 0)
	{
		// clear background
		fl_color(220, 220, 220);
		fl_rectf(x(), y(), w(), h());
	}
	
	const double y_scale = (h()/2 - y_spacing)/y_range;
	const double x_scale = static_cast<double>(w() - 2*x_spacing)/t.size();
	
	// Draw axis grid
	fl_color(0, 0, 0);
	fl_line(x_offset, h() - y_spacing + y(), x_offset, y_offset);
	fl_line(x_offset, y_zero, w() - x_spacing + x(), y_zero);
	
	// draw data points
	fl_color(0, 0, 140);
	
	unsigned int x_prev = x_offset, y_prev = y_zero;
	for(unsigned int n = 0; n < t.size(); n++) {
		// change color to highlight region
		if(n == highlight_start) {
			fl_color(FL_RED);
		}
		if(n == highlight_end) {
			fl_color(0, 0, 140);
		}
		
		unsigned int x = static_cast<unsigned int>(n*x_scale) + x_offset;
		unsigned int y = static_cast<unsigned int>(-t[n]*y_scale + y_zero);
		fl_line(x_prev, y_prev, x, y);
		x_prev = x;
		y_prev = y;
	}
	
	// draw y-axis range
	std::string y_plus = "+" + to_string(y_range);
	std::string y_minus = "-" + to_string(y_range);
	
	fl_draw(y_plus.c_str(), x_offset + 5, y() + y_spacing + 10);
	fl_draw(y_minus.c_str(), x_offset + 5, h() - y_spacing + y());
	
	t_lock.release();
}

void trace_display_box::setData(const timeseries_t& t_draw, const bool hold)
{
	// get lock
	t_lock.acquire();
	
	// copy
	t = t_draw;
	this->hold = hold;
	hold_count++;
	
	t_lock.release();
	
	// repaint
	Fl::lock();
	damage(FL_DAMAGE_ALL);
	redraw();
	Fl::check();
	Fl::unlock();
}

void trace_display_box::setHighlightRegion(const unsigned int begin, const unsigned int end)
{
	// get lock
	t_lock.acquire();
	
	highlight_start = begin;
	highlight_end = end;
	
	// release lock
	t_lock.release();
}

void trace_display_box::setYRange(const double y_range)
{
	// get lock
	t_lock.acquire();
	
	// copy
	this->y_range = y_range;

	// unlock
	t_lock.release();
	
	// repaint
	Fl::lock();
	damage(FL_DAMAGE_ALL);
	redraw();
	Fl::check();
	Fl::unlock();
}



double trace_display_box::getYRange()
{
	// get lock
	t_lock.acquire();
	
	// copy
	const double result = y_range;

	// unlock
	t_lock.release();
	
	return result;
}

void trace_display_box::zoom(const bool in)
{
	// get lock
	t_lock.acquire();
	
	// update y-range
	if(in) {
		y_range -= y_range/2;
	}
	else {
		y_range += y_range;
	}

	// unlock
	t_lock.release();
	
	// repaint
	Fl::lock();
	damage(FL_DAMAGE_ALL);
	redraw();
	Fl::check();
	Fl::unlock();
}

