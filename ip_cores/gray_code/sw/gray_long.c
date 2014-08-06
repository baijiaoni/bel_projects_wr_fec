#include <stdio.h>
#include <stdint.h>



uint64_t bin2gray(uint64_t num)
{
   return (num >> 1) ^ num;
}

uint64_t gray2bin(uint64_t num)
{

   uint64_t mask;
   uint32_t i=0;

   for( mask = num >> 1; mask != 0; mask = mask >> 1)
   {
      //printf("%d. Num %lx Mask %lx \n",i ,num, mask);
      num = num ^ mask;
      i++;
   }

   return num;

}


int main(void)
{

   uint64_t num = 0xFAFABFFL;
   uint64_t bg, gb;

   bg = bin2gray(num);
   printf("Bin %lx 2  gray: %lx \n",num, bg);

   gb = gray2bin(bg);
   printf("Gray %lx 2 bin: %lx \n",bg, gb);

   return  0;
}
