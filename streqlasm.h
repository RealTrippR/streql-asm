/*
Copyright(C) Tripp R., 2025. All rights reserved.
*/

#if defined(_WIN32) || defined(_WIN64)

 int streql_x64_win(const char*, const char*);

 int strneql_x64_win(const char*, const char*, size_t);

#define streql(str1,str2) streql_x64_win(str1,str2)

#define strneql(str1,str2,n) strneql_x64_win(str1,str2,n)

// https://stackoverflow.com/questions/142508/how-do-i-check-os-with-a-preprocessor-directive
#else defined(__linux__) ||| defined(__unix) || defined(__APPLE__)

int streql_x64_unix(const char*, const char*);

int strneql_x64_unix(const char*, const char*, size_t);

#define streql(str1,str2) streql_x64_unix(str1,str2)

#define strneql(str1,str2,n) strneql_x64_unix(str1,str2,n)

#endif // !_WIN32

