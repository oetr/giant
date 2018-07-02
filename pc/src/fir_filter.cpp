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

#include "fir_filter.h"

fir_filter::fir_filter(const timeseries_t& coeff) : in(0), out(0), filter_coeff(0),
	plan_fft(0), plan_ifft(0), inited(false)
{
	// compute filter coeff in freq domain
	N = coeff.size();
	M = 2*coeff.size() - 1;
	M_fft = M/2 + 1;
	
	in = new double[M];
	filter_coeff = new fftw_complex[M_fft];
	out = new fftw_complex[M_fft];
	
	plan_fft = fftw_plan_dft_r2c_1d(M, in, out, FFTW_MEASURE);
	plan_ifft = fftw_plan_dft_c2r_1d(M, out, in, FFTW_MEASURE);
	
	if(!in || !filter_coeff || !plan_fft || !plan_ifft || !out) {
		cerror << "fir_filter::fir_filter(): FFT init failed" << std::endl;
	}
	else {
		// zero out
		memset(in, 0, M*sizeof(double));
		
		// copy to array
		std::copy(coeff.begin(), coeff.end(), in);
	
		// transform
		fftw_execute(plan_fft);
		
		// copy
		for(unsigned int i = 0; i < M_fft; i++) {
			filter_coeff[i][0] = out[i][0];
			filter_coeff[i][1] = out[i][1];
		}
		
		inited = true;
	}
}

fir_filter::~fir_filter()
{
	if(plan_fft)
		 fftw_destroy_plan(plan_fft);
	if(plan_ifft)
		 fftw_destroy_plan(plan_ifft);
	if(in)
		delete [] in;
	if(out)
		delete [] out;
	if(filter_coeff)
		delete [] filter_coeff;
}


void fir_filter::filter(const timeseries_t& v, timeseries_t& output)
{
	if(!inited) {
		cerror << "fir_filter::filter(): FFT not inited" << std::endl;
		return;
	}
	
	// resize output
	output.resize(v.size() + N - 1, 0);
	// zero output
	std::fill(output.begin(), output.end(), 0);
	
	const unsigned int N_v = v.size();
	
	// number of overlap-add blocks
	// const unsigned int blocks = N_v/N; 
	
	// size of final block
	const unsigned int final_block_size = N_v % N;
	
	//clog << std::dec << blocks << " blocks + " << final_block_size << " final samples" << std::endl;
	
	timeseries_t::const_iterator it_block = v.begin();
	unsigned int block_len = 0;
	for(unsigned int block_begin = 0; block_begin < N_v; block_begin += N) 
	{
		// block end
		block_len = (block_begin + N < N_v) ? N : final_block_size;
		
		//std::cout << "Length " << block_len << std::endl;
		
		// copy
		std::copy(it_block, it_block + block_len, in);

		// zero pad		
		std::fill(in + block_len, in + M, 0);
		
		// transform block
		fftw_execute(plan_fft);
		
		// complex multiply in frequency domain
		double re_re, im_im, re_im, im_re;
		for(unsigned int i = 0; i < M_fft; i++) {
			re_re = out[i][0] * filter_coeff[i][0];
			re_im = out[i][0] * filter_coeff[i][1];
			im_re = out[i][1] * filter_coeff[i][0];
			im_im = out[i][1] * filter_coeff[i][1];
			out[i][0] = re_re - im_im;
			out[i][1] = re_im + im_re;	
		}
		
		// transform back
		fftw_execute(plan_ifft);
		
		// add overlapping blocks, normalize ifft data
		for(unsigned int i = 0; i < N + block_len - 1; i++) {
			output[i + block_begin] += in[i]/M;
		}
		
		// next block
		it_block += N;
	}
}
