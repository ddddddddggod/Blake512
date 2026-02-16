// blake_Test.cpp : 콘솔 응용 프로그램에 대한 진입점을 정의합니다.
//

#include "stdafx.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <ctype.h>

#include "blake.h"

#include "pt_debug.h"

#pragma warning(disable : 4996) 

FILE *gfp_out;

void fprintBstr(FILE *fp, char *S, unsigned char *A, int L)
{
	int	i;

	fprintf(fp, "%s", S);

	for ( i=0; i<L; i++ )
		fprintf(fp, "%02X", A[i]);

	if ( L == 0 )
		fprintf(fp, "00");

	fprintf(fp, "\n");
}

static const unsigned long long IV512[8] = {
	0x6A09E667F3BCC908, 0xBB67AE8584CAA73B,
	0x3C6EF372FE94F82B, 0xA54FF53A5F1D36F1,
	0x510E527FADE682D1, 0x9B05688C2B3E6C1F,
	0x1F83D9ABFB41BD6B, 0x5BE0CD19137E2179
};

static const unsigned int sigma[16][16] = {
	{  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15 },
	{ 14, 10,  4,  8,  9, 15, 13,  6,  1, 12,  0,  2, 11,  7,  5,  3 },
	{ 11,  8, 12,  0,  5,  2, 15, 13, 10, 14,  3,  6,  7,  1,  9,  4 },
	{  7,  9,  3,  1, 13, 12, 11, 14,  2,  6,  5, 10,  4,  0, 15,  8 },
	{  9,  0,  5,  7,  2,  4, 10, 15, 14,  1, 11, 12,  6,  8,  3, 13 },
	{  2, 12,  6, 10,  0, 11,  8,  3,  4, 13,  7,  5, 15, 14,  1,  9 },
	{ 12,  5,  1, 15, 14, 13,  4, 10,  0,  7,  6,  3,  9,  2,  8, 11 },
	{ 13, 11,  7, 14, 12,  1,  3,  9,  5,  0, 15,  4,  8,  6,  2, 10 },
	{  6, 15, 14,  9, 11,  3,  0,  8, 12,  2, 13,  7,  1,  4, 10,  5 },
	{ 10,  2,  8,  4,  7,  6,  1,  5, 15, 11,  9, 14,  3, 12, 13,  0 },
	{  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15 },
	{ 14, 10,  4,  8,  9, 15, 13,  6,  1, 12,  0,  2, 11,  7,  5,  3 },
	{ 11,  8, 12,  0,  5,  2, 15, 13, 10, 14,  3,  6,  7,  1,  9,  4 },
	{  7,  9,  3,  1, 13, 12, 11, 14,  2,  6,  5, 10,  4,  0, 15,  8 },
	{  9,  0,  5,  7,  2,  4, 10, 15, 14,  1, 11, 12,  6,  8,  3, 13 },
	{  2, 12,  6, 10,  0, 11,  8,  3,  4, 13,  7,  5, 15, 14,  1,  9 }
};

#define CB0   0x243F6A8885A308D3
#define CB1   0x13198A2E03707344
#define CB2   0xA4093822299F31D0
#define CB3   0x082EFA98EC4E6C89
#define CB4   0x452821E638D01377
#define CB5   0xBE5466CF34E90C6C
#define CB6   0xC0AC29B7C97C50DD
#define CB7   0x3F84D5B5B5470917
#define CB8   0x9216D5D98979FB1B
#define CB9   0xD1310BA698DFB5AC
#define CBA   0x2FFD72DBD01ADFB7
#define CBB   0xB8E1AFED6A267E96
#define CBC   0xBA7C9045F12C7F99
#define CBD   0x24A19947B3916CF7
#define CBE   0x0801F2E2858EFC16
#define CBF   0x636920D871574E69

static const unsigned long long CB[16] = {
	CB0, CB1, CB2, CB3, CB4, CB5, CB6, CB7,
	CB8, CB9, CBA, CBB, CBC, CBD, CBE, CBF
};
unsigned int bswap32(unsigned int x)
{
	x = ((x << 16) | (x >> 16)) & 0xFFFFFFFF;
	x = ((x & 0xFF00FF00) >> 8) | ((x & 0x00FF00FF) << 8);
	return x;
}
unsigned long long bswap64(unsigned long long x)
{
	x = ((x << 32) | (x >> 32)) & 0xFFFFFFFFFFFFFFFF;
	x = ((x & 0xFFFF0000FFFF0000) >> 16) | ((x & 0x0000FFFF0000FFFF) << 16);
	x = ((x & 0xFF00FF00FF00FF00) >> 8) | ((x & 0x00FF00FF00FF00FF) << 8);
	return x;
}
void enc64be_aligned(void *dst, unsigned long long val)
{
	*(unsigned long long *)dst = bswap64(val);
}
unsigned long long dec64be_aligned(const void *src)
{
	return bswap64(*(const unsigned long long *)src);
}void enc64be(void *dst, unsigned long long val)
{
	val = bswap64(val);

	*(unsigned long long *)dst = val;
}

