#!/bin/sh
cat <<END
server {
  listen $NGINX_PORT;
  root $NGINX_DOCUMENT_ROOT;

  location / {
  }
}
END
