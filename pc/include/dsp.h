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

/**
 * @file dsp.h
 * @short DSP functions
 */

#ifndef _dsp_h_included
#define _dsp_h_included

// C includes
//#include <inttypes.h>

// C++ includes
#include <complex>
#include <vector>
#include <iostream>
#include <deque>
#include <iterator>
#include <iomanip>
#include <fstream>
#include <queue>

// Project includes
#include <dbgstream.h>
#include <fftw3.h>
#include <util.h>

// Added by Benno: New c++ compiler Version needs new Headers!
#include <limits>   // Obviosly needed for compiling
//#include <cstring>

/**
 * Trace 16 bit data type
 */
typedef int16_t trace_raw_t;

/**
 * Type for complex data
 */
typedef std::complex<double> complex_t;

/**
 * Array type for spectral data
 */
typedef std::vector<complex_t> spectrum_t;

/**
 * Basic data type for float
 */
typedef double dsp_float_t;

/**
 * Array type for time domain data
 */
typedef std::vector<dsp_float_t> timeseries_t;

/**
 * Precision for ASCII double I/O
 */
const unsigned int DSP_DOUBLE_ASCII_PREC = 20;

/**
 * Shift timeseries to the left, appending zeros at the end
 * @note
 * @param v Timeseries to shift
 * @param shift Number of points to shift
 */
void dsp_shift_left(timeseries_t& v, const unsigned int shift);

/**
 * Shift timeseries to the right, adding zeros at the beginning,
 * discarding samples at the end
 * @param v Timeseries to shift
 * @param shift Number of points to shift
 */
void dsp_shift_right(timeseries_t& v, const unsigned int shift);

/**
 * Get sample mean of timeseries
 * @param v Timeseries to get mean of
 * @return Mean of v
 */
double dsp_mean(const timeseries_t& v);

/**
 * Get powerof timeseries
 * @param v Timeseries to get power of
 * @return Power of v
 * @note The power value is _not_ divided by v.size()
 */
double dsp_power(const timeseries_t& v);

/**
 * Get sample variance of timeseries
 * @param v Timeseries to get variance of
 * @return Variance of v
 */
double dsp_var(const timeseries_t &v);

/**
 * Get sample variance if mean is known (optimization)
 * @param v Timeseries to get variance of
 * @param mean Mean of v
 * @return Variance of v
 */
double dsp_var(const timeseries_t &v, const double mean);

/**
 * Get first maximum of timeseries
 * @param v Timeseries to get maximum of
 * @return Value such that all other values of v are < than this result
 */
double dsp_max(const timeseries_t& v);

/**
 * Get first minimum of timeseries
 * @param v Timeseries to get minimum of
 * @return Value such that all other values of v are > than this result
 */
double dsp_min(const timeseries_t& v);

/**
 * Get first maximum of timeseries and its position
 * @param v Timeseries to get maximum of
 * @param max_idx Reference to integer to write position of first maximum to
 * @return Value such that all other values of v are < than this result
 */
double dsp_max(const timeseries_t& v, unsigned long& max_idx);

/**
 * Get first minimum of timeseries and its position
 * @param v Timeseries to get minimum of
 * @param max_idx Reference to integer to write position of first minimum to
 * @return Value such that all other values of v are > than this result
 */
double dsp_min(const timeseries_t& v, unsigned long& min_idx);

/**
 * Perform FFT of timeseries
 * @warning CURRENTLY DISABLED
 * @param v Timeseries to transform
 * @param V Output variable for spectrum
 * @param zero_pad Optional: Number of zeros to append to increase spectral resolution, defaults to 0
 */
void dsp_fft(const timeseries_t& v, spectrum_t& V, const unsigned int zero_pad = 0);

/**
 * Perform IFFT of spectral data
 * @warning CURRENTLY DISABLED
 * @param V Spectral data to transform
 * @param v Output variable for timeseries
 */
void dsp_ifft(const spectrum_t& V, timeseries_t& v);

/**
 * Compute cross-correlation of timeseries using a time-domain approach
 * @warning NOT FULLY VERIFIED
 * @param v1 First timeseries
 * @param v2 Second timeseries
 * @param out Timeseries to write xcorr(v1, v2) to
 */
void dsp_xcorr(const timeseries_t& v1, const timeseries_t& v2,
               timeseries_t& out);

/**
 * Compute normalized cross-correlation of timeseries using a time-domain approach
 * @warning NOT FULLY VERIFIED
 * @param v1 First timeseries
 * @param v2 Second timeseries
 * @param out Timeseries to write xcorr_normalized(v1, v2) to
 */
void dsp_xcorr_norm(const timeseries_t& v1, const timeseries_t& v2,
                    timeseries_t& out);

