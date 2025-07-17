#include <streqlasm.h>
#include <stdio.h>
#include <locale.h>
#include <immintrin.h>

#define ASCII_COLOR_RED "\x1b[31m"
#define ASCII_COLOR_RESET "\x1b[0m"

void prstreql(const char* str1, const char* str2)
{
	if (streql(str1, str2)) {
		printf("%s & %s are equal.\n", str1, str2);
	}
	else {
		printf(ASCII_COLOR_RED"%s & %s are not equal.\n"ASCII_COLOR_RESET, str1, str2);
	}
}


void prstrneql(const char* str1, const char* str2, size_t n)
{
	int r = strneql_x64_win(str1, str2, n);
	if (r) {
		printf("%s & %s are equal up to %zu characters.\n", str1, str2, n);
	}
	else {
		printf(ASCII_COLOR_RED"%s & %s are not equal up to %zu characters.\n"ASCII_COLOR_RESET, str1, str2, n);
	}
}

int main() {

	// for UTF-8
	setlocale(LC_ALL, "");
	{
		const char* str1 = "mystr\0bb";
		const char* str2 = "myst1r\0aa";
		prstreql(str1, str2);
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
		const char* str2 = "questa frase è lunga 35 caratteri... no, veramente, è 59";
		prstreql(str1, str2);
	}
}