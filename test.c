#include <streqlasm.h>
#include <stdio.h>
#include <locale.h>
#include <immintrin.h>
#include <stdint.h>
#include <string.h>
#include <assert.h>

#define ASCII_COLOR_RED "\x1b[31m"
#define ASCII_COLOR_RESET "\x1b[0m"

int prstreql(const char* str1, const char* str2)
{
	int r = streql(str1, str2);
	int r2 = strcmp(str1, str2)==0;
	if (r != r2) {
		assert(00 && "BAD");
	}
	if (r) {
		printf("'%s' & '%s' are equal.\n", str1, str2);
	}
	else {
		printf("'%s' & '%s' "ASCII_COLOR_RED" are not equal."ASCII_COLOR_RESET"\n", str1, str2);
	}
	return r;
}

int prstrneql(const char* str1, const char* str2, uint64_t n)
{
	int r = strneql(str1, str2, n);
	int r2 = strncmp(str1, str2, n)==0;
	printf("r: %d -", r);
	
	if (r) {
		printf("'%s' & '%s' are equal up to %zu characters.\n", str1, str2, n);
	}
	else {
		printf("'%s' & '%s'" ASCII_COLOR_RED" are not equal "ASCII_COLOR_RESET"up to % zu characters.\n", str1, str2, n);
	}
	if (r != r2) {
		assert(00 && "BAD");
	}
	return r;
}

int main() {
	// https://www.ired.team/miscellaneous-reversing-forensics/windows-kernel-internals/linux-x64-calling-convention-stack-frame
	// https://learn.microsoft.com/en-us/cpp/build/x64-calling-convention?view=msvc-170/
	// for UTF-8
	setlocale(LC_ALL, "");
	{
		const char* str1 = "0";
		const char* str2 = "ascii";
		prstrneql(str1, str2, 1);
	}
	{
		const char* str1 = "1";
		const char* str2 = "1";
		prstrneql(str1, str2, 1);
	}
	{
		const char* str1 = "mystr\0 b2";
		const char* str2 = "mystr\0\ta1";
		prstreql(str1, str2);
		prstrneql(str1, str2,7);
	}
	{
		const char* str1 = "mystrbeta\0c";
		const char* str2 = "mystrsigma";
		prstrneql(str1, str2, 5);
		prstrneql(str1, str2, 9);
	}
	{
		const char* str1 = "ply";
		const char* str2 = "ply";
		prstrneql(str1, str2, 3);
	}
	{
		const char* str1 = "questa frase è lunga 35 caratteri";
		prstreql(str1, str1);
	}
	{
		const char* str1 = "questa frase è lunga 36 caratteri.";
		prstreql(str1, str1);
	}
	{
		const char* str1 = "questa frase è lunga 34 caratteri.";
		const char* str2 = "questa frase è lunga 34 caratteri... no, veramente, è 59";
		prstreql(str1, str2);
		prstrneql(str1, str2, 34);
		prstrneql(str1, str1, 35);
	}
	{
		const char* str1 = "this sentence is 36 characters long. 4978947469358952779257587333553258676943874638436946746374368746878735769830360286408644802360803926";
		const char* str2 = "this sentence is 36 characters long. 32589676439834698864469368986739379367";
		prstreql(str1, str2);
		prstrneql(str1, str2, 35);
	}
}