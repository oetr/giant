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

#include "dsp.h"

void dsp_shift_left(timeseries_t& v, const unsigned int shift)
{
	// shift left
	for(long k = static_cast<long>(shift); k < static_cast<long>(v.size()); k++) 
	{
		v[k - shift] = v[k];
	}
	
	// append zeros
	for(long k = v.size() - static_cast<long>(shift); k < static_cast<long>(v.size()); k++) 
	{
		v[k] = 0;
	}
}


void dsp_shift_right(timeseries_t& v, const unsigned int shift)
{
	// shift
	for(long k = static_cast<long>(v.size())-1; k >= static_cast<long>(shift); k--) 
	{
		v[k] = v[k - shift];
	}
	
	// zero beginning
	for(long k = 0; k < static_cast<long>(shift) && k < static_cast<long>(v.size()); k++) {
		v[k] = 0;
	}

}

double dsp_mean(const timeseries_t& v)
{
    double mean = 0;
    const double n = static_cast<double>(v.size());

    for(unsigned int i = 0; i < v.size(); i++)
        mean += v[i]/n;

    return mean;
}

double dsp_power(const timeseries_t& v)
{
    double power = 0;
    //const double n = static_cast<double>(v.size());

    for(unsigned int i = 0; i < v.size(); i++)
        power += v[i]*v[i];

    return power;
}

double dsp_var(const timeseries_t &v)
{
    return dsp_var(v, dsp_mean(v));
}

double dsp_var(const timeseries_t &v, const double mean)
{
    double var = 0;

    for(unsigned int i = 0; i < v.size(); i++)
        var += (v[i] - mean) * (v[i] - mean);

    return var/(v.size()-1);
}

double dsp_max(const timeseries_t& v)
{
	unsigned long dummy = 0;
	return dsp_max(v, dummy);
}

double dsp_min(const timeseries_t& v)
{
	unsigned long dummy = 0;
	return dsp_min(v, dummy);
}

double dsp_max(const timeseries_t& v, unsigned long& max_idx)
{
	max_idx = 0;
	for(unsigned long i = 0; i < v.size(); i++)
		if(v[i] > v[max_idx])
			max_idx = i;

	return v[max_idx];
}

double dsp_min(const timeseries_t& v, unsigned long& min_idx)
{
	min_idx = 0;
	for(unsigned long i = 0; i < v.size(); i++)
		if(v[i] < v[min_idx])
			min_idx = i;

	return v[min_idx];
}

void dsp_xcorr(const timeseries_t& v1, const timeseries_t& v2,
    timeseries_t& out)
{
    const int n = std::min(v1.size(), v2.size());
	const int max_shift = n;
	const unsigned int out_size = 2*max_shift + 1;
	out.resize(out_size);

	double s_v1v2 = 0;

	// correlation for shifted signals upto some fixed bound
	for(int shift = -max_shift; shift < max_shift; shift++) {
		s_v1v2 = 0;

		for(int i = 0 ; i < n; i++) {
			int j = i + shift;
			// out of series?

			if (j < 0 || j >= n)
				continue;
			else
				s_v1v2 += (v2[i]) * (v1[j]);
		}

		out[shift + max_shift] = s_v1v2;
	}
}

void dsp_xcorr_norm(const timeseries_t& v1, const timeseries_t& v2,
    timeseries_t& out)
{
    const int n = std::min(v1.size(), v2.size());
    const int max_shift = n;
	const unsigned int out_size = 2*max_shift + 1;
    out.resize(out_size);

    const double m_v1 = dsp_mean(v1), m_v2 = dsp_mean(v2);
    const double s_v1 = dsp_var(v1, m_v1), s_v2 = dsp_var(v2, m_v2);
    double s_v1v2 = 0;

    // correlation coeff. denominator
    double denominator = sqrt(s_v1 * s_v2);

    // correlation for shifted signals upto some fixed bound
    for(int shift = -max_shift; shift < max_shift; shift++) {
        s_v1v2 = 0;

        for(int i = 0 ; i < n; i++) {
            int j = i + shift;
            // out of series?

            if (j < 0 || j >= n)
                continue;
            else
                s_v1v2 += (v2[i] - m_v2) * (v1[j] - m_v1);


             // rule variant: v2[j] = 0 for j < 0 and j >= n
             /*if (j < 0 || j >= n)
                s_v1v2 += (v1[i] - m_v1) * (- m_v2);
             else
                s_v1v2 += (v1[i] - m_v1) * (v2[j] - m_v2);*/

        }

        out[shift + max_shift] = s_v1v2/denominator;
    }
}