/**
 * Compute cross-correlation of timeseries using a frequency-domain approach
 * @warning CURRENTLY DISABLED (see FFT/IFFT), NOT FULLY VERIFIED
 * @param v1 First timeseries
 * @param v2 Second timeseries
 * @param out Timeseries to write xcorr(v1, v2) to
 */
void dsp_xcorr_norm_fft(const timeseries_t& v1, const timeseries_t& v2,
                        timeseries_t& out);


/**
 * Estimate derivative of timeseries
 * @param v Timeseries to derive
 * @return Derivative of v
 */
timeseries_t dsp_derive(const timeseries_t& v);

/**
 * Filter timeseries with moving average
 * @param v Timeseries to filter in-place
 * @param len Length of moving average window
 */
void dsp_moving_average(timeseries_t& v, const unsigned int len);

/**
 * Filter timeseries with any IIR filter (compatible to MATLAB filter())
 *
 * N-1               N-1
 * SUM a(n) y(k-n) = SUM b(k) x(k-n)      for 0 <= k < length(v)
 * n=0               n=0
 *
 * Transfer function in z-Domain:
 *
 *          N-1
 *          SUM d(n) z^(-n)
 *          n=0
 * H(z) = ----------------------
 *           N-1
 *       1 + SUM c(n) z^(-n)
 *           n=1
 *
 * where c(n) = a(n) / a(0), d(n) =  b(n) / a(0)
 *
 * @param v Timeseries to filter in-place
 * @param b Coefficients for x(k-n)
 * @param a Coefficients for y(k-n), i.e., recursive part
 */
void dsp_iir(timeseries_t& v, const timeseries_t& b, const timeseries_t& a);

/**
 * Get filter coefficients for moving average (FIR filter, so a = [1])
 * @param a Output for a coefficients
 * @param b Output for b coefficients
 * @param P Length of window
 */
void dsp_movavg(timeseries_t& a, timeseries_t& b, const unsigned int P);

/**
 * Get filter coefficients for IIR chebychev Lowpass/Highpass
 * @warning NOT VERIFIED, INSTABILITY POSSIBLE DUE TO IIR CHARACTERISTICS
 * @param a Output for a coefficients
 * @param b Output for b coefficients
 * @param T_s Sample period, i.e., 1/f_sample
 * @param f_cutoff Cutoff frequency (max. is f_sample/2)
 * @param ripple Maximum ripple in range 0 ... 29
 * @param NP Number of poles, even number in range 2, 4, ..., 20
 * @param lowpass True to design lowpass, false for highpass
 */
void dsp_chebychev(timeseries_t& a, timeseries_t& b, const double T_s, const double f_cutoff,
                   const double ripple, const unsigned int NP, const bool lowpass = true);

/**
 * Get filter coefficients for IIR notch filter, 5th order
 * @param a Output for a coefficients
 * @param b Output for b coefficients
 * @param T_s Sample period, i.e., 1/f_sample
 * @param f_notch Center frequency of notch filter
 * @param Q quality factor
 */
void dsp_notch(timeseries_t& a, timeseries_t& b, const double T_s, const double f_notch,
               const double Q);

/**
 * Get filter coefficients for FIR windowed-sinc Lowpass/Highpass
 * @param a Output for a coefficients
 * @param b Output for b coefficients
 * @param T_s Sample period, i.e., 1/f_sample
 * @param f_cutoff Cutoff frequency
 * @param M Filter order
 * @param lowpass True to design lowpass, false for highpass
 */
void dsp_windowed_sinc(timeseries_t& a, timeseries_t& b, const double T_s, const double f_cutoff,
                       const unsigned int M, const bool lowpass = true);

/**
 * Get filter coefficients for FIR windowed-sinc Bandpass
 * @param b Output for b coefficients
 * @param T_s Sample period, i.e., 1/f_sample
 * @param f_hp Cutoff frequency for highpass
 * @param f_lp Cutoff frequency for lowpass
 * @param M Filter order
 */
void dsp_fir_bp(timeseries_t& b, const double T_s, const double f_hp, const double f_lp, const unsigned int M);

/**
 * Get filter coefficients for simple amplificaton (FIR filter, so a = [1], b = [c])
 * @param a Output for a coefficients
 * @param b Output for b coefficients
 * @param c Amplification factor
 */
void dsp_amplify(timeseries_t& a, timeseries_t& b, const double c);

/**
 * Integrate timeseries, i.e., y(k) = sum(n = 0 ... k)(x(n))
 * @param t Timeseries to integrate in-place
 */
void dsp_integrate(timeseries_t& t);

/**
 * Get point-wise absolute value of timeseries
 * @param t Timeseries to get absolute value of in place
 */
void dsp_abs(timeseries_t& t);

