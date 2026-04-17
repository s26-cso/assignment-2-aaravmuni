#include <stdio.h>
#include <dlfcn.h>
#include <string.h>

int main()
{
    char operations[100];
    int a,b;

    while(scanf("%s %d %d", operations, &a, &b) == 3)
    {

    char libname[100] = "lib";
    strcat(libname, operations);
    strcat(libname, ".so");

    void *handle = dlopen(libname, RTLD_LAZY);

    int(*func)(int,int);
    func = dlsym(handle,operations);

    int result = func(a,b);

    printf("%d\n", result);

    dlclose(handle);
    }

    return 0;
}