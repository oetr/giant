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

#include "memmap.h"

int memMap(const std::string file, int id, int length, mappedRegion *hReg,
	const bool overwrite)
{
    struct stat stat_buf;
    int res;
    unsigned int i;
    int exists = 1;
    char buffer[1024];
	
#ifdef _WIN32
    PSECURITY_DESCRIPTOR pSD;
    HANDLE hFile, hMem;
    SECURITY_ATTRIBUTES  sa;
    DWORD sz;
	
	std::string path = util::map_to_windows_path(file);
#else
    int fdes;
	std::string path = file;
#endif

    mappedRegion reg = (mappedRegion)calloc(1, sizeof(mappedRegionS));
    if (NULL == reg) {
		cerror << "memMap(): Could not alloc" << std::endl;
		return -3;
	}
	
    *hReg = reg;

    /* check if file already exists and determine its length */
    res = stat( path.c_str(), &stat_buf);
    if (res < 0) {
        if (errno == ENOENT) exists = 0;
        else return -1;
    }
	
    if (exists && !overwrite) 
		reg->length = stat_buf.st_size;
    else 
		reg->length = length;

#ifdef _WIN32
    /* create security descriptor (needed for Windows NT) */
    pSD = (PSECURITY_DESCRIPTOR) calloc(1, SECURITY_DESCRIPTOR_MIN_LENGTH );
    if( pSD == NULL ) return -2;

    InitializeSecurityDescriptor(pSD, SECURITY_DESCRIPTOR_REVISION);
    SetSecurityDescriptorDacl(pSD, TRUE, (PACL) NULL, FALSE);

    sa.nLength = sizeof(sa);
    sa.lpSecurityDescriptor = pSD;
    sa.bInheritHandle = TRUE;

    /* create or open file */
    if (exists && !overwrite) {
        hFile = CreateFile(path.c_str(), GENERIC_READ | GENERIC_WRITE,
            FILE_SHARE_READ | FILE_SHARE_WRITE, &sa, OPEN_EXISTING,
            FILE_ATTRIBUTE_NORMAL, NULL);
    }
    else {
        hFile = CreateFile(path.c_str(), GENERIC_READ | GENERIC_WRITE,
            FILE_SHARE_READ | FILE_SHARE_WRITE, &sa, CREATE_ALWAYS,
            FILE_ATTRIBUTE_NORMAL, NULL);
    }
    if (hFile == INVALID_HANDLE_VALUE) {
        free(pSD);
		cerror << "memMap(): Could not open file '" << path << "'" << std::endl;
        return -3;
    }
    if (!(exists && !overwrite)) {
        /* ensure that file is long enough and filled with zero */
        memset(buffer, 0, sizeof(buffer));
        for (i = 0; i < reg->length/sizeof(buffer); ++i) {
            if (!WriteFile(hFile, buffer, sizeof(buffer), &sz, NULL)) {
				cerror << "memMap(): Could not write" << std::endl;
				cerror << "getLastError():" << std::hex << GetLastError() << std::endl;
                return -3;
            }
        }
        if (!WriteFile(hFile, buffer, reg->length % sizeof(buffer), &sz, NULL)) {
			cerror << "memMap(): Could not write" << std::endl;
			cerror << "getLastError():" << std::hex << GetLastError() << std::endl;
            return -3;
        }
    }
        
    /* create file mapping */
    sprintf(buffer, "_MEMMAP_REGION_%d", id);
    hMem = CreateFileMapping(hFile, &sa, PAGE_READWRITE, 0,
            reg->length, buffer);
    free(pSD);
    if (NULL == hMem) {
		cerror << "memMap(): Could not create mapping" << std::endl;
		return -3;
	}

    /* map the file to memory */
    reg->addr = MapViewOfFile(hMem, FILE_MAP_ALL_ACCESS, 0, 0, 0);
    if (NULL == reg->addr) {
		cerror << "memMap(): Could not map view" << std::endl;
		return -3;
	}

    CloseHandle( hFile);
    CloseHandle( hMem);

#else
    /* UNIX */
    if (exists && !overwrite) {
        /* open mapped file */
        fdes = open(path.c_str(), O_RDWR, S_IRUSR | S_IWUSR);
        if (fdes < -1) return -1;
    }
    else /* not exists or overwrite */ {
        /* create mapped file */
        fdes = open(path.c_str(), O_RDWR | O_CREAT, S_IRUSR | S_IWUSR);
        if (fdes < -1) 
			return -1;
        /* ensure that file is long enough and filled with zero */
        memset( buffer, 0, sizeof(buffer));
        for (i = 0; i < reg->length/sizeof(buffer); ++i) {
            if (write( fdes, buffer, sizeof(buffer)) != sizeof(buffer)) {
                return -1;
            }
        }
        if (write( fdes, buffer, reg->length % sizeof(buffer)) != reg->length % sizeof(buffer)) {
            return -1;
        }
    }

    /* map the file to memory */
    reg->addr = mmap(NULL, reg->length,
        PROT_READ | PROT_WRITE, MAP_SHARED, fdes, 0);
		
    close(fdes);
	
    if (reg->addr == (void *)-1) 
		return -1;
#endif

    return 0;
}

void memUnmap(mappedRegion* hReg)
{
    mappedRegion reg = *hReg;
    if (reg) {
#ifdef _WIN32
        if (reg->addr) {
            UnmapViewOfFile(reg->addr);
        }
#else
        if (reg->addr) {
            munmap(reg->addr, reg->length);
        }
#endif
        free(reg);
    }
    *hReg = 0;
}

char* memGetAddr(mappedRegion* hReg)
{
    return (char *)((*hReg)->addr);
}

int memGetLength(mappedRegion* hReg)
{
    return (*hReg)->length;
}
