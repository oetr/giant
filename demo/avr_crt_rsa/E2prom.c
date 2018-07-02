//  Simple Operating system for Smart cards
//  Copyright (C) 2002  Matthias Bruestle <m@mbsks.franken.de>
// 
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
// 
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
// 
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

void		  Seqxewrt(unsigned int dst, unsigned char *src, unsigned int len);
unsigned char xeread(unsigned int addr );

void          IntE2wrt(unsigned int addr, unsigned char b );
unsigned char IntE2read(unsigned int addr );



void WriteinExE2prom(unsigned int dst, unsigned char *src, unsigned int len)
{
	Seqxewrt(dst, src, len);
}


void ReadfromExE2prom(unsigned int src, unsigned char *dst, unsigned int len)
{
	while (len--)
	{
		*dst++ = xeread(src);
		src++;
	}
}

void WriteinIntE2prom(unsigned int dst, unsigned char *src, unsigned int len)
{

	while (len--)
	{
		IntE2wrt(dst, *src++);
		dst++;
	} 
}

void ReadfromIntE2prom(unsigned int src, unsigned char *dst, unsigned int len)
{
	while (len--)
	{
		*dst++ = IntE2read(src);
		src++;
	}
}
