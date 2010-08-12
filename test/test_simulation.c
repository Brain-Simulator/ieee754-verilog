#include <stdio.h>
#include <ctype.h>

float str2float(char *a)
{
	unsigned long out=0,i;
	for(i=0;a[i];i++)
	{
		out *= 2;
		if(a[i] == '1')
			out++;
	}
	return *((float*)&out);
}

void float2str(float in, char *out)
{
	unsigned long a = *(unsigned long*)(&in);
	int i;
	out[32] = 0;
	for(i=31;i>=0;i--)
	{
		out[i] = (a % 2) + '0';
		a /= 2;
	}
}

int fequal(float a, float b)
{
	long ai = *(long*)&a;
	long bi = *(long*)&b;
	return ai == bi;
}

int main(int argc, char *argv[])
{
	float A, B, C, correct1, correct2;
	int t_success=0, t_count=0;
	char inA[70],inB[70],outC[70],corC[70];
	
	if( sizeof(long) != sizeof(float) )
	{
		puts("error sizeof long != sizeof float");
		return -1;
	}
	
	while(scanf("%5s",inA) == 1)
	{
		if(strcmp(inA,"TEST1") == 0)
		{
			scanf("%s %s %s", inA, inB, outC);
			A = str2float(inA);
			B = str2float(inB);
			C = str2float(outC);
			correct2 = correct1 = A + B;
		}
		else if(strcmp(inA,"TEST2") == 0)
		{
			scanf("%s %s %s %s", inA, inB, outC, corC);
			A = str2float(inA);
			B = str2float(inB);
			C = str2float(outC);
			correct1 = str2float(corC);
			correct2 = A + B;
		}
		else
		{
			while(getchar() != '\n');//skip until end of the line
			continue;
		}
		
		if(! fequal(correct1, C))
		{
			char scorrect1[35];
			char scorrect2[35];
			float2str(correct1, scorrect1);
			float2str(correct2, scorrect2);
			printf("Test failed: %e + %e = %e != %e\n",A, B, correct1, C);
			printf("  A %s\n +B %s\n == %s\n   (%s)\n != %s\n", inA, inB, scorrect1, scorrect2, outC);
		}
		else
		{
			//printf("Test OK! (%.2f + %.2f = %.2f)\n", A, B, C);
			t_success++;
		}
		t_count++;
	}
	printf("Succeded %d test, Failed %d tests\n", t_success, t_count - t_success);
	printf("Sucess: %.2lf%%\n",100 * t_success / (double)t_count );
	return 0;
}

