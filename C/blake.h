#ifndef __BLAKE_H__
#define __BLAKE_H__

#define TRACE

typedef unsigned char		word8;	
typedef unsigned short		word16;	
typedef unsigned long		word32;
typedef unsigned char BitSequence;
typedef unsigned long long DataLength;
typedef enum { 
  SUCCESS=0
 ,FAIL=1
 ,BAD_HASHBITLEN=2
 ,STATE_NULL=3
} HashReturn;

typedef struct {
	unsigned char buf[128];
	unsigned long long H[8];

	unsigned long long V[16];
} hashState;

#endif	// __BLAKE_H__