void dsp_moving_average(timeseries_t& v, const unsigned int len)
{
	if(len <= 1)
		return;
		
	double acc = 0;
	
	std::queue<double> qv;
	
	// first window up to len-1
	for(unsigned int i = 0; i < v.size() && i < len; i++) {
		acc += v[i];
		qv.push(v[i]);
		v[i] = acc/len;
	}
	
	// window fully in timeseries
	double old_v = 0;
	for(unsigned int i = len; i < v.size(); i++) {
		// get old value just out of window
		old_v = qv.front();
		qv.pop();
		
		// add new value
		qv.push(v[i]);
		
		// update
		acc = acc + v[i] - old_v;
		v[i] = acc/len;
	}
}

timeseries_t dsp_derive(const timeseries_t& v)
{
	timeseries_t d;
	d.resize(v.size(), 0);
	
	if(v.size() > 0) {
		d[0] = v[0];
		
		// diff[i] = ((v[i] - v[i-1]) + (v[i+1] - v[i-1])/2)/2
		for(unsigned int i = 1; i < v.size()-1; i++) {
			d[i] = (2*v[i] - 3*v[i-1] + v[i+1])/4;
		}
	}
	
	return d;
}

void dsp_abs(timeseries_t& t) {
	for(unsigned int k = 0; k < t.size(); k++)
		t[k] = fabs(t[k]);
}

bool dsp_store_to_file(const timeseries_t& t, const std::string file)
{
	std::ofstream ofs;
    ofs.open(file.c_str());
    if (!ofs.is_open()) {
        cerror << "dsp_store_to_file(): Cannot open file " << file << " for output" << std::endl;
        return false;
    }

	ofs << std::setprecision(DSP_DOUBLE_ASCII_PREC);
	std::copy(t.begin(), t.end(), std::ostream_iterator<double> (ofs, "\n"));
    
	ofs.close();
	
	return true;
}

bool dsp_store_to_file_bin(const timeseries_t& t, const std::string file)
{
	std::ofstream ofs;
    ofs.open(file.c_str(), std::ios::binary);
    if (!ofs.is_open()) {
        cerror << "dsp_store_to_file_bin(): Cannot open file " << file << " for output" << std::endl;
        return false;
    }

	ofs.write(reinterpret_cast<const char*>(&t[0]), t.size() * sizeof(dsp_float_t));
	ofs.close();
	
	return true;
}


void dsp_fft(const timeseries_t& v, spectrum_t& V, const unsigned int zero_pad)
{
	cerror << "WARNING: FFT disabled!" << std::endl;

    /*
	const unsigned int n = v.size() + zero_pad;
    const unsigned int n_dft = n/2 + 1;
 
	V.clear();

    // input array
    double * in = new double[n];
    if(!in) {
        std::cerr << "Could not create DFT input array" << std::endl;
        return;
    }

    // output array
    fftw_complex* out = new fftw_complex[n_dft];
    if(!out) {
        std::cerr << "Could not create DFT output array" << std::endl;
        delete [] out;

        return;
    }

    fftw_plan plan = fftw_plan_dft_r2c_1d(n, in, out, FFTW_MEASURE);
    if(!plan) {
        std::cerr << "Could not create DFT plan" << std::endl;
        delete [] out;
        delete [] in;

        return;
    }

    // copy input AFTER plan creation!
    for(unsigned int i = 0; i < v.size(); i++) {
        in[i] = static_cast<double>(v[i]);
    }

    // zero padding
    for(unsigned int i = v.size(); i < v.size() + zero_pad; i++) {
        in[i] = 0;
    }

    // execute
    fftw_execute(plan);

    // copy output
    for(unsigned int i = 0; i < n_dft; i++) {
        complex_t tmp(out[i][0], out[i][1]);
        V.push_back(tmp);
    }

    fftw_destroy_plan(plan);
    delete [] in;
    delete [] out;*/
}

