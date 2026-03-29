#define _GNU_SOURCE

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>

int main(const int argc, const char * const * const argv) {
  if (argc < 2) {
    fprintf(stderr, "Usage: %s FILE ...\n", argv[0]);
    return 1;
  }

  for (int i = 1; i < argc; i++) {
    const  char  *file      = argv[i];
    struct statx  buf_statx;

    /* Get creation time. */
    if (statx(AT_FDCWD, file, AT_SYMLINK_NOFOLLOW, STATX_BTIME, &buf_statx) < 0) {
      fprintf(stderr, "Failed to stat file \"%s\": %s\n", file, strerror(errno));
      return 1;
    }

    const struct timespec times[] = {
      {buf_statx.stx_btime.tv_sec, buf_statx.stx_btime.tv_nsec}, /* tv_sec, tv_nsec */
      {buf_statx.stx_btime.tv_sec, buf_statx.stx_btime.tv_nsec}  /* tv_sec, tv_nsec */
    };

    if (utimensat(AT_FDCWD, file, times, AT_SYMLINK_NOFOLLOW) < 0) {
      fprintf(stderr, "Failed to set modification and access times of file \"%s\": %s\n",
              file, strerror(errno));
      return 1;
    }
  }

  return 0;
}
