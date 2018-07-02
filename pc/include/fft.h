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

#ifndef _FFT_H
#define _FFT_H

#include <fftw3.h>
#include <dbgstream.h>
#include <dsp.h>

/**
 * @brief FFT wrapper class
 */
class fft
{
	public:
		/**
		 * Create fft of given size
		 * @param size Size of time-domain data
		 */
		fft(const unsigned int size);
		
		/**
		 * Destructor
		 */
		~fft();
	
		/**
		 * Set time-domain data size
		 * @param size Size of time-domain data
		 * @return false on error, otherwise true
		 */
		bool set_n(const unsigned int size);
		
		/**
		 * Fourier-transform data
		 * @param v Input time-domain data
		 * @param V Output for freq-domain data
		 * @return false on error, otherwise true
		 */
		bool transform(const timeseries_t& v, spectrum_t& V);
		
		/** 
		 * Inverse transform
		  * @param v Output time-domain data
		 * @param V Input for freq-domain data
		 * @return false on error, otherwise true
		 */
		bool inverse_transform(const spectrum_t& V, timeseries_t& v);
		
		/**
		 * Compute power spectral density, i.e., |FFT(v)|^2
		 * @param v Input time-domain data
		 * @param sd Power spectral density output
		 * @return false on error, otherwise true
		 */
		bool psd(const timeseries_t& v, timeseries_t& sd);
		
		unsigned int get_n() const {
			return N;
		};
	protected:
	private:
		/**
		 * Cleanup helper
		 */
		void cleanup();
		
		/**
		 * Helper to perform internal transform on in -> out
		 */
		void in_to_out();
		
		/**
		 * Helper to perform internal inverse transform on out -> in
		 */
		void out_to_in();
	
		/**
		 * Init status
		 */
		bool inited;
		
		/**
		 * Size of time-domain data
		 */
		unsigned int N;
		
		/**
		 * Temporary input buffer
		 */
		double * in;
		
		/**
		 * Temporary output buffer
		 */
		fftw_complex * out;
		
		/**
		 * FFTW planner object
		 */
		fftw_plan plan;
		
		/**
		 * FFTW inverse planner object
		 */
		fftw_plan inverse_plan;
};

#endif