/**
 * Get blocking coefficient for DC/low-frequency blocker
 * @param f_sample Sample rate
 * @param f_cut Cut-frequency (- 6dB point)
 * @return Coefficient to use with dsp_dc_block()
 */
double dsp_get_dc_block_coeff(const double f_sample, const double f_cut);

/**
 * First order DC/low-frequency blocker (IIR)
 * @param x Timeseries to filter in-place
 * @param coeff Coefficient acquired via dsp_get_dc_block_coeff()
 */
void dsp_dc_block(timeseries_t& x, const double coeff);

/**
 * Store timeseries to ASCII file, precision (number of digits) is controlled via DSP_DOUBLE_ASCII_PREC
 * @param t Timeseries to dump
 * @param file Path to file to dump data to
 */
bool dsp_store_to_file(const timeseries_t& t, const std::string file);

/**
 * Store timeseries to binary file as 8 byte double
 * @param t Timeseries to dump
 * @param file Path to file to dump data to
 */
bool dsp_store_to_file_bin(const timeseries_t& t, const std::string file);

/**
 * Find peaks in timeseries
 * @param t Timeseries to analyse
 * @param delta Min. difference to previous peak
 * @param offset Point to start search at
 * @param length Number of points to work on, pass 0 for full timeseries
 * @param omit_max If true, maxima are _NOT_ extracted
 * @param omit_min If true, minima are _NOT_ extracted
 * @note A point is considered a peak if it has the maximal/minimal
 *       value, and was preceded (to the left) by a value lower/greater than
 *       delta
 * @return Vector of position/value pairs
 */
std::vector<std::pair<unsigned long, double> > dsp_findpeaks(const timeseries_t& t, const double delta,
        const unsigned long offset = 0, const unsigned long length = 0, const bool omit_max = false,
		const bool omit_min = false);

/**
 * Find first peaks in timeseries
 * @param t Timeseries to analyse
 * @param delta Min. difference to previous peak
 * @param offset Point to start search at
 * @param length Number of points to work on, pass 0 for full timeseries
 * @note A point is considered a peak if it has the maximal/minimal
 *       value, and was preceded (to the left) by a value lower/greater than
 *       delta
 * @return Pair containing first min/max combination (=peak)
 */
std::pair<unsigned int, unsigned int> dsp_find_first_peak(const timeseries_t& t, const double delta,
        const unsigned int offset = 0, const unsigned int length = 0);

/**
 * Get vector with Hann window coefficients of length N
 * @note w(n) = 0.5 * ( 1 - cos(2pi*n/(N-1)) )
 * @param N length of window
 * @return Timerseries with N window coefficients
 */
timeseries_t dsp_hann_window(const unsigned int N);

/**
 * @brief Recursive timeseries average & variance estimation
 *
 * Class to recursively compute point-wise average of timeseries
 */
class dsp_trace_average
{
public:
	/**
	 * Constructor
	 * @param _K Length of timeseries to average
	 */
	dsp_trace_average(const unsigned long _K = 0);

	/**
	 * Destructor
	 */
	~dsp_trace_average();

	/**
	 * Get point-wise average timeseries
	 * @return Reference to average
	 */
	const timeseries_t& get_mean() const;

	/**
	 * Get point-wise variance
	 * @return Reference to variance
	 */
	const timeseries_t& get_var() const;

	/**
	 * Update variance & average with new timeseries
	 * @param Timeseries of length K
	 */
	void update(const timeseries_t& t);

	/**
	 * Reset recursive averaging
	 */
	void clear();


	void setLength(const unsigned long& K) {
		this->K = K;
		clear();
	};
	
	const unsigned long& getLength() const {
		return K;
	};

	/**
	 * Get number of timeseries processed so far
	 * @return Number of timeseries used for mean & variance estimation
	 */
	unsigned long getN() const {
		return N;
	};

	/**
	 * Helper to update mean & variance recursively for one point in time
	 * @param val New value to use for update
	 * @param m Reference to mean variable
	 * @param M2 Reference to variance helper (variance * I) variable
	 * @param v Reference to variance variable
	 * @param I Number of timeseries before update, has to be incremented externally after this routine
	 */
	static inline void update_m_M2_var(double val, double& m, double& M2,
	                                   double& v, unsigned long I) {
		double delta = val - m;

		// update mean
		m += delta/(I+1);

		// update variance helper
		M2 += delta * (val - m);

		// update variance
		v = M2/(I);

		return;
	};
protected:
private:
	/**
	 * Storage for point-wise average, variance & variance helper
	 */
	timeseries_t mean, var, M2;

	/**
	 * Number of timeseries processed so far
	 */
	unsigned long N;

	/**
	 * Length of timeseries
	 */
	unsigned long K;
};

#endif
