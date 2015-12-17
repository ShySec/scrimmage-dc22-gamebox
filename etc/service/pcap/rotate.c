#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
char buffer[4096];

int main(int argc, char** argv) {
    if(argc < 2) {
        puts("usage: rotate <file>");
        return 1;
    }

    // Open up the input file
    int in = open(argv[1], O_RDONLY);

    if(in < 0) {
        perror("input");
        return 1;
    }

    // Move it to the destination
    int out = open("/tmp/latest.pcap", O_CREAT | O_RDWR | O_TRUNC);

    if(out < 0) {
        perror("output");
        return 1;
    }

    if(chmod("/tmp/latest.pcap", 0644) != 0) {
        perror("chmod");
        return 1;
    }

    ssize_t n = 0;
    while(0 < (n = read(in, buffer, sizeof(buffer)))) {
        write(out, buffer, n);
    }
}