#define ROTL64(x, n)   (((x) << (n)) | ((x) >> (64 - (n)))) & 0xFFFFFFFFFFFFFFFF
#define ROTR64(x, n)   ROTL64(x, (64 - (n)))
void GB(unsigned long long m0, unsigned long long m1, unsigned long long c0, unsigned long long c1, 
		unsigned long long *a, unsigned long long *b, unsigned long long *c, unsigned long long *d)
{

	static int i = 0;
#if 1
	printf(" ---------- round = %d  GB  = %d\n", (i/8), (i%8)); i++;
	printf("m0 = %08X.%08X ",  (unsigned int)(m0 >> 32),(unsigned int)m0);
	printf("c0 = %08X.%08X \n",(unsigned int)(c0 >> 32),(unsigned int)c0);
	printf("m1 = %08X.%08X ",  (unsigned int)(m1 >> 32),(unsigned int)m1);
	printf("c1 = %08X.%08X \n",(unsigned int)(c1 >> 32),(unsigned int)c1);
	printf("a  = %08X.%08X ",  (unsigned int)(*a >> 32),(unsigned int)*a);
	printf("b  = %08X.%08X \n",(unsigned int)(*b >> 32),(unsigned int)*b);
	printf("c  = %08X.%08X ",  (unsigned int)(*c >> 32),(unsigned int)*c);
	printf("d  = %08X.%08X \n",(unsigned int)(*d >> 32),(unsigned int)*d);
	//printf(" %08X.%08X ",(unsigned int)((m0^c1) >> 32),(unsigned int)(m0^c1));
	getchar();
#endif

	*a = (*a + *b + (m0 ^ c1)) & 0xFFFFFFFFFFFFFFFF;
	*d = ROTR64(*d ^ *a, 32);
	*c = (*c + *d) & 0xFFFFFFFFFFFFFFFF;
	*b = ROTR64(*b ^ *c, 25);

#if 1
	printf(" a = %08X.%08X \n",(unsigned int)(*a >> 32),(unsigned int)(*a));
	printf(" b = %08X.%08X \n",(unsigned int)(*b >> 32),(unsigned int)(*b));
	printf(" c = %08X.%08X \n",(unsigned int)(*c >> 32),(unsigned int)(*c));
	printf(" d = %08X.%08X \n",(unsigned int)(*d >> 32),(unsigned int)(*d));
	getchar();
#endif


	*a = (*a + *b + (m1 ^ c0)) & 0xFFFFFFFFFFFFFFFF;
	*d = ROTR64(*d ^ *a, 16);
	*c = (*c + *d) & 0xFFFFFFFFFFFFFFFF;
	*b = ROTR64(*b ^ *c, 11);
	
#if 1
	printf(" a = %08X.%08X \n",(unsigned int)(*a >> 32),(unsigned int)(*a));
	printf(" b = %08X.%08X \n",(unsigned int)(*b >> 32),(unsigned int)(*b));
	printf(" c = %08X.%08X \n",(unsigned int)(*c >> 32),(unsigned int)(*c));
	printf(" d = %08X.%08X \n",(unsigned int)(*d >> 32),(unsigned int)(*d));
	getchar();
#endif



}

