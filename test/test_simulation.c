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

int isnan(char *num)
{
	int i,count;
	for(i=1;i<=8;i++)
	{
		if(num[i] != '1')
			return 0;
	}
	for(i=9; i<=31; i++)
	{
		if(num[i] == '1')
			return 1;
	}
	return 0;
}

int fequal(char *cor, char *out)
{
	int corIsNan = isnan(cor);
	int outIsNan = isnan(out);
	if(corIsNan ^ outIsNan)
		return 0;
	if(corIsNan && outIsNan) /*I don't care, what you say IEEE! NaN==NaN */
		return 1;
	return strcmp(cor, out) == 0;
}

int main(int argc, char *argv[])
{
	float A, B, C, correct1;
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
			correct1 = A + B;
			float2str(correct1, corC);
		}
		else if(strcmp(inA,"TEST2") == 0)
		{
			scanf("%s %s %s %s", inA, inB, outC, corC);
			A = str2float(inA);
			B = str2float(inB);
			C = str2float(outC);
			correct1 = str2float(corC);
		}
		else
		{
			while(getchar() != '\n');//skip until end of the line
			continue;
		}
		if(! fequal(corC, outC))
		{
			printf("Test #%d failed: %e + %e = %e != %e\n", t_count+1, A, B, correct1, C);
			printf("  A %s\n +B %s\n == %s\n != %s\n", inA, inB, corC, outC);
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

