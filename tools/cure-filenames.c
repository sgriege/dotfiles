#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void cure_filename(const char * const file);
void remove_unprintable_chars(char * const str);

int main(const int argc, const char * const * const argv) {
  for (int i = 1; i < argc; i++)
    cure_filename(argv[i]);
  return EXIT_SUCCESS;
}

void cure_filename(const char * const file) {
  char *cured = strdup(file);

  if (!cured) {
    fprintf(stderr, "Failed to duplicate string: %s\n", strerror(errno));
    exit(EXIT_FAILURE);
  }

  remove_unprintable_chars(cured);

  if (!strcmp(file, cured))
    fprintf(stderr, "File \"%s\" left unmodified.\n", file);
  else if (rename(file, cured))
    fprintf(stderr, "Failed to rename file \"%s\": %s\n", file, strerror(errno));

  free(cured);
  return;
}

void remove_unprintable_chars(char * const str) {
  for (size_t i = 0; i < strlen(str); i++) {
    if (str[i] < 32 || str[i] > 126)
      str[i] = '_';
  }

  return;
}