// data = input work 80byte
// dst  = return hash 64byte
void blake512(const void *data, void *dst)
{
	hashState state;
	unsigned int k;
	unsigned char tmpbuf[48];
	unsigned char *out;
	unsigned long long M[16];
	char temp[128];

// Initialize
	memcpy(state.H, IV512, 8 * sizeof(unsigned long long));
	memcpy(state.buf, data, 80);		// copy message
	{
		fprintf(gfp_out, "Initial Value:\n");
		Show64(8, state.H);
		fprintf(gfp_out, "\n");
	}

// padding
	memset(tmpbuf, 0, 48);
	tmpbuf[0] = 0x80;
	tmpbuf[31] |= 1;
	enc64be_aligned(tmpbuf + 32, 0);	// copy T1
	enc64be_aligned(tmpbuf + 40, 640);	// copy T0
	memcpy(state.buf + 80, tmpbuf, 48);
	{
		fprintf(gfp_out, "==================================================================================\n\n");
		fprintf(gfp_out, "Message Block:\n");
		Show32(32, (unsigned int*)state.buf);
	}	

	state.V[0x0] = state.H[0];
	state.V[0x1] = state.H[1];
	state.V[0x2] = state.H[2];
	state.V[0x3] = state.H[3];
	state.V[0x4] = state.H[4];
	state.V[0x5] = state.H[5];
	state.V[0x6] = state.H[6];
	state.V[0x7] = state.H[7];
	state.V[0x8] = CB0;					// V8 = S[0] ^ CB0;
	state.V[0x9] = CB1;					// V9 = S[1] ^ CB1;
	state.V[0xA] = CB2;					// VA = S[2] ^ CB2;
	state.V[0xB] = CB3;					// VB = S[3] ^ CB3;
	state.V[0xC] = 0x452821E638D011F7;	// VC = T0	^ CB4 -> VC = 640 ^ CB4;
	state.V[0xD] = 0xBE5466CF34E90EEC;	// VD = T0	^ CB5 -> VD = 640 ^ CB5;
	state.V[0xE] = CB6;					// VE = T1	^ CB6;
	state.V[0xF] = CB7;					// VF = T1	^ CB7;

	M[0x0] = dec64be_aligned(state.buf +   0);
	M[0x1] = dec64be_aligned(state.buf +   8);
	M[0x2] = dec64be_aligned(state.buf +  16);
	M[0x3] = dec64be_aligned(state.buf +  24);
	M[0x4] = dec64be_aligned(state.buf +  32);
	M[0x5] = dec64be_aligned(state.buf +  40);
	M[0x6] = dec64be_aligned(state.buf +  48);
	M[0x7] = dec64be_aligned(state.buf +  56);
	M[0x8] = dec64be_aligned(state.buf +  64);
	M[0x9] = dec64be_aligned(state.buf +  72);
	M[0xA] = dec64be_aligned(state.buf +  80);
	M[0xB] = dec64be_aligned(state.buf +  88);
	M[0xC] = dec64be_aligned(state.buf +  96);
	M[0xD] = dec64be_aligned(state.buf + 104);
	M[0xE] = dec64be_aligned(state.buf + 112);
	M[0xF] = dec64be_aligned(state.buf + 120);
	{
		fprintf(gfp_out, "init state:\n");
		Show64(16, state.V);
		fprintf(gfp_out, "\n");
	}

	for (k = 0; k < 16; k ++) {
		GB(M[sigma[k][0x0]], M[sigma[k][0x1]], CB[sigma[k][0x0]], CB[sigma[k][0x1]], &state.V[0x0], &state.V[0x4], &state.V[0x8], &state.V[0xC]);
		GB(M[sigma[k][0x2]], M[sigma[k][0x3]], CB[sigma[k][0x2]], CB[sigma[k][0x3]], &state.V[0x1], &state.V[0x5], &state.V[0x9], &state.V[0xD]);
		GB(M[sigma[k][0x4]], M[sigma[k][0x5]], CB[sigma[k][0x4]], CB[sigma[k][0x5]], &state.V[0x2], &state.V[0x6], &state.V[0xA], &state.V[0xE]);
		GB(M[sigma[k][0x6]], M[sigma[k][0x7]], CB[sigma[k][0x6]], CB[sigma[k][0x7]], &state.V[0x3], &state.V[0x7], &state.V[0xB], &state.V[0xF]);
		GB(M[sigma[k][0x8]], M[sigma[k][0x9]], CB[sigma[k][0x8]], CB[sigma[k][0x9]], &state.V[0x0], &state.V[0x5], &state.V[0xA], &state.V[0xF]);
		GB(M[sigma[k][0xA]], M[sigma[k][0xB]], CB[sigma[k][0xA]], CB[sigma[k][0xB]], &state.V[0x1], &state.V[0x6], &state.V[0xB], &state.V[0xC]);
		GB(M[sigma[k][0xC]], M[sigma[k][0xD]], CB[sigma[k][0xC]], CB[sigma[k][0xD]], &state.V[0x2], &state.V[0x7], &state.V[0x8], &state.V[0xD]);
		GB(M[sigma[k][0xE]], M[sigma[k][0xF]], CB[sigma[k][0xE]], CB[sigma[k][0xF]], &state.V[0x3], &state.V[0x4], &state.V[0x9], &state.V[0xE]);
		{
			sprintf(temp, "Round%d:\n", k);
			fprintf(gfp_out, temp);
			Show64(16, state.V);
			fprintf(gfp_out, "\n");
		}
	}
	state.H[0] ^= state.V[0x0] ^ state.V[0x8];	// H[0] ^= S[0] ^ V0 ^ V8;
	state.H[1] ^= state.V[0x1] ^ state.V[0x9];	// H[1] ^= S[1] ^ V1 ^ V9;
	state.H[2] ^= state.V[0x2] ^ state.V[0xA];	// H[2] ^= S[2] ^ V2 ^ VA;
	state.H[3] ^= state.V[0x3] ^ state.V[0xB];	// H[3] ^= S[3] ^ V3 ^ VB;
	state.H[4] ^= state.V[0x4] ^ state.V[0xC];	// H[4] ^= S[0] ^ V4 ^ VC;
	state.H[5] ^= state.V[0x5] ^ state.V[0xD];	// H[5] ^= S[1] ^ V5 ^ VD;
	state.H[6] ^= state.V[0x6] ^ state.V[0xE];	// H[6] ^= S[2] ^ V6 ^ VE;
	state.H[7] ^= state.V[0x7] ^ state.V[0xF];	// H[7] ^= S[3] ^ V7 ^ VF;
	{
		fprintf(gfp_out, "Final:\n");
		Show64(8, state.H);
		fprintf(gfp_out, "\n");
	}

// return hash
	out = (unsigned char*)dst;
	for (k = 0; k < 8; k ++)
		enc64be(out + (k << 3), state.H[k]);
}

