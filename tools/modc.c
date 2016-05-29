#define _GNU_SOURCE

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <regex.h>
#include <stdlib.h>
#include <errno.h>
#include <ev.h>
#include <stdint.h>

#define sizeofarray(arr) ((sizeof(arr))/sizeof(arr[0]))
#define min(a,b) (((a) > (b)) ? (b) : (a))

enum {
  BUF_SIZE = 4096
};

struct str_t {
  size_t      len;
  const char *str;
};
typedef struct str_t str_t;

struct copy_t {
  int     infd;
  int     outfd;
  int     ret;
  size_t  rlen;
  size_t  wlen;
  char   *buf;
  char   *buf_wi;
  ev_io  *in;
  ev_io  *out;
};
typedef struct copy_t copy_t;

struct my_io_t {
  ev_io   io;
  copy_t *copy;
};
typedef struct my_io_t my_io_t;

static void
print_reg_error(
    const char *func,
    regex_t *re,
    int status) {

  size_t len = regerror(status, re, 0, 0);
  char *buf = malloc(len);
  if ( buf ) {
    regerror(status, re, buf, len);
    fprintf(stderr, "%s() failed: %s\n", func, buf);
    free(buf);
  } else {
    fprintf(stderr,
        "%s() and then malloc() failed, so no error message for you\n",
        func);
  }
}

static void
syserr(const char *msg) {

  fprintf(stderr, "libev error: %s\n", msg);
  abort();

}

static void
usage(
    const char *name) {

  fprintf(stderr, "usage: %s <module js file>\n", name);

}

static int
get_module_name(
    const char *fname,
    str_t *module_name,
    str_t *module_class) {

  int ret;
  regex_t re;
  regmatch_t matches[3];

  ret = regcomp(&re, "[^/]+/+app/+(.+)[\\./]([[:alpha:]]+).js", REG_EXTENDED);
  if ( ret ) {
    print_reg_error("regcomp", &re, ret);
    goto err;
  }

  ret = regexec(&re, fname, sizeofarray(matches), matches, 0);

  regfree(&re);

  if ( ret )
    goto nomatch_err;

  module_name->len = matches[1].rm_eo - matches[1].rm_so;
  module_name->str = &(fname[matches[1].rm_so]);

  module_class->len = matches[2].rm_eo - matches[2].rm_so;
  module_class->str = &(fname[matches[2].rm_so]);

end:
  return ret;

nomatch_err:
  fprintf(stderr,
      "file name '%s' doesn't match proper module name\n",
      fname);
err:
  ret = 1;
  goto end;

}

static void
do_read(
    struct ev_loop *loop,
    ev_io *io,
    int revents) {

  ssize_t c;
  my_io_t *mio = (my_io_t*)io;
  copy_t *copy = mio->copy;

  c =
    read(
      copy->infd,
      copy->buf,
      min(BUF_SIZE, copy->rlen));

  if ( c == -1 ) {

    if (!(errno == EAGAIN || errno == EINTR)) {

      fprintf(stderr, "read() failed: %m\n");
      ev_io_stop(loop, io);
      ev_break(loop, EVBREAK_ALL);

    }

  } else if ( c ) {

    copy->rlen -= c;
    copy->wlen = c;
    copy->buf_wi = copy->buf;

    ev_io_stop(loop, io);
    ev_io_start(loop, copy->out);

  }

}

static void
do_write(
    struct ev_loop *loop,
    ev_io *io,
    int revents) {

  ssize_t c;
  my_io_t *mio = (my_io_t*)io;
  copy_t *copy = mio->copy;

  c =
    write(
      copy->outfd,
      copy->buf_wi,
      copy->wlen);

  if ( c == -1 ) {

    if (!(errno == EAGAIN || errno == EINTR)) {
    
      fprintf(stderr, "write() failed: %m\n");
      ev_io_stop(loop, io);
      ev_break(loop, EVBREAK_ALL);

    }

  } else if ( c ) {

    copy->wlen -= c;
    
    if ( copy->wlen ) {

      copy->buf_wi += c;

    } else {

      ev_io_stop(loop, io);

      if ( copy->rlen )
        ev_io_start(loop, copy->in);

    }

  }

}

