#include <stdio.h>
#include <sys/syscall.h>
#include <unistd.h>

int main() {
  // printf("Hello World\n");
  write(1, "Hello World\n", 13);
  // syscall(SYS_write, 1, "Hello World\n", 13);
  return 0;
}
