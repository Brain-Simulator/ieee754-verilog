#include <stdio.h>
#include <ctype.h>

float str2float(char *a)
{
	long out=0,i;
	for(i=0;a[i];i++)
	{
		out *= 2;
		if(a[i] == '1')
			out++;
	}
	return *((float*)&out);
}

int main()
{
	float A,B,C;
	int t_success=0, t_count=0;
	char inA[70],inB[70],outC[70];
	
	if( sizeof(long) != sizeof(float) )
	{
		puts("error sizeof long != sizeof float");
		return -1;
	}
	
	while(scanf("%5s",inA) == 1)
	{
		if(strcmp(inA,"TEST1") != 0)
		{
			while(getchar() != '\n');//skip until end of the line
			continue;
		}
		scanf("%s %s %s", inA, inB, outC);
		A = str2float(inA);
		B = str2float(inB);
		C = str2float(outC);
		if(A + B != C)
		{
			printf("Test failed: %f + %f = %f != %f\n",A,B,A+B,C);
			printf("%10s %s + %s != %s\n","",inA,inB,outC);
		}
		else
		{
			printf("Test OK! (%.2f + %.2f = %.2f)\n", A, B, C);
			t_success++;
		}
		t_count++;
	}
	printf("Sucess: %.2lf%%\n",100 * t_success / (double)t_count );
	return 0;
}

