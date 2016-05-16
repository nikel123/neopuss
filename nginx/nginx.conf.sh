#!/bin/sh
cat <<END
daemon off;
error_log $NGINX_LOG_PATH/error.log info;
pid $NGINX_VAR_PATH/nginx.pid;

events {
  use epoll;
}

http {
  client_body_temp_path $NGINX_VAR_PATH/client_body/;
  fastcgi_temp_path $NGINX_VAR_PATH/fastcgi/;
  uwsgi_temp_path $NGINX_VAR_PATH/uwsgi/;
  scgi_temp_path $NGINX_VAR_PATH/scgi/;

  access_log $NGINX_LOG_PATH/access.log;

  server {
    listen $NGINX_PORT;
    root $NGINX_DOCUMENT_ROOT;

    location / {
    }
  }

}
END
