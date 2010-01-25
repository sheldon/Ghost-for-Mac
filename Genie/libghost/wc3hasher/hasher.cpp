#include <iostream>
#include <string>
#include "bncsutil.h"
#include "hasher.h"

using namespace std;

// BNCSutil - CheckRevision - GetNumber
#define BUCR_GETNUM(ch) (((ch) == 'S') ? 3 : ((ch) - 'A'))
// BNCSutil - CheckRevision - IsNumber
#define BUCR_ISNUM(ch) (((ch) >= '0') && ((ch) <= '9'))


int checkRevisionInRam(const char* formula, const FileBuffer* const files[], int numFiles, int mpqNumber, unsigned long* checksum)
{
	const static long checkrevision_seeds[] = {0xE7F4CB62, 0xF6A14FFC,0xAA5504AF,0x871FCDC2,0x11BF6A18,0xC57292E6,0x7927D27E,0x2FEC8733};
	
	uint64_t values[4];
	long ovd[4], ovs1[4], ovs2[4];
	char ops[4];
	const char* token;
	int curFormula = 0;

	uint32_t* dwBuf;
	uint32_t* current;
	size_t seed_count;
	
	
	if (!formula || !files || numFiles == 0 || mpqNumber < 0 || !checksum) {
		//bncsutil_debug_message("error: checkRevision() parameter sanity check "
		//	"failed");
		return 0;
	}
	
	seed_count = sizeof(checkrevision_seeds);

	
	if (seed_count <= (size_t) mpqNumber) {
		//bncsutil_debug_message_a("error: no revision check seed value defined "
		//	"for MPQ number %d", mpqNumber);
		return 0;
	}
	
	token = formula;
	while (token && *token) {
		if (*(token + 1) == '=') {
			int variable = BUCR_GETNUM(*token);
			if (variable < 0 || variable > 3) {
				//bncsutil_debug_message_a("error: Unknown revision check formula"
				//	" variable %c", *token);
				return 0;
			}
			
			token += 2; // skip over equals sign
			if (BUCR_ISNUM(*token)) {
				values[variable] = ATOL64(token);
			} else {
				if (curFormula > 3) {
					// more than 4 operations?  bloody hell.
					//bncsutil_debug_message("error: Revision check formula"
					//	" contains more than 4 operations; unsupported.");
					return 0;
				}
				ovd[curFormula] = variable;
				ovs1[curFormula] = BUCR_GETNUM(*token);
				ops[curFormula] = *(token + 1);
				ovs2[curFormula] = BUCR_GETNUM(*(token + 2));
				curFormula++;
			}
		}
		
		for (; *token != 0; token++) {
			if (*token == ' ') {
				token++;
				break;
			}
		}
	}
	
	// Actual hashing (yay!)
	// "hash A by the hashcode"
	values[0] ^= checkrevision_seeds[mpqNumber];
	
	for (int i = 0; i < numFiles; i++) {
		size_t buffer_size;
		
		buffer_size = files[i]->buffer_size;

		dwBuf = (uint32_t*)files[i]->file_buffer;
		current = dwBuf;
		
		for (size_t j = 0; j < buffer_size; j += 4) {
			values[3] = LSB4(*(current++));
			for (int k = 0; k < curFormula; k++) {
				switch (ops[k]) {
					case '+':
						values[ovd[k]] = values[ovs1[k]] + values[ovs2[k]];
						break;
					case '-':
						values[ovd[k]] = values[ovs1[k]] - values[ovs2[k]];
						break;
					case '^':
						values[ovd[k]] = values[ovs1[k]] ^ values[ovs2[k]];
						break;
					case '*':
						// well, you never know
						values[ovd[k]] = values[ovs1[k]] * values[ovs2[k]];
						break;
					case '/':
						// well, you never know
						values[ovd[k]] = values[ovs1[k]] / values[ovs2[k]];
						break;
					default:
						return 0;
				}
			}
		}
	}

	*checksum = (unsigned long) LSB4(values[2]);
	return 1;
}

