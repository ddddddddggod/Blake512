#ifndef _PT_DEBUG_H_
#define _PT_DEBUG_H_

void Show64_step(size_t cnt,const unsigned long long *X,size_t step);

#define Show64(cnt,X) Show64_step(cnt,X,1)

void Show08(size_t cnt,const unsigned char *b);
void Show32(size_t cnt,const unsigned int *b);

#endif
