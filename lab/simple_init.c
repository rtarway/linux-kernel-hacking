#include <stdio.h>
#include <unistd.h>

int main() {
  printf("\n");
  printf("========================================\n");
  printf("   Hello from Minimal C Init!           \n");
  printf("   If you see this, Kernel is OK!       \n");
  printf("========================================\n");
  printf("\n");

  // Don't exit, or kernel will panic
  while (1) {
    sleep(1);
  }
  return 0;
}