void dsp_ifft(const spectrum_t& V, timeseries_t& v)
{
	cerror << "WARNING: FFT disabled!" << std::endl;
	
	/*
	const unsigned int n_dft = V.size();
    const unsigned int n = 2*n_dft - 2;
    
	 v.clear();

    // output array
    double * out = new double[n];
    if(!out) {
        std::cerr << "Could not create IDFT output array" << std::endl;
        return;
    }

    // input array
    fftw_complex* in = new fftw_complex[n_dft];
    if(!in) {
        std::cerr << "Could not create IDFT input array" << std::endl;
        delete [] in;

        return;
    }

    fftw_plan plan = fftw_plan_dft_c2r_1d(n, in, out, FFTW_MEASURE);
    if(!plan) {
        std::cerr << "Could not create DFT plan" << std::endl;
        delete [] out;
        delete [] in;

        return;
    }

    // copy input AFTER plan creation!
    for(unsigned int i = 0; i < n_dft; i++) {
        in[i][0] = V[i].real();
        in[i][1] = V[i].imag();
    }

    // execute
    fftw_execute(plan);

    // copy normalized output
    for(unsigned int i = 0; i < n; i++) {
        v.push_back(out[i]/n);
    }

    fftw_destroy_plan(plan);
    delete [] in;
    delete [] out;*/
}

void dsp_xcorr_norm_fft(const timeseries_t& v1, const timeseries_t& v2,
    timeseries_t& out)
{
	cerror << "WARNING: FFT disabled!" << std::endl;

	/*
    const unsigned int n = v1.size() + v2.size();
    const unsigned int n_dft = n/2 + 1;

    const double m_v1 = dsp_mean(v1), m_v2 = dsp_mean(v2);
    const double s_v1 = dsp_var(v1, m_v1), s_v2 = dsp_var(v2, m_v2);

    std::cout << "m_1 = " << m_v1 << std::endl;
    std::cout << "m_2 = " << m_v2 << std::endl;

    std::cout << "s_1 = " << s_v1 << std::endl;
    std::cout << "s_2 = " << s_v2 << std::endl;

    // correlation coeff. denominator
    double denominator = sqrt(s_v1 * s_v2);

    // remove means
    timeseries_t v1_(v1), v2_(v2);

    for(unsigned int i = 0; i < v1_.size(); i++)
        v1_[i] -= m_v1;

    for(unsigned int i = 0; i < v2_.size(); i++)
        v2_[i] -= m_v2;

    // spectrum
    spectrum_t V1, V2;
    timeseries_t out_tmp;

    std::cout << "Performing DFTs...";
    dsp_fft(v1_, V1, n - v1.size());
    dsp_fft(v2_, V2, n - v2.size());
    std::cout << "Done." << std::endl;

    // multiply spectra
    spectrum_t V_xy;
    for(unsigned int i = 0; i < n_dft; i++)
        V_xy.push_back(V1[i] * std::conj(V2[i]));

    std::cout << "Performing IDFT...";
    dsp_ifft(V_xy, out_tmp);
    for(unsigned int i = 0; i < n; i++)
        out_tmp[i] /= denominator;

    out.resize(out_tmp.size(), 0);

    // cyclic shift to center at zero
    for(unsigned int i = 0; i < n; i++)
        out[(i + n/2 - 1) % n] = out_tmp[i];

    std::cout << "Done." << std::endl;*/
}


/**
 * N-1               M-1
 * SUM a(k) y(n-k) = SUM b(k) x(n-k)      for 0 <= n < length(x)
 * k=0               k=0
 *
 *          M-1
 *          SUM d(k) z^(-k)
 *          k=0
 * H(z) = ----------------------
 *           N-1
 *       1 + SUM c(k) z^(-k)
 *           k=1
 *
 * where c(k) = a(k) / a(0), d(k) =  b(k) / a(0)
 */