int _tmain(int argc, _TCHAR* argv[])
{
	unsigned char dst[64];
	char fn[32];
	unsigned int *pdata;

#define TEST_NUM			(1)
#if (TEST_NUM == 1)
	unsigned char gX13[]= {	0x00,0x00,0x00,0x02,0x5b,0x4a,0xbb,0x46,0x95,0x9d,0x93,0xd0,0x49,0x1a,0x8c,0x97,0xb0,0x02,0x37,0x29,
							0x5d,0x1e,0xf8,0xfd,0xe0,0x74,0x2c,0xf7,0x00,0xdd,0x5c,0xb2,0x00,0x00,0x00,0x00,0x39,0x2d,0x31,0xbc,
							0x20,0xdb,0x56,0x16,0xc6,0xf0,0x56,0x28,0x79,0x15,0x4d,0xc4,0x62,0x1a,0x46,0x97,0x4c,0x25,0xf0,0x40,
							0x0d,0xbc,0x8c,0xea,0x24,0xd7,0xaf,0x70,0x53,0x95,0x89,0xad,0x1c,0x02,0xac,0x3d,0x00,0x09,0xe2,0x2e };
#elif(TEST_NUM == 2)
	unsigned char gX13[]= {	0x00,0x00,0x00,0x02,0x5b,0x4a,0xbb,0x46,0x95,0x9d,0x93,0xd0,0x49,0x1a,0x8c,0x97,0xb0,0x02,0x37,0x29,
							0x5d,0x1e,0xf8,0xfd,0xe0,0x74,0x2c,0xf7,0x00,0xdd,0x5c,0xb2,0x00,0x00,0x00,0x00,0xa4,0x47,0xaa,0xb6,
							0x66,0x41,0x0a,0x3c,0xd3,0x06,0xcb,0x6b,0x52,0x80,0x47,0xab,0xea,0x13,0xe6,0x62,0x65,0x9a,0x74,0x14,
							0x99,0xca,0x0b,0xed,0x35,0x07,0x6f,0x4f,0x53,0x95,0x89,0xad,0x1c,0x02,0xac,0x3d,0x00,0x01,0x28,0xcf };
#else
	unsigned char gX13[]= {	0x00,0x00,0x00,0x02,0x5b,0x4a,0xbb,0x46,0x95,0x9d,0x93,0xd0,0x49,0x1a,0x8c,0x97,0xb0,0x02,0x37,0x29,
							0x5d,0x1e,0xf8,0xfd,0xe0,0x74,0x2c,0xf7,0x00,0xdd,0x5c,0xb2,0x00,0x00,0x00,0x00,0x56,0xc0,0x2f,0x12,
							0x82,0x24,0xd3,0xb8,0xe9,0x37,0x67,0x9f,0x9d,0x00,0x10,0x00,0x2e,0x32,0x02,0x6b,0xf2,0x9d,0x22,0xd5,
							0x30,0x68,0xcb,0x13,0xc0,0x14,0x4d,0xa5,0x53,0x95,0x89,0xad,0x1c,0x02,0xac,0x3d,0x00,0x0a,0x1e,0xf1 };
#endif

	{
		sprintf(fn, "debug_%d.txt", TEST_NUM - 1);
		gfp_out = fopen(fn, "w");	
		fprintf(gfp_out, "\nLen = %d\n", 512);
		fprintBstr(gfp_out, "Msg = ", (unsigned char*)gX13, 80);
		fprintf(gfp_out, "\n");
	}

	pdata = (unsigned int *)gX13;
	for(int i = 0; i < 20; i++) {
		pdata[i] = bswap32(pdata[i]);
	}

	blake512(gX13, dst);

	{
		fprintBstr(gfp_out, "\nMD = ", (unsigned char*)dst, 64);
		fclose(gfp_out);
	}
	return 0;
}
