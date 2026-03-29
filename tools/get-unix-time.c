#include <stdio.h>
#include <time.h>
#include <sys/time.h>

int main(const int argc, const char * const * const argv) {
  fprintf(stderr, "HH:MM:SS DD.MM.YYYY\n");

  unsigned int hour, min, sec, day, month, year;
  scanf("%02u:%02u:%02u %02u.%02u.%04u",
        &hour, &min, &sec, &day, &month, &year);

  struct tm time_tm = {
    sec, min, hour,
    day, month - 1, year - 1900,
    0,     /* tm_wday;   ignored */
    0,     /* tm_yday;   ignored */
    -1,    /* tm_isdst;  determine whether DST is in effect */
    0,     /* tm_gmtoff; man page doesn't say, but seems to be ignored */
    "UTC", /* tm_zone;   man page doesn't say, but seems to be ignored */
  };

  const time_t time_sec = mktime(&time_tm);

  fprintf(stderr, "Time: ");
  printf("%u\n", (const unsigned int) time_sec);

  if (argc > 1) {
    const char * const file = argv[1];

    const struct timeval time_val[] = {
      {time_sec, 0}, /* tv_sec, tv_usec */
      {time_sec, 0}  /* tv_sec, tv_usec */
    };

    if (lutimes(file, time_val) < 0)
      fprintf(stderr, "Error setting access and modification times of file \"%s\".\n", file);
    else
      fprintf(stderr, "Access and modification times of file \"%s\" changed.\n", file);
  }

  return 0;
}
