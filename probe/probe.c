#include <dlfcn.h>
#include <stdio.h>
int main(int argc, char **argv) {
    void *h = dlopen(argv[1], RTLD_NOW);
    if (!h) { printf("dlopen-failed: %s\n", dlerror()); return 3; }
    printf("dlopen-ok\n");
    if (!dlsym(h, "StartBot")) { printf("sym-missing\n"); return 4; }
    printf("sym-ok\n");
    return 0;
}
