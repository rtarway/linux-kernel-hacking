#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>

int main() {
  pid_t pid = fork();

  if (pid < 0) {
    // Fork failed
    perror("Fork failed");
    return 1;
  } else if (pid == 0) {
    // This block is executed by the CHILD process
    printf("I am the Child! (PID: %d).\n", getpid());
    while (1) {
      printf("I am the Child! (PID: %d). I will loop forever until killed.\n",
             getpid());
      sleep(1); // Sleep to avoid burning CPU
    }
  } else {
    // This block is executed by the PARENT process
    printf("I am the Parent! (PID: %d, Child PID: %d)\n", getpid(), pid);
    printf("Run 'kill -9 %d' in another terminal to kill the child.\n", pid);

    while (1) {
      printf("I am the Parent! (PID: %d, Child PID: %d)\n", getpid(), pid);
      sleep(1);
    }
    printf("Parent exiting now...\n");
  }

  return 0;
}
