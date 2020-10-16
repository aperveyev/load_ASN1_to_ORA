#include <stdio.h>
#include <stdlib.h>

unsigned char s[2000];
unsigned char g[26];
 
int main(int argc, char *argv[]) {
 FILE *f,*w,*d;
 time_t tm;
 struct tm* tmi; 
 unsigned int  l,r,i,n=0;
 if (argc!=5) {
 	printf("HM to HEX cvt, usage:\n");
 	printf("- input file name\n");
 	printf("- input portion number\n");
 	printf("- out file name\n");
 	printf("- log/stat file name\n");
 	return 1;
 }
 d=fopen(argv[4],"w"); 
 time(&tm);
 tmi=localtime(&tm);
 strftime(g,26,"%Y-%m-%d %H:%M:%S",tmi);
 fprintf(d,"START,%s,%s,%s,TOTAL,0\n",g,argv[1],argv[2]);
 f=fopen(argv[1],"rb");
 w=fopen(argv[3],"w");
/* header */
 r=fread(s,2,1,f); 
 if ( s[1]==0x84 ) r=fread(s,28,1,f); /* 4+ 1+1+16 + 1+1+4 */
 if ( s[1]==0x83 ) r=fread(s,26,1,f); /* 3+ 1+1+16 + 1+1+3 */
 if ( s[1]==0x82 ) r=fread(s,24,1,f); /* 2+ 1+1+16 + 1+1+2 */ 
 while(1) {
  r=fread(s,3,1,f);
  if ( r!=1 )
   { 
     time(&tm);  
     tmi=localtime(&tm);
     strftime(g,26,"%Y-%m-%d %H:%M:%S",tmi);
     fprintf(d,"FINISH,%s,%s,%s,TOTAL,%i\n",g,argv[1],argv[2],n); 
     return 0; 
   }
  fprintf(w,"%02x%02x%02x",s[0],s[1],s[2]);      
  if ( s[0]==0xBF ) /* 2-bytes record tag */
  {
  	if ( s[2]==0x81 ) { r=fread(s,1,1,f); l=s[0]; fprintf(w,"%02x",s[0]); }
    else 
      { if ( s[2]==0x82 ) { r=fread(s,2,1,f); l=s[0]*256+s[1]; fprintf(w,"%02x%02x",s[0],s[1]); }
        else              { l=s[2]-1; }
      }
  }
  else {
    if ( s[1]==0x81 ) 
      { l=s[2]; }
    else 
      { if ( s[1]==0x82 ) { l=s[2]*256; r=fread(s,1,1,f); l=l+s[0]; fprintf(w,"%02x",s[0]); }
        else              { l=s[1]-1; } 
      }
  } 
  r=fread(s,l,1,f);
  if (r!=1) 
   { 
     time(&tm); 
     tmi=localtime(&tm);
     strftime(g,26,"%Y-%m-%d %H:%M:%S",tmi);
     fprintf(d,"ERROR,%s,%s,%s,B %i != %i,%i\n",g,argv[1],argv[2],r,l,n); 
     return 1; 
   }
  for(i=0;i<l;i++) fprintf(w,"%02x",s[i]);      
  fprintf(w,",%i,%u,%s,%s\n",++n,0,argv[2],argv[1]);
 }
 time(&tm);  
 tmi=localtime(&tm);
 strftime(g,26,"%Y-%m-%d %H:%M:%S",tmi);
 fprintf(d,"FINISH,%s,%s,%s,TOTAL,%i\n",g,argv[1],argv[2],n); 
 return 0;
}
