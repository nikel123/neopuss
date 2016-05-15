export NGINX_PORT := 8080
export NGINX_DOCUMENT_ROOT := $(CURDIR)/html

nginx/nginx.conf: nginx/nginx.conf.sh mk/nginx.mk config.mk
	"$<" > "$@"
