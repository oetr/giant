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

#ifndef _util_h
#define _util_h

// C++ includes
#include <algorithm>
#include <string>
#include <iostream>
#include <sstream>
#include <fstream>
//#include <cctype>
#include <iomanip>
#include <bitset>
#include <vector>

// C includes
//#include <sys/types.h>
//#include <ctypes>
#include <fcntl.h>
//#include <unistd.h>
#include <errno.h>
#include <sys/time.h>
#include <sys/stat.h>
#include <time.h>
#include <cstdlib>
//#include <cstdio>
#include <cstring>
#include <inttypes.h>

// Project includes
#include <dbgstream.h>

/**
 * Round double->int
 * @param x Value to round
 * @return round(x)
 */
inline int round_to_int(double x)
{
   return int(x > 0.0 ? x + 0.5 : x - 0.5);
};

/**
 * Template to convert type from string via stringstream
 * @param src String to convert
 * @return Conversion result
 */
template<typename TTarget> 
TTarget from_string(const std::string& src) {
	std::stringstream ss;
	ss << src;
	
	TTarget result;
	ss >> result;
	
	if(!ss.eof()) {
		cerror << "from_string(): Conversion from string failed" << std::endl;
	}
	
	return result;
};

/**
 * Template to convert type to string via stringstream
 * @param src Value to convert
 * @return Conversion result
 */
template<typename TSrc> 
std::string to_string(const TSrc& src) {
	std::stringstream ss;
	ss << src;
	
	if(ss.eof()) {
		cerror << "to_string(): Conversion to string failed" << std::endl;
	}
	
	return ss.str();
};

/**
 * Tristate logic boolean values
 */
typedef enum {
	TRISTATE_FALSE, TRISTATE_TRUE, TRISTATE_DONT_CARE
} tristate_t;

/**
 * Macro to simplify ini-name construction
 */
#define ININAME(x, y) ((x) + ":" + (y)).c_str()

/**
 * Byte array type
 */
typedef std::vector<uint8_t> byte_buffer_t;

/**
 * @brief Collection class for several utility functions
 */
class util
{
	public:
		/**
		 * Convert string to lowercase
		 * @param s Reference to string to convert
		 * @return Converted string
		 */
		static std::string tolower(std::string& s) 
		{
			std::string result = s;
			std::transform(result.begin(), result.end(), result.begin(), (int(*)(int)) std::tolower);
			return result;
		};
		
		/**
		 * Convert string to bool
		 * @param s String to convert
		 * @return true if s == true
		 */
		static bool string_to_bool(std::string s) 
		{
			s = util::tolower(s);
			
			if(s == "true")
				return true;
			else
				return false;
		};
		
		/**
		 * Convert string to tristate
		 * @param s String to convert
		 * @return true if s == true, false if s == false, otherwise dont_care
		 */
		static tristate_t string_to_tristate(std::string s) 
		{
			s = util::tolower(s);
			
			if(s == "true")
				return TRISTATE_TRUE;
			else if(s == "false")
				return TRISTATE_FALSE;
			else	
				return TRISTATE_DONT_CARE;
		};
		
		/**
		 * Convert tristate to string
		 * @param t Tristate to convert
		 * @return String representation of t
		 */
		static const std::string tristate_to_string(const tristate_t& t) 
		{
			const std::string to_str[3] = {
				"false", "true", "dont_care"
			};
			
			const unsigned int pos = static_cast<unsigned int>(t);
			const std::string result = pos < 3 ? to_str[pos] : "conversion_error";
			
			return result;
		};
		
		/**
		 * Get current timer in seconds
		 * @return Timestamp in seconds
		 */
		static double get_timer() 
		{
			timeval t;
			gettimeofday(&t, 0);

			return (double)t.tv_sec  + ((double)t.tv_usec) * 1e-6;
		}
		
		/**
		 * Get date-time string
		 * @return String with date-time
		 */
		static std::string get_datetime() 
		{
			time_t rawtime;
			struct tm * timeinfo;

			time (&rawtime);
			timeinfo = localtime (&rawtime);
			
			std::string result = asctime(timeinfo);
			
			return result;
		};
		
