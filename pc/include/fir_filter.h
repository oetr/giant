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

#ifndef _fir_filter_H
#define _fir_filter_H

#include <fftw3.h>
#include <dbgstream.h>
#include <dsp.h>
#include <algorithm>
#include <dbgstream.h>

/**
 * @brief FFT-based FIR filter
 */
class fir_filter
{
	public:
		/**
		 * Construct filter object
		 * @param coeff Filter coefficients in time domain
		 */
		fir_filter(const timeseries_t& coeff);
		
		/**
		 * Destructor
		 */
		~fir_filter();
	
		/**
		 * Filter timeseries and store result
		 * @param v Timeseries to filter
		 * @param output Timeseries for filtered data
		 * @warn Does not work in-place, i.e., ensure that v != output
		 */
		void filter(const timeseries_t& v, timeseries_t& output);
		
		/**
		 * Get filter length
		 * @return Length of filter in time domain in points
		 */
		unsigned int getFilterLength() const {
			return N;
		};
	protected:
	private:
		/**
		 * Length of zero padded array
		 */
		unsigned int M;
		
		/**
		 * Length of filter in time domain
		 */
		unsigned int N;
		
		/**
		 * Length of freq domain data
		 */
		unsigned int M_fft;
		
		/**
		 * Input buffer
		 */
		double* in;
		
		/**
		 * FFT output
		 */
		fftw_complex* out;
		
		/**
		 * Filter coeffs in freq domain
		 */
		fftw_complex* filter_coeff;
		
		/**
		 * FFT plans
		 */
		fftw_plan plan_fft, plan_ifft;
		
		/**
		 * FFT init status
		 */
		bool inited;
};

#endif