void dsp_iir(timeseries_t& v, const timeseries_t& b, const timeseries_t& a)
{
    const int n = v.size();

    std::deque<double> qx, qy;

    // init with zeros
    qx.insert(qx.end(), b.size()-1, 0);
    qy.insert(qy.end(), a.size()-1, 0);

    /**
     *                  N-1              M-1
     * y(n) = 1/a(0)(- SUM a(k) y(n-k) + SUM b(k) x(n-k))  for 0 <= n < length(x)
     *                  k=1              k=0
     *
     */
    double y_curr = 0;
    for(int i = 0; i < n; i++) {
        y_curr = 0;
        //std::cout << "y[" << i << "] = ";
        for(int k = 1; k < static_cast<int>(a.size()); k++) {
            y_curr -= a[k] * qy[k-1];
            //std::cout << "-a[" << k << "]*" << qy[k-1] << " ";//y[" << i-k << "] ";
        }

        y_curr += b[0] * v[i];

        //std::cout << "+b[0]*" << v[i] << " "; //x[" << i << "] ";

        for(int k = 1; k < static_cast<int>(b.size()); k++) {
            y_curr += b[k] * qx[k-1];
            //std::cout << "+b[" << k << "]*" << qx[k-1] << " "; //x[" << i-k << "] ";
        }

        y_curr /= a[0];

        //std::cout << " = " << y_curr << std::endl;

        if(b.size() > 1) {
            qx.pop_back();
            qx.push_front(v[i]);
        }

        if(a.size() > 1) {
            qy.pop_back();
            qy.push_front(y_curr);
        }

        v[i] = y_curr;

        //std::copy(qx.begin(), qx.end(), std::ostream_iterator<double>(std::cout, " "));
        //std::cout << std::endl;
    }
}

static inline double dsp_sq(const double x) {
    return x*x;
}

void dsp_movavg(timeseries_t& a, timeseries_t&b, const unsigned int P)
{
    a.clear();
    b.clear();

    a.resize(1, 1);
    b.resize(P, 1.0/static_cast<double>(P));
}


