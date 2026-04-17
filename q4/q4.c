#include <stdio.h>
#include <dlfcn.h>
#include <string.h>

int main()
{
    char operations[100];
    int a, b;

    while (scanf("%s %d %d", operations, &a, &b) == 3)
    {
        char libname[100] = "lib";
        strcat(libname, operations);
        strcat(libname, ".so");

        void *handle = dlopen(libname, RTLD_LAZY);
        if (!handle) {
            printf("dlopen error: %s\n", dlerror());
            continue;
        }

        dlerror();

        int (*func)(int, int);
        *(void **)(&func) = dlsym(handle, operations);

        char *error = dlerror();
        if (error != NULL) {
            printf("dlsym error: %s\n", error);
            dlclose(handle);
            continue;
        }

        int result = func(a, b);
        printf("%d\n", result);

        dlclose(handle);
    }

    return 0;
}