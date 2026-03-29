#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define DFLTLENGTH 10
#define MAXLENGTH  22

typedef char bool;

#define TRUE  1
#define FALSE 0

int main(const int argc, const char * const * const argv) {
  char pw[MAXLENGTH + 1];
  char candidate;
  unsigned int length;
  unsigned int i, j;
  unsigned int min, max;
  bool first_try, duplicate;

  if (argc >= 2)
    length = atoi(argv[1]);
  else
    length = DFLTLENGTH;

  if (length > MAXLENGTH)
    length = MAXLENGTH;
  if (length % 2 != 0)
    length--;

  fprintf(stderr, "Length: %u\n", length);

  srand(time(NULL));

  for (i = 0; i < length; i++) {
    if ((i % 4) / 2 == 0) {
      min = 97;
      max = 122;
    }
    else {
      min = 48;
      max = 57;
    }

    first_try = TRUE;

    while (first_try || duplicate) {
      /* TODO: Instead of trial and error, use a list of characters/digits not yet used. */
      candidate = min + (unsigned int) ((max - min + 1.0) * rand() / (RAND_MAX + 1.0));

      first_try = FALSE;
      duplicate = FALSE;

      for (j = 0; j < i; j++) {
        if (pw[j] == candidate) {
          duplicate = TRUE;
          break;
        }
      }
    }

    pw[i] = candidate;
  }

  pw[length] = 0;

  printf("%s\n", pw);

  return 0;
}