		/**
		 * Get string with date-time according to special format
		 * @param format Format string to use with strftime()
		 * @return String with formatted date-time
		 */
		static std::string get_formatted_time(const std::string format) 
		{
			time_t rawtime;
			struct tm * timeinfo;

			time (&rawtime);
			timeinfo = localtime (&rawtime);
			
			char buffer[80];
			
			strftime(buffer, 80, format.c_str(), timeinfo);
			
			return std::string(buffer);
		}
		
		/**
		 * Check file existence
		 * @param path Path to file
		 * @return true if file exists, otherwise false
		 */
		static bool file_exists(const std::string path) 
		{
			bool exists = false;
			std::fstream fin;
			
			fin.open(path.c_str(), std::ios::in);
			if(fin.is_open()) {
				exists = true;
			}
			fin.close();
			
			return exists;
		};
		
		/**
		 * Check directory existence
		 * @param path Path
		 * @return true if dir exists, otherwise false
		 */
		static bool dir_exists(const std::string path) 
		{
			struct stat stat_buf;
			
			int res = stat(path.c_str(), &stat_buf);
			if (res >= 0) {
				return true;
			}
			else {
				return false;
			}
		};

		/**
		 * Create directory
		 * @param dir String with path to directory to create
		 */
		static void make_dir(const std::string dir) 
		{
			std::cout << "Make " << dir << std::endl;
			
			int stat = mkdir(dir.c_str(), S_IRUSR | S_IWUSR | S_IXUSR);

			if(stat < 0) {
				cerror << "util::make_dir(): Could not make " << dir << "'" << std::endl;
				cerror << "ErrorCode: " << std::dec << errno << " = " << strerror(errno) << std::endl;
			}
			else {
				clog << "util::make_dir(): Directory '" << dir << "' made" << std::endl;
			}
		};
		
		/**
		 * Map cygwin to windows path
		 **/
		static std::string map_to_windows_path(const std::string path) 
		{
#ifndef WIN32
			return path;
#else
			std::string result;
			const std::string pattern = "/cygdrive/";
			
			if(path.size() > pattern.size() + 1) {
				// check if string starts with pattern
				if(path.substr(0, pattern.size()) == pattern) {
					// remove pattern, change drive letter sytax
					const std::string driveLetter = path.substr(pattern.size(), 1);
					result = driveLetter + ":\\" + path.substr(pattern.size() + 1);
				}
				else {
					result = path;
				}
			}
			else {
				result = path;
			}
			
			// replace / with backslash
			std::replace(result.begin(), result.end(), '/', '\\');
			
			return result;
#endif
		};
		
		/**
		 * Dump HEX array
		 * @param s Ostream to dump to
		 * @param buf Array to dump
		 * @param length Number of bytes to dump
		 */
		static void hexdump(std::ostream& s, const uint8_t* buf, const unsigned int length) 
		{
			for(unsigned int i = 0; i < length; i++) 
			{
				s << std::setw(2) << std::setfill('0') << std::hex << static_cast<unsigned int>(buf[i]) << " ";
			}
		};
		
		/**
		  * Dump 8 bit hex buffer
		  * @param o Stream to write to
		  * @param buf Buffer to dump
		  * @param num_per_row Number of digits to print newline after, 0 for all
		  *                    in one line, with address printing
		  * @param addr_offset Optional offset when printing adresses (num_per_row != 0)
		  */
		static void hexdump(std::ostream& o, const byte_buffer_t& buf,
			const unsigned int num_per_row = 0, const uint32_t addr_offset = 0)
		{
			if(num_per_row > 0) 
			{
				o << u32hs(addr_offset, true) << " ";
			}
			
			for(unsigned int i = 0; i < buf.size(); i++) 
			{
				o << util::u8hs(buf[i]) << " ";
				
				if(num_per_row > 0 && ((i+1) % num_per_row) == 0)
				{
					o << std::endl;
					o << u32hs(i+1+addr_offset, true) << " ";
				}
			}
		};
		
		static void hexdump(std::ostream& o, const std::vector<uint32_t>& buf,
			const unsigned int num_per_row = 0, const uint32_t addr_offset = 0)
		{
			if(num_per_row > 0) 
			{
				o << u32hs(addr_offset, true) << " ";
			}
			
			for(unsigned int i = 0; i < buf.size(); i++) 
			{
				o << util::u32hs(buf[i]) << " ";
				
				if(num_per_row > 0 && ((i+1) % num_per_row) == 0)
				{
					o << std::endl;
					o << u32hs(i+1+addr_offset, true) << " ";
				}
			}
		};
		