void dsp_chebychev(timeseries_t& a, timeseries_t& b, const double T_s, const double f_cutoff,
	const double ripple, const unsigned int NP, const bool lowpass)
{
	const unsigned int L = 23;
	const double f_c = f_cutoff * T_s;

	if(ripple < 0 || ripple > 29) {
		cerror << "dsp_chebychev(): Ripple must be in range 0 ... 29" << std::endl;
		return;
	}

	if(f_c > 0.5) {
		cerror << "dsp_chebychev(): Cutoff frequency must be <= f_sampling/2" << std::endl;
		return;
	}

	if(NP < 2 || NP > 20 || (NP % 2 != 0)) {
		cerror << "dsp_chebychev(): Pole count must be 2,4,...,20" << std::endl;
		return;
	}

	a.clear();
	b.clear();


	timeseries_t  ta, tb;

	// algorithm adapted from  http://www.dspguide.com/programs.txt, table 20-4
	a.resize(L, 0);
	ta.resize(L, 0);
	b.resize(L, 0);
	tb.resize(L, 0);

	a[2] = b[2] = 1;

	for(unsigned int p = 0; p < NP/2; p++) {
		// unit circle pole coordinates
		double rp = -cos(M_PI/(NP*2) + M_PI*p/NP);
		double ip = sin(M_PI/(NP*2) + M_PI*p/NP);

		// warp circle -> ellipse
		if(ripple != 0) {
			const double es = sqrt(dsp_sq(100.0/(100.0-ripple)) - 1);
			const double vx = 1.0/NP * log(1.0/es + sqrt(dsp_sq(1.0/es) + 1));
			const double kx_exp = 1.0/NP * log(1.0/es + sqrt(dsp_sq(1.0/es) - 1));
			const double kx = 0.5*(exp(kx_exp) + exp(-kx_exp));

			rp *= 0.5*(exp(vx) - exp(-vx))/kx;
			ip *= 0.5*(exp(vx) + exp(-vx))/kx;
		}

		// s -> z-domain
		const double t = 2 * tan(0.5);
		const double t2 = dsp_sq(t);
		const double w = 2*M_PI*f_c;
		const double m = dsp_sq(rp) + dsp_sq(ip);
		double d = 4 - 4*rp*t + m * t2;
		const double x0 = t2/d;
		const double x1 = 2*t2/d;
		const double x2 = t2/d;
		const double y1 = (8- 2*m*t2)/d;
		const double y2 = (-4 - 4*rp*t - m*t2)/d;

		double k = 0;
		
		if(lowpass)
			k = sin(0.5 - w/2) / sin(0.5 + w/2);
		else
			k = -cos(0.5 + w/2) / cos(w/2 - 0.5);
			
		const double k2 = dsp_sq(k);
		d = 1 + y1*k - y2*k2;
		const double b0 = (x0 - x1*k + x2*k2)/d;
		double b1 = (-2*x0*k + x1 + x1*k2 -2*x2*k)/d;
		const double b2 = (x0*k2 - x1*k + x2)/d;
		double a1 = (2*k + y1 + y1*k2 - 2*y2*k)/d;
		const double a2 = (-k2 - y1*k + y2)/d;
		
		if(!lowpass) {
			a1 = -a1;
			b1 = -b1;
		}

		ta = a;
		tb = b;

		for(unsigned int i = 2; i < L; i++) {
			b[i] = b0*tb[i] + b1*tb[i-1] + b2*tb[i-2];
			a[i] = ta[i] - a1*ta[i-1] - a2*ta[i-2];
		}
	}

	// finish combining
	a[2] = 0;
	for(unsigned int i = 0; i < L-2; i++) {
		a[i] = a[i+2];
		b[i] = b[i+2];
	}

	// normalize gain
	double sa = 0, sb = 0;
	
	if(lowpass) {
		for(unsigned int i = 0; i < L-2; i++) {
			sa += -a[i];
			sb += b[i];
		}
	}
	else {
		for(unsigned int i = 0; i < L-2; i++) {
			if(i % 2 == 0) {
				sa += -a[i];
				sb += b[i];
			}
			else {
				sa += a[i];
				sb += -b[i];
			}
			
		}
	}
	

	const double gain = sb/(1-sa);

	for(unsigned int i = 0; i < L-2; i++) {
		b[i] /= gain;
	}

	a[0] = 1;

	// discard superfluous coefficients
	a.resize(NP+1, 0);
	b.resize(NP+1, 0);
}

void dsp_notch(timeseries_t& a, timeseries_t& b, const double T_s, const double f_notch,
    const double Q)
{
	a.clear();
	b.clear();

	// notch radiant frequency
	const double w_dc = 2 * M_PI * f_notch;
	// prewarping factor
	const double c = 1/tan(w_dc * T_s/2);
	// bandwidth
	const double B = 1/Q;

	a.resize(5, 0);
	b.resize(5, 0);

	// fill coefficients
	const double c2 = dsp_sq(c);
	const double c4 = dsp_sq(c2);
	const double B2 = dsp_sq(B);

	a[0] = B2*c2 + sqrt(2)*B*c*(c2+1) + dsp_sq(c2+1);
	a[1] = -2*sqrt(2)*(c2-1)*(B*c + sqrt(2)*c2 + sqrt(2));
	a[2] = -2*(B2*c2 - 3*c4 + 2*c2 - 3);
	a[3] = 2*sqrt(2)*(c2-1)*(B*c - sqrt(2)*(c2+1));
	a[4] = B2*c2 - sqrt(2)*B*c*(c2+1) + dsp_sq(c2+1);

	b[0] = dsp_sq(c2+1);
	b[1] = -4*(c4-1);
	b[2] = 2*(3*c4 - 2*c2 + 3);
	b[3] = -4*(c4-1);
	b[4] = dsp_sq(c2+1);
}

