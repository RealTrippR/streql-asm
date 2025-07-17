#include <streqlasm.h>
#include <stdio.h>
#include <locale.h>
#include <immintrin.h>

#define ASCII_COLOR_RED "\x1b[31m"
#define ASCII_COLOR_RESET "\x1b[0m"

int prstreql(const char* str1, const char* str2)
{
	int r = streql_x64_win(str1, str2);
	if (r) {
		printf("'%s' & '%s' are equal.\n", str1, str2);
	}
	else {
		printf("'%s' & '%s' "ASCII_COLOR_RED" are not equal."ASCII_COLOR_RESET"\n", str1, str2);
	}
	return r;
}


int prstrneql(const char* str1, const char* str2, size_t n)
{
	int r = strneql_x64_win(str1, str2, n);
	if (r) {
		printf("'%s' & '%s' are equal up to %zu characters.\n", str1, str2, n);
	}
	else {
		printf("'%s' & '%s'" ASCII_COLOR_RED" are not equal "ASCII_COLOR_RESET"up to % zu characters.\n", str1, str2, n);
	}
	return r;
}

int main() {
	// https://www.ired.team/miscellaneous-reversing-forensics/windows-kernel-internals/linux-x64-calling-convention-stack-frame
	// https://learn.microsoft.com/en-us/cpp/build/x64-calling-convention?view=msvc-170/
	// for UTF-8
	setlocale(LC_ALL, "");
	{
		const char* str1 = "mystr\0bb";
		const char* str2 = "mystr\0aa";
		int i =prstreql(str1, str2);
		prstrneql(str1, str2,7);
	}
	{
		const char* str1 = "mystrbeta";
		const char* str2 = "mystrsigma";
		prstrneql(str1, str2, 5);
		prstrneql(str1, str2, 9);
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
		const char* str1 = "questa frase è lunga 35 caratteri";
		const char* str2 = "questa frase è lunga 35 caratteri... no, veramente, è 59";
		prstreql(str1, str2);
		prstrneql(str1, str2, 35);

	}
}