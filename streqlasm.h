/*
Copyright © 2025 Tripp Robins

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the “Software”), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons
to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#ifndef TRIPP_STREQL_ASM_H
#define TRIPP_STREQL_ASM_H


#if defined(_MSC_VER)
#if defined(_M_X64)
#define STREQL_SIMD_SUPPORTED 1
#else
#define STREQL_SIMD_SUPPORTED 0
#endif
#else
#if defined(__SSE4_2__)
#define STREQL_SIMD_SUPPORTED 1
#else
#define STREQL_SIMD_SUPPORTED 0
#endif
#endif

#if (defined(_M_X64) || defined(__aarch64__))
#define STREQL_SUPPORTED_ARCHITECHURE 1
#elif
#define STREQL_SUPPORTED_ARCHITECHURE 0
#endif
#if (defined(_WIN32) || defined(_WIN64)) || (defined(__x86_64__)) && (STREQL_SUPPORTED_ARCHITECHURE) && (STREQL_SIMD_SUPPORTED)

int streql_x64_win(const char*, const char*);

int strneql_x64_win(const char*, const char*, size_t);

#define streql(str1,str2) streql_x64_win(str1,str2)

#define strneql(str1,str2,n) strneql_x64_win(str1,str2,n)

/* https://stackoverflow.com/questions/142508/how-do-i-check-os-with-a-preprocessor-directive */
#elif (defined(__linux__) || defined(__unix) || defined(__APPLE__)) && (STREQL_SUPPORTED_ARCHITECHURE) && (STREQL_SIMD_SUPPORTED)

int streql_x64_unix(const char*, const char*);

int strneql_x64_unix(const char*, const char*, size_t);

#define streql(str1,str2) streql_x64_unix(str1,str2)

#define strneql(str1,str2,n) strneql_x64_unix(str1,str2,n)

#else
/* C fallback */
static int streql(const char* str1, const char* str2) {
    while (1) {
        if (*str1 != *str2) {
            return 0;
        }
        else if (*str1 == 0 || str2 == 0) {
            return 1;
        }
        str1++;
        str2++;
    }
    return 1;
}
static int strneql(const char* str1, const char* str2, unsigned int n) {
    size_t i = 0;
    while (i < n) {
        if (str1[i] != str2[i]) {
            return 0;
        }
        if (str1[i] == '\0' || str2[i] == '\0') {
            return 1;
        }
        i++;
    }
    return 1;
}
#endif


#endif /* !TRIPP_STREQL_ASM_H */