void dsp_windowed_sinc(timeseries_t& a, timeseries_t&b , const double T_s, const double f_cutoff,
	 const unsigned int M, const bool lowpass)
{
	a.clear();
	b.clear();

	a.resize(1, 1);
	a[0] = 1;
	
	const double K = 1;

	const double f_c = f_cutoff * T_s;
	if(f_c > 0.5) {
		cerror << "dsp_windowed_sinc(): Cutoff frequency must be <= f_sampling/2" << std::endl;
		return;
	}

	b.resize(M+1, 0);

	// according to http://www.dspguide.com/ch16/2.htm
	double norm = 0;
	for(int m = 0; m <= static_cast<int>(M); m++) {
		b[m] = K*sin(2*M_PI*f_c*(m-static_cast<int>(M)/2))/(m-static_cast<int>(M)/2);
		
		// uncomment for Blackman window
		//b[m] = K*sin(2*M_PI*f_c*(m-static_cast<int>(M)/2))/(m-static_cast<int>(M)/2) * (0.42 - 0.5*cos(2.0*M_PI*m/M) + 0.08*cos(4.0*M_PI*m/M));
		
		if(m != static_cast<int>(M)/2)
			norm += b[m];
	}
	
	//std::cout << "Norm: " << norm << std::endl;
		
	b[M/2] = K * 2.0 * M_PI * f_c;
	norm += b[M/2];
	
	// normalize
	for(unsigned int m = 0; m < b.size(); m++)
		b[m] /= norm;
		
	// spectral inversion
	if(!lowpass) {
		for(unsigned int m = 0; m < b.size(); m++)
			b[m] = -b[m];
		
		b[M/2] += 1;
	}
}

void dsp_fir_bp(timeseries_t& b, const double T_s, const double f_hp, const double f_lp, const unsigned int M)
{
	timeseries_t b1, b2, a;
	
	// create lowpass filter
	dsp_windowed_sinc(a, b1, T_s, f_lp, M, true);
	
	// lowpass only
	if(f_hp == 0) {
		b = b1;
		return;
	}
	
	// create highpass filter
	dsp_windowed_sinc(a, b2, T_s, f_hp, M, false);
	
	// highpass only
	if(f_lp == 0) {
		b = b2;
		return;
	}
	
	// else: combine to bandpass
	
	b.clear();
	b.resize(M+1, 0);

	// add up to form band-reject filter, and spectrally invert it 
	// for bandpass filter
	for(unsigned int i = 0; i < b1.size() && i < b2.size() && i < b.size(); i++) {
		b[i] = -(b1[i] + b2[i]);
	}
	
	b[M/2] += 1;
}

void dsp_amplify(timeseries_t& a, timeseries_t& b, const double c)
{
	a.clear();
	b.clear();

	a.resize(1, 1);
	b.resize(1, c);
}

void dsp_integrate(timeseries_t& t)
{
	// integration
	for(unsigned int k = 1; k < t.size(); k++) {
		t[k] = t[k] + t[k-1];
	}
}

double dsp_get_dc_block_coeff(const double f_sample, const double f_cut)
{
	// normalized cutoff
	const double Fc = 2.0 * f_cut/f_sample;
	
	// compute coefficient
	return (sqrt(3) -  2 * sin(M_PI * Fc))/(sin(M_PI * Fc) + sqrt(3) * cos(M_PI * Fc));
}

void dsp_dc_block(timeseries_t& x, const double coeff)
{
	// first order IIR dc block (cascaded differentiator and leaky integrator)
	// Difference equation: y(k) = x(k) - x(k-1) + coeff * y(k-1)
	
	// inital conditions
	double x_prev = 0, y_prev = 0, tmp = 0;
	
	for(unsigned int k = 0; k < x.size(); k++) {
		// buffer
		tmp = x[k];
		
		// update
		x[k] = x[k] - x_prev + coeff * y_prev;
		
		// update x(k-1) and y(k-1) values
		x_prev = tmp;
		y_prev = x[k];
	}
}

