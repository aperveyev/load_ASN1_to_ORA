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
 	printf("NSN to HEX cvt, usage:\n");
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
  l=256*s[1]+s[0];
  if (l>1000) /*FF and something*/ { 
   if (s[2]!=255 && s[1]!=255) { /* only one FF */
     l=256*s[2]+s[1]; fprintf(w,"%02x%02x",s[1],s[2]); 
	 r=fread(s,1,1,f); 
	 if (r!=1) 
	  { 
       time(&tm); 
       tmi=localtime(&tm);
       strftime(g,26,"%Y-%m-%d %H:%M:%S",tmi);
       fprintf(d,"ERROR,%s,%s,%s,BA %i != %i,%i\n",g,argv[1],argv[2],r,l,n); 
       return 1; 
	  } 
     fprintf(w,"%02x",s[0]);	 
	 }
   else if (s[2]!=255) { /* two FFs */
     l=s[2]; fprintf(w,"%02x",s[2]); 
	 r=fread(s,2,1,f); 
	 if (r!=1) 
	  { 
       time(&tm); 
       tmi=localtime(&tm);
       strftime(g,26,"%Y-%m-%d %H:%M:%S",tmi);
       fprintf(d,"ERROR,%s,%s,%s,BA %i != %i,%i\n",g,argv[1],argv[2],r,l,n); 
       return 1; 
	  } 
     fprintf(w,"%02x%02x",s[0],s[1]);	 
     l=l+256*s[0];   
     }
   else { /* 3 bytes of FF -- read more */
     while(s[0]==255) 
	 { 
	   r=fread(s,1,1,f); 
       if (r!=1) 
	    { 
         time(&tm); 
         tmi=localtime(&tm);
         strftime(g,26,"%Y-%m-%d %H:%M:%S",tmi);
         fprintf(d,"FINISH,%s,%s,%s,TOTAL,%i\n",g,argv[1],argv[2],n);          
         return 1; 
	    } 
	 }
     fprintf(w,"%02x",s[0]);
     l=s[0];
     r=fread(s,2,1,f); 
	 if (r!=1) 
	  { 
       time(&tm); 
       tmi=localtime(&tm);
       strftime(g,26,"%Y-%m-%d %H:%M:%S",tmi);
       fprintf(d,"ERROR,%s,%s,%s,BD %i != %i,%i\n",g,argv[1],argv[2],r,l,n); 
       return 1; 
	  } 
     fprintf(w,"%02x%02x",s[0],s[1]); 
   }
  }
  else {
   for(i=0;i<3;i++) fprintf(w,"%02x",s[i]);	  
  }
  r=fread(s,l-3,1,f);
  if (r!=1) 
   { 
     time(&tm); 
     tmi=localtime(&tm);
     strftime(g,26,"%Y-%m-%d %H:%M:%S",tmi);
     fprintf(d,"ERROR,%s,%s,%s,BE %i != %i,%i\n",g,argv[1],argv[2],r,l,n); 
     return 1; 
   }
  cm_ini(p_cm);
  cm_blk(p_cm,s,l-3);
  for(i=0;i<l-3;i++) fprintf(w,"%02x",s[i]);      
  fprintf(w,",%i,%u,%s,%s\n",++n,cm_crc(p_cm),argv[2],argv[1]);
 }
 time(&tm);  
 tmi=localtime(&tm);
 strftime(g,26,"%Y-%m-%d %H:%M:%S",tmi);
 fprintf(d,"FINISH,%s,%s,%s,TOTAL,%i\n",g,argv[1],argv[2],n); 
 return 0;
}
