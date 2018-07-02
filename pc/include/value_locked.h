/*!
   This file is part of GIAnt, the Generic Implementation ANalysis Toolkit
   
   Visit www.sourceforge.net/projects/giant/
   
   Copyright (C) 2010 - 2011 David Oswald <david.oswald@rub.de>
   
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License version 3 as
   published by the Free Software Foundation.

   This program is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
   General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, see http://www.gnu.org/licenses/.
!*/

#ifndef _VALUE_LOCKED_H
#define _VALUE_LOCKED_H

#include <pthread.h>

template<class T>
/**
 * @brief Locked thread-safe value wrapper
 */
class value_locked
{
	public:
		/**
		 * Default constructor
		 */
		value_locked() {
			pthread_mutex_init(&mutex_value, 0);
		};
		
		/** 
		 * Init constructor
		 * @param val Value to init with
		 */
		value_locked(const T& val) : value(val) {
			pthread_mutex_init(&mutex_value, 0);
		};
		
		/**
		 * Destructor
		 */
		~value_locked() {
			pthread_mutex_destroy(&mutex_value);
		}
		
		/**
		 * Acquire lock for value
		 * @warning Must be matched by release()call when done
		 */
		inline void acquire() {
			pthread_mutex_lock(&mutex_value);
		};
		
		/**
		 * Acquire lock for value and get reference
		 * @warning Must be matched by release()call when done
		 * @return Reference to value
		 */
		inline T& acquire_get() {
			acquire();
			return value;
		};
		
		/**
		 * Release lock acquired before
		 * @warning Match with acquire()/acquire_get() call
		*/
		inline void release() {
			pthread_mutex_unlock(&mutex_value);
		};
		
		/**
		 * Get object value
		 * @return Object value copy
		 */
		inline T get() {
			T tmp = acquire_get();
			release();
			return tmp;
		};
		
		/**
		 * Set object value
		 * @param val Reference to value to insert
		 */
		inline void set(const T& val) {
			acquire();
			value = val;
			release();
		};
	protected:
	private:
		/**
		 * Storage for actual value
		 */
		T value;
	
		 /**
		  * Mutex for value locking
		  */
		mutable pthread_mutex_t mutex_value;
};

#endif