		/**
		 * Convert byte to hex string
		 * @param v Value to convert
		 * @param with_0x Add 0x prefix?
		 * @return Hex string
		 */
		static std::string u8hs(const uint8_t v, const bool with_0x = false) 
		{
			std::stringstream ss;
			
			if(with_0x) {
				ss << "0x";
			}
			
			ss << std::setw(2) << std::setfill('0') << std::hex << static_cast<unsigned int>(v);
			return ss.str();
		};

		/**
		 * Reverse bit order in byte
		 * @param v Value to reverse
		 * @return Bit-reversed v
		 */
		static uint8_t bitreverse(const uint8_t v) 
		{
			return static_cast<uint8_t>(((v * 0x0802LU & 0x22110LU) | (v * 0x8020LU & 0x88440LU)) * 0x10101LU >> 16); 
		};
		
		/**
		 * Convert byte to bit string
		 * @param v Value to convert
		 * @return Bit string
		 */
		static std::string u8bs(const uint8_t v) 
		{
			std::string result = "00000000";
			
			for(unsigned int i = 0; i < 8; i++) {
				if(v & (1 << i)) {
					result[7 - i] = '1';
				}
			}
			
			return result;
		};

		/**
		 * Convert word to hex string
		 * @param v Value to convert
		 * @param with_0x Add 0x prefix?
		 * @return Hex string
		 */
		static std::string u16hs(const uint16_t v, const bool with_0x = false) 
		{
			std::stringstream ss;
			
			if(with_0x) {
				ss << "0x";
			}
			
			ss << std::setw(4) << std::setfill('0') << std::hex << static_cast<unsigned int>(v);
			return ss.str();
		};
		
		/**
		 * Convert word to hex string
		 * @param v Value to convert
		 * @param with_0x Add 0x prefix?
		 * @return Hex string
		 */
		static std::string u32hs(const uint32_t v, const bool with_0x = false) 
		{
			std::stringstream ss;
			
			if(with_0x) {
				ss << "0x";
			}
			
			ss << std::setw(8) << std::setfill('0') << std::hex << static_cast<unsigned int>(v);
			return ss.str();
		};

		/**
		 * Convert word to bit string
		 * @param v Value to convert
		 * @return Bit string
		 */
		static std::string u16bs(const uint16_t v) 
		{
			std::string result = "0000000000000000";
			
			for(unsigned int i = 0; i < 16; i++) {
				if(v & (1 << i)) {
					result[15 - i] = '1';
				}
			}
			
			return result;
		};
		
		/**
		 * Convert word to bit string
		 * @param v Value to convert
		 * @return Bit string
		 */
		static std::string u32bs(const uint32_t v) 
		{
			std::string result = "00000000000000000000000000000000";
			
			for(unsigned int i = 0; i < 32; i++) {
				if(v & (1 << i)) {
					result[15 - i] = '1';
				}
			}
			
			return result;
		};
		
		/**
		 * Convert hex string to vector<bitset<8>>
		 * @param in Hex string
		 * @param byte_cnt Number of bytes to convert
		 * @return Vector of bitset<8>
		 */
		static std::vector< std::bitset<8> > string_to_bytevec(std::string in, const unsigned int byte_cnt) 
		{
			std::vector< std::bitset<8> > result;
			result.resize(byte_cnt, 0);
			
			in = util::tolower(in);
	
			std::stringstream s_conv;
			s_conv << in;
			for(unsigned int i = 0; i < byte_cnt; i++) {
				unsigned int byte = 0;
				s_conv >> std::hex >> byte;
				
				result[i] = static_cast<uint8_t>(byte);
			}
			
			return result;
		};
		
		/**
		  * Dump 16 bit hex buffer
		  * @param o Stream to write to
		  * @param buf Buffer to dump
		  */
		static void hexdump(std::ostream& o, const std::vector<uint16_t>& buf)
		{
			for(unsigned int i = 0; i < buf.size(); i++) 
			{
				o << util::u16hs(buf[i]) << " ";
			}
		};
};

#endif
