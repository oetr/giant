#include <plot/trace_display_window_manager.h>

trace_display_window_manager::trace_display_window_manager()
{
	running.set(false);
}

trace_display_window_manager::~trace_display_window_manager()
{
	// cleanup
	std::vector<trace_display_window*>::iterator it;
	for(it = windows.begin(); it != windows.end(); ++it) {
		delete (*it);
	}
}

trace_display_window* trace_display_window_manager::createWindow(const std::string name, const unsigned int x, 
	const unsigned int y, const unsigned int w, const unsigned int h)
{
	Fl::lock();
	
	trace_display_window* win = new trace_display_window(x, y, w, h, name.c_str());
	
	// create and display window
	windows.push_back(win);
	win->show();
	
	Fl::check();
	
	Fl::unlock();
	
	return win;
}

bool trace_display_window_manager::start()
{
	//dbg::trace trace(DBG_HERE);
	
	cdbg << "About to start" << std::endl;
	
	if(running.get()) {
		return false;
	}
	
	cdbg << "Starting thread" << std::endl;
	
	// start sampling thread
	pthread_t thread;

	
	if(pthread_create(&thread, 0, this->thread_func, this) != 0) {
		running.set(false);
		return false;
	}

	cdbg  << "Detaching thread" << std::endl;
	
	// detach thread so it does not leak memory after exiting
	pthread_detach(thread);

	running.set(true);
	
	std::vector<trace_display_window*>::iterator it;
	for(it = windows.begin(); it != windows.end(); ++it) {
		(*it)->show();
	}
	
	return true;
}

bool trace_display_window_manager::stop()
{
	if(!running.get()) {
		return false;
	}
	
	running.set(false);
	return true;
}

void* trace_display_window_manager::thread_func(void* u)
{
	trace_display_window_manager* me = reinterpret_cast<trace_display_window_manager*>(u);
	
	// start multithreaded FL
	Fl::lock();
	
	while (Fl::wait() > 0) 
	{
		if (Fl::thread_message()) {
			// process messages
		}
	}

	cdbg  << "Thread exiting" << std::endl;
	
	me->running.set(false);

	//pthread_exit(0);
	return 0;
}



