#ifndef HASHER_H
#define HASHER_H

#include <string>

typedef struct FileBuffer
{
	uint8_t* file_buffer;
	size_t buffer_size;
} FileBuffer;
int checkRevisionInRam(const char* formula, const FileBuffer* const files[], int numFiles, int mpqNumber, unsigned long* checksum);
#endif
