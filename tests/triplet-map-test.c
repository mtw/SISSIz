#include <ctype.h>
#include <stdio.h>

#include "global.h"

static int failures=0;

static void checkMapping(char first, char second, char third, int expected)
{
  int actual=tripletTO64(first,second,third);

  if (actual!=expected){
    fprintf(stderr,"%c%c%c mapped to %d, expected %d\n",
            first,second,third,actual,expected);
    failures++;
  }
}

int main(void)
{
  static const char rna[]="ACGU";
  static const char dnaRna[]="ACGTU";
  static const int dnaRnaIndex[]={0,1,2,3,3};
  int seen[64]={0};
  int i,j,k,mask,expected,actual;

  /* Every canonical RNA triplet must map bijectively onto 0..63. */
  for (i=0;i<4;i++){
    for (j=0;j<4;j++){
      for (k=0;k<4;k++){
        expected=16*i+4*j+k;
        actual=tripletTO64(rna[i],rna[j],rna[k]);
        checkMapping(rna[i],rna[j],rna[k],expected);
        if (actual>=0 && actual<64) seen[actual]++;

        /* Case must not affect the encoding. */
        for (mask=0;mask<8;mask++){
          checkMapping((mask&1)?(char)tolower((unsigned char)rna[i]):rna[i],
                       (mask&2)?(char)tolower((unsigned char)rna[j]):rna[j],
                       (mask&4)?(char)tolower((unsigned char)rna[k]):rna[k],
                       expected);
        }
      }
    }
  }

  for (i=0;i<64;i++){
    if (seen[i]!=1){
      fprintf(stderr,"triplet index %d is produced %d times, expected once\n",
              i,seen[i]);
      failures++;
    }
  }

  /* T and U are equivalent in every position. */
  for (i=0;i<5;i++){
    for (j=0;j<5;j++){
      for (k=0;k<5;k++){
        expected=16*dnaRnaIndex[i]+4*dnaRnaIndex[j]+dnaRnaIndex[k];
        for (mask=0;mask<8;mask++){
          checkMapping((mask&1)?(char)tolower((unsigned char)dnaRna[i]):dnaRna[i],
                       (mask&2)?(char)tolower((unsigned char)dnaRna[j]):dnaRna[j],
                       (mask&4)?(char)tolower((unsigned char)dnaRna[k]):dnaRna[k],
                       expected);
        }
      }
    }
  }

  /* Invalid input must be rejected, never turned into an array index. */
  if (tripletTO64('N','A','A')!=-1) failures++;
  if (tripletTO64('A','-','A')!=-1) failures++;
  if (tripletTO64('A','A','?')!=-1) failures++;

  if (failures!=0) return 1;

  printf("64 canonical triplets, case variants and T/U aliases map correctly\n");
  return 0;
}
