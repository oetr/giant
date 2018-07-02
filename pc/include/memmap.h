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

#ifndef _memmap_h
#define _memmap_h

// WARNING: Always include this last, since it seems to cause errors by
// including windows.h or process.h on WIN32

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <cstdio>

#include <dbgstream.h>
#include <util.h>

#if defined WIN32 || defined _WIN32 || defined WIN64 || defined _WIN64 || defined WINDOWS
#include <windows.h>
#include <process.h>
#else
#include <sys/mman.h>
#include <unistd.h>
#endif

typedef struct {
    void * addr;
    int length;
} mappedRegionS ;

typedef mappedRegionS* mappedRegion;


/**
 * Map a file into the memory of this process.
 * Input parameters:
 *    file:   The name of the file to be mapped.
 *            The file is created if it doesn't exist.
 *    id:     A system wide unique identifier of the mapped region
 *    length: The length of the mapped region.
 *            This parameter is used only if the file doesn't exist, 
 *            otherwise the length of the existing file is used.
 *    overwrite: Overwrite existing files
 * Output parameter:
 *    hReg:   A handle that describes the mapped region.
 * Return value:
 *    0: Successful completion.
 *   -1: An error occured. The cause is specified in the variable errno.  
 *   -2: Not enough memory available.
 *   -3: An error occured. 
 *       The cause may be determined by GetLastError (Windows only).
 **/
int memMap(const std::string file, int id, int length, mappedRegion *hReg,
	const bool overwrite = false);

/** 
 * Unmap a file from the memory 
 * Input parameter:
 *    hReg:   The handle of the mapped region created by memmap
 **/
void memUnmap(mappedRegion *hReg);

/** 
 * Get the (local) address of a mapped region
 * Input parameter:
 *    hReg:   The handle of the mapped region created by memmap
 * Return value:
 *    The address
 **/
char* memGetAddr(mappedRegion *hReg);

/**
 * Get the length of a mapped region
 * Input parameter:
 *    hReg:   The handle of the mapped region created by memmap
 * Return value:
 *    The length in bytes
 **/
int memGetLength(mappedRegion *hReg);

#endif