static int
copy_module_body(
    int infd,
    int outfd) {

  int ret;
  struct stat s;
  my_io_t in_watcher;
  my_io_t out_watcher;
  struct ev_loop *loop;
  static char copy_buf[BUF_SIZE];

  ret = fstat(infd, &s);
  if ( ret ) {
    fprintf(stderr, "fstat() failed: %m\n");
    goto err;
  }

  copy_t copy  = {
      .infd   = infd,
      .outfd  = outfd,
      .ret    = 0,
      .rlen   = s.st_size,
      .wlen   = 0,
      .buf    = copy_buf,
      .buf_wi = 0,
      .in     = &in_watcher.io,
      .out    = &out_watcher.io
    };

  if ( copy.rlen == 0 ) {
    ret = 0;
    goto end;
  }

  ev_set_syserr_cb(syserr);

  loop = ev_default_loop(0);
  if ( !loop ) {
    fprintf(stderr, "ev_default_loop() failed\n");
    goto err;
  }

  in_watcher.copy = out_watcher.copy = &copy;

  ev_io_init(&in_watcher.io,  do_read,  infd,  EV_READ);
  ev_io_init(&out_watcher.io, do_write, outfd, EV_WRITE);

  ev_io_start(loop, &in_watcher.io);

  while(ev_run(loop, 0));

  ev_loop_destroy(loop);

  ret = copy.ret;

end:
  return ret;

err:
  ret = 1;
  goto end;


}

static int
output_header(
    str_t *module_name,
    str_t *module_class) {

  int ret;
  const char hdr1[] = "App.register('";
  const char hdr2[] = "',(function(){\n";
  size_t len;
  size_t c;
  char *buf, *i;
  
  len = sizeof(hdr1) + sizeof(hdr2) - 1 +
        module_name->len + module_class->len;

  buf = malloc(len);
  if ( !buf ) {
    fprintf(stderr, "malloc() failed\n");
    goto malloc_err;
  }

  memcpy(buf, hdr1, sizeof(hdr1) - 1);

  i = buf + sizeof(hdr1) - 1;

  memcpy(i, module_class->str, module_class->len);

  i += module_class->len;
  *i = ':';
  ++i;

  memcpy(i, module_name->str, module_name->len);

  i += module_name->len;

  memcpy(i, hdr2, sizeof(hdr2) - 1);

  do {
  
    c = write(STDOUT_FILENO, buf, len);

    if ( c == -1 ) {
      if ( errno != EINTR ) {

        fprintf(stderr, "write() failed: %m\n");
        goto err;

      } else {
        continue;
      }
    }

    len -= c;

  } while ( len );


  free(buf);

  ret = 0;
end:
  return ret;

err:
  free(buf);
malloc_err:
  ret = 1;
  goto err;

}

static int
output_footer() {

  int ret;
  ssize_t c;

  const char str[] = "\n})());\n";

  c = write(STDOUT_FILENO, str, sizeof(str) - 1);

  ret = 0;
end:
  return ret;

err:
  ret = 1;
  goto end;

}

static int
fill_module(
    int fd,
    str_t *module_name,
    str_t *module_class) {

  int ret;

  ret = output_header(module_name, module_class);
  if (ret) goto end;

  ret = copy_module_body(fd, STDOUT_FILENO);
  if ( ret ) goto end;

  ret = output_footer();

end:
  return ret;

}

static int
output_module(
    const char *fname,
    str_t *module_name,
    str_t *module_class) {

  int ret;
  int fd;
  
  fd = open(fname, O_RDONLY | O_NONBLOCK);

  if ( fd == -1 )
    goto err;

  ret =
      fill_module(
          fd,
          module_name,
          module_class);

  close(fd);

end:
  return ret;

err:
  fprintf(stderr, "open(\"%s\") failed: %m\n", fname);
  ret = 1;
  goto end;

}

int
main(
    int    argc,
    char **argv) {

  int ret;
  str_t module_name;
  str_t module_class;

  if ( argc != 2 ) {
     usage(argv[0]);
     goto err;
  }

  ret =
      get_module_name(
          argv[1],
          &module_name,
          &module_class);

  if ( ret )
    goto end;

  ret =
      output_module(
          argv[1],
          &module_name,
          &module_class);

end:
  return ret;

err:
  ret = 1;
  goto end;

}
