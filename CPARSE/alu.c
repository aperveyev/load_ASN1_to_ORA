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
 	printf("ALU to HEX cvt, usage:\n");
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
 r=fread(s,8,1,f); 
 l=s[7];
 r=fread(s,l-8,1,f);
 while(1) {
  r=fread(s,4,1,f);
  if (r!=1) 
   { 
     time(&tm);  
     tmi=localtime(&tm);
     strftime(g,26,"%Y-%m-%d %H:%M:%S",tmi);
     fprintf(d,"FINISH,%s,%s,%s,TOTAL,%i\n",g,argv[1],argv[2],n); 
     return 0; 
   }
/*  if (s[2]==0x81) { l=s[3]; fprintf(w,"%02x%02x%02x%02x",s[0],s[1],s[2],s[3]); }
  else { l=s[3]*256; fprintf(w,"%02x%02x%02x%02x",s[0],s[1],s[2],s[3]); r=fread(s,1,1,f); l=l+s[0]; fprintf(w,"%02x",s[0]); } */
  l=s[0]*256+s[1];
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
