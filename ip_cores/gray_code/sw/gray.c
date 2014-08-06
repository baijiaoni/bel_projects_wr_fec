#include <stdio.h>
#include <stdint.h>



uint32_t bin2gray(uint32_t num)
{
   return (num >> 1) ^ num;
}

uint32_t gray2bin(uint32_t num)
{

   uint32_t mask;

   for( mask = num >> 1; mask != 0; mask = mask >> 1)
   {
      num = num ^ mask;
   }

   return num;

}


int main(void)
{

   uint32_t num = 0x0;
   uint32_t bg, gb;
   uint32_t cnt;

   for(cnt=0x0;cnt<0x15;cnt++)
   {
      bg = bin2gray(cnt);
      gb = gray2bin(bg);

      printf("Bin 2 gray:%x - %x - %x \n",cnt,bg,gb);
   }

   return  0;
}
