#include <stdio.h>
#include <stdlib.h>
#include "../design/hls_ap_bus_test.h"

int main () 
{
	int mem[128];
    FILE *out_file;

	hls_ap_bus_test(mem);

    out_file = fopen("out.dat","w");
	
    for (int i=0; i<128; i++)
    {
	    fprintf(out_file,"%d\n",mem[i]);
        printf("%d\n", mem[i]);
    }
    
    fclose(out_file);

    printf ("\nComparing against output data \n");
    if (system("diff -w out.dat out_golden.dat")) 
    {

       printf("*******************************************\n");
       printf("FAIL: Output DOES NOT match the golden output\n");
       printf("*******************************************\n");
    } 
    else 
    {
       printf("*******************************************\n");
       printf("PASS: The output matches the golden output!\n");
       printf("*******************************************\n");
    }    
	return 0;
}

