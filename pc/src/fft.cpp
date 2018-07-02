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

#include "fft.h"

fft::fft(const unsigned int size) : inited(false), N(size), in(0), out(0), plan(0), inverse_plan(0)
{
	set_n(size);
}

fft::~fft()
{
	cleanup();
}

bool fft::set_n(const unsigned int size)
{
	if(size > 0 && (N != size || !inited)) {
		cleanup();
		N = size;
		
		clog << "fft::set_n(): New N = " << std::dec << N << std::endl;
		
		in = new double[N];
		out = new fftw_complex[N/2 + 1];
		plan = fftw_plan_dft_r2c_1d(N, in, out, FFTW_MEASURE);
		inverse_plan = fftw_plan_dft_c2r_1d(N, out, in, FFTW_MEASURE);
		
		if(!in || !out || !plan || !inverse_plan) {
			cleanup();
			cerror << "fft::set_n(): FFT init failed" << std::endl;
			
			return false;
		}
		
		memset(in, 0, N*sizeof(double));
		
		inited = true;
	}
	
	return true;
}

bool fft::transform(const timeseries_t& v, spectrum_t& V)
{
	V.clear();
	
	if(!inited) {
		cerror << "fft::transform(): FFT not inited" << std::endl;
		return false;
	}
	
	const unsigned int N_dft = N/2 + 1;
	
	if(v.size() > N) {
		cerror << "fft::transform(): Truncating timeseries" << std::endl;
	}
	
	// copy input
	for(unsigned int i = 0; i < std::min((unsigned int)v.size(), N); i++)
		in[i] = v[i];
		
	if(N > v.size())
		clog << "fft::transform(): Zero padding" << std::endl;
		
	// eventually zero-pad
	for(unsigned int i = v.size(); i < N; i++) {
		//cerror << "fft::transform(): Zero padding" << std::endl;
		in[i] = 0;
	}
	
	// transform
	in_to_out();
	
	// copy output
	for(unsigned int i = 0; i < N_dft; i++) {
		complex_t tmp(out[i][0]/N, out[i][1]/N);
		V.push_back(tmp);
	}
	
	return true;
}

bool fft::inverse_transform(const spectrum_t& V, timeseries_t& v)
{
	v.clear();
	
	if(!inited) {
		cerror << "fft::inverse_transform(): FFT not inited" << std::endl;
		return false;
	}
	
	const unsigned int N_dft = N/2 + 1;
	
	if(V.size() > N_dft) {
		cerror << "fft::inverse_transform(): Truncating timeseries" << std::endl;
	}
	
	// copy input
	for(unsigned int i = 0; i < std::min((unsigned int)V.size(), N_dft); i++)
	{
		out[i][0] = V[i].real();
		out[i][1] = V[i].imag();
	}
	
	// eventually zero-pad
	for(unsigned int i = V.size(); i < N_dft; i++) {
		out[i][0] = 0;
		out[i][1] = 0;
	}
	
	// inverse transform
	out_to_in();
	
	// copy output
	for(unsigned int i = 0; i < N; i++) {
		v.push_back(in[i]);
	}
	
	return true;
}

void fft::cleanup()
{
	if(plan)
		 fftw_destroy_plan(plan);
	if(inverse_plan)
		 fftw_destroy_plan(inverse_plan);
	if(in)
		delete [] in;
	if(out)
		delete [] out;
	
	inited = false;
}

void fft::in_to_out()
{
	fftw_execute(plan);
}

void fft::out_to_in()
{
	fftw_execute(inverse_plan);
}

bool fft::psd(const timeseries_t& v, timeseries_t& sd)
{	
	if(!inited) {
		cerror << "fft::psd(): FFT not inited" << std::endl;
		return false;
	}
	
	const unsigned int N_dft = N/2 + 1;
	
	if(v.size() > N) {
		cerror << "fft::psd(): Truncating timeseries" << std::endl;
	}
	
	// copy input
	for(unsigned int i = 0; i < std::min((unsigned int)v.size(), N); i++)
		in[i] = v[i];
		
	// eventually add zero padding
	for(unsigned int i = v.size(); i < N; i++)
		in[i] = 0;
	
	// transform
	in_to_out();
	
	// prepare output
	sd.clear();
	sd.resize(N_dft, 0);
	
	// copy output
	for(unsigned int i = 0; i < N_dft; i++) {
		// assign squared magnitude, normalized
		sd[i] = (out[i][0]*out[i][0] + out[i][1]*out[i][1])/(N*N);
	}
	
	return true;
}

