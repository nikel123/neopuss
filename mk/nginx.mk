export NGINX_PORT          := 8080
export NGINX_DOCUMENT_ROOT := $(CURDIR)/html
export NGINX_CONFIG        := $(realpath nginx/nginx.conf)
export NGINX_LOG_PATH      := $(CURDIR)/nginx/log
export NGINX_EXE           := /usr/bin/nginx
export NGINX_VAR_PATH      := $(CURDIR)/nginx/var

nginx/nginx.conf: nginx/nginx.conf.sh mk/nginx.mk config.mk
	'$<' > '$@'

~/.config/systemd/user/nginx_neopuss.service: nginx/nginx_neopuss.service.sh mk/nginx.mk config.mk
	'$<' > '$@'
	systemctl --user daemon-reload

start: start_nginx
stop: stop_nginx

.PHONY: start_nginx stop_nginx test_nginx

start_nginx: ~/.config/systemd/user/nginx_neopuss.service nginx/nginx.conf
	-systemctl --user reload nginx_neopuss
	systemctl --user start nginx_neopuss

stop_nginx:
	-systemctl --user stop nginx_neopuss

test_nginx: nginx/nginx.conf
	'$(NGINX_EXE)' -t -c '$(realpath $<)'