std::vector<std::pair<unsigned long, double> > dsp_findpeaks(const timeseries_t& t, const double delta, 
	const unsigned long offset, const unsigned long length, const bool omit_max, const bool omit_min)
{
	std::vector<std::pair<unsigned long, double> > peaks;
	
	double min = std::numeric_limits<double>::max();
	double max = -std::numeric_limits<double>::max();
	
	unsigned long max_pos = offset, min_pos = offset;
	bool find_max = true;
	
	const unsigned long end = (offset + length - 1) < t.size() ? (offset + length - 1) : t.size();
	
	for(unsigned long k = offset; k < end; k++) {
		const double curr = t[k];
		
		if(curr > max) {
			max = curr;
			max_pos = k;
		}
		
		if(curr < min) {
			min = curr;
			min_pos = k;
		}
		
		if(find_max) {
			if(curr < max - delta) {
				
				if(!omit_max) {
					peaks.push_back(std::make_pair(max_pos, max));
				}
				
				min = curr;
				min_pos = k;
				find_max = false;
			}
		}
		else {
			if(curr > min + delta) {
				
				if(!omit_min) {
					peaks.push_back(std::make_pair(min_pos, min));
				}
				
				max = curr;
				max_pos = k;
				find_max = true;
			}
		}
	}

	return peaks;
}

std::pair<unsigned int, unsigned int> dsp_find_first_peak(const timeseries_t& t, const double delta,
	const unsigned int offset, const unsigned int length)
{
	std::pair<unsigned int, unsigned int> minmax;
	
	double min = std::numeric_limits<double>::max();
	double max = -std::numeric_limits<double>::max();
	
	unsigned long max_pos = offset, min_pos = offset;
	bool find_max = true, max_found = false, min_found = false;
	
	const unsigned int offset_real = std::min((unsigned long)offset, t.size()-1);
	const unsigned int end = std::min((unsigned long)(offset + length - 1), t.size() - 1);
	
	minmax = std::make_pair(offset_real, end);
	
	for(unsigned int k = offset_real; k <= end; k++) {
		const double curr = t[k];
		
		if(curr > max) {
			max = curr;
			max_pos = k;
		}
		
		if(curr < min) {
			min = curr;
			min_pos = k;
		}
		
		if(find_max) {
			//if(curr < max - delta) {
			if(curr < max - delta) {
				minmax.second = max_pos;
				min = curr;
				min_pos = k;
				find_max = false;
				max_found = true;
				
				// max & min found
				if(min_found) {
					return minmax;
				}
			}
		}
		else {
			if(curr > min + delta) {
				minmax.first = min_pos;
				max = curr;
				max_pos = k;
				find_max = true;
				min_found = true;
				
				// max & min found
				if(max_found) {
					return minmax;
				}
			}
		}
	}
	
	cerror << "Warning: Not found" << std::endl;

	return minmax;
}

timeseries_t dsp_hann_window(const unsigned int N)
{
	timeseries_t window;
	window.resize(N, 0);
	
	for(unsigned int n = 0; n < N; n++)
		window[n] = 0.5 * (1.0 - cos((2*M_PI*n)/(N-1)));
		
	return window;
}

dsp_trace_average::dsp_trace_average(const unsigned long _K) : N(0)
{
    K = _K;
	clear();
}

dsp_trace_average::~dsp_trace_average()
{

}

void dsp_trace_average::update(const timeseries_t& t)
{
	// update trace means and variance helpers
	for(unsigned long k = 0; k < K; k++)
		update_m_M2_var(t[k], mean[k], M2[k], var[k], N);

	// trace counter
	N++;
}

void dsp_trace_average::clear()
{
	mean.clear();
	M2.clear();
	var.clear();

	mean.resize(K, 0);
	var.resize(K, 0);
	M2.resize(K, 0);

	N = 0;
}

const timeseries_t& dsp_trace_average::get_mean() const
{
	return mean;
}

const timeseries_t& dsp_trace_average::get_var() const
{
	return var;
}
