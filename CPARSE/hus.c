#include <stdio.h>
#include <stdlib.h>
#include "crcmodel.h"

unsigned char s[2000];
unsigned char g[26];
 
int main(int argc, char *argv[]) {
 FILE *f,*w,*d;
 cm_t cm;
 p_cm_t p_cm=&cm;
 time_t tm;
 struct tm* tmi; 
 unsigned int  l,r,i,n=0;
 p_cm->cm_width = 32;
 p_cm->cm_poly  = 0x04C11DB7;
 p_cm->cm_init  = 0xFFFFFFFF; 
 p_cm->cm_refin = TRUE;  
 p_cm->cm_refot = TRUE; 
 p_cm->cm_xorot = 0xFFFFFFFF;
 if (argc!=5) {
 	printf("HUA to HEX cvt, usage:\n");
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

 while(1) {
  r=fread(s,3,1,f);
  if (r!=1) 
   { 
     time(&tm);  
     tmi=localtime(&tm);
     strftime(g,26,"%Y-%m-%d %H:%M:%S",tmi);
	 fprintf(d,"FINISH,%s,%s,%s,TOTAL,%i\n",g,argv[1],argv[2],n); 
	 return 0; 
   }
  if (s[1]==0x81) { l=s[2]; fprintf(w,"%02x%02x%02x",s[0],s[1],s[2]); }
  else { l=s[2]*256; fprintf(w,"%02x%02x%02x",s[0],s[1],s[2]); r=fread(s,1,1,f); l=l+s[0]; fprintf(w,"%02x",s[0]); } 
  r=fread(s,l,1,f);
  if (r!=1) 
   { 
     time(&tm); 
     tmi=localtime(&tm);
     strftime(g,26,"%Y-%m-%d %H:%M:%S",tmi);
	 fprintf(d,"ERROR,%s,%s,%s,B %i != %i,%i\n",g,argv[1],argv[2],r,l,n); 
	 return 1; 
   }
  cm_ini(p_cm);
  cm_blk(p_cm,s,l);
  for(i=0;i<l;i++) fprintf(w,"%02x",s[i]);      
  fprintf(w,",%i,%u,%s,%s\n",++n,cm_crc(p_cm),argv[2],argv[1]);
 }
 time(&tm);  
 tmi=localtime(&tm);
 strftime(g,26,"%Y-%m-%d %H:%M:%S",tmi);
 fprintf(d,"FINISH,%s,%s,%s,TOTAL,%i\n",g,argv[1],argv[2],n); 
 return 0;
}
