#include "aux.h"
#include "irq.h"


/*
inline  unsigned int  atm_get(void)
{
	 //read atomic bit (csr 0x1c)
	 unsigned int atm;
    // gcc doesnt know csr 0x1c, so we must force it (update your f*cking binutils...)
	 asm volatile (	".long 0x93800800" : "=&r" (atm));
    return atm;	             	
}

inline void atomic_on()
{
   //begin atomic operation (hold cycle line on data bus HI)   
   asm volatile ( "mvi r1,1\n" \
                  ".long 0xD3810000" );
   return;	             	
}

inline void atomic_off()
{
	 //end atomic operation (drop cycle line on data bus) 
    asm volatile ( ".long 0xD3800000" );
	 return;	             	
}
*/


unsigned int ier = 5;

inline unsigned long long getSysTime()
{
   unsigned long long systime;  
   systime =  ((unsigned long long)*(pCpuSysTime+0))<<32;
   systime |= ((unsigned long long)*(pCpuSysTime+1)) & 0x00000000ffffffff;
   return systime;  
}

inline void cycSleep(unsigned int cycs)
{
   unsigned int j;
   for (j = 0; j < cycs; ++j) asm("# noop"); 
}

inline void uSleep(unsigned long long uSecs)
{
   cycSleep((unsigned int)(uSecs * 1000 / T_SYS));
}

inline unsigned int  getCpuID()  {return *pCpuId;}
inline unsigned int  getCpuIdx() {return *pCpuId & 0xff;}
inline unsigned int  getCores()  {return *pCluInfo  & 0xff;}

inline  unsigned int  atomic_get(void)
{
	 return *pCpuAtomic;	             	
}

inline void atomic_on()
{
   ier = irq_get_enable();
   irq_disable();
   *pCpuAtomic = 1;
}

char progressWheel()
{
   static unsigned char index = 0;
   const char c_running[4] = {'|', '/', '-', '\\'};
   
   return c_running[index++ & 0x03];

}


inline void atomic_off()
{
	*pCpuAtomic = 0;
	unsigned int foo = 0;
	// or the IE bit with ier
	asm volatile ("rcsr  %0, IE\n"      \
	              "or    %0, %0, %1\n"  \
	              "wcsr  IE, %0\n"      \
                : "+r" (foo)           \
                : "r" (ier)            \
        );        	
}

char* sprinthex(char* buffer, unsigned long val, unsigned char digits)
{
	unsigned char i,ascii;
	const unsigned long mask = 0x0000000F;

	for(i=0; i<digits;i++)
	{
		ascii= (val>>(i<<2)) & mask;
		if(ascii > 9) ascii = ascii - 10 + 'A';
	 	else 	      ascii = ascii      + '0';
		buffer[digits-1-i] = ascii;		
	}
	
	buffer[digits] = 0x00;
	return buffer;	
}


char* mat_sprinthex(char* buffer, unsigned long val)
{
   return sprinthex(buffer, val, 8);
}
