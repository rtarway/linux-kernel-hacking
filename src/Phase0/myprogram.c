#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>

int main() {
  // Open a file named "input.txt" for reading only
  // O_RDONLY is the flag for read-only access (0)

  // "input.txt" is the path to the file
  // O_RDONLY is the mode (read-only)
  int fd = open("input.txt", O_RDONLY);

  if (fd < 0) {
    // perror prints a descriptive error message to stderr
    // e.g., "Error opening file: No such file or directory"
    perror("Error opening file");
    return 1;
  }

  char buffer[10];

  // Read 10 bytes from the file into the buffer
  // fd: file descriptor to read from
  // buffer: where to store the data
  // 10: number of bytes to read
  ssize_t bytesRead = read(fd, buffer, 10);

  if (bytesRead < 0) {
    perror("Error reading file");
    close(fd);
    return 1;
  }

  // Write the read bytes to STDOUT (File Descriptor 1)
  write(1, buffer, bytesRead);

  // Write a newline for clean output
  write(1, "\n", 1);

  printf("File is open! Run 'lsof -p %d' in another terminal.\n", getpid());
  printf("Press Enter to continue...\n");
  getchar();

  // Close the file descriptor
  close(fd);

  return 0;
}
