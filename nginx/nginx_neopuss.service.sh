#!/bin/sh
cat <<END
[Unit]
Description=Neopuss nginx development server unit

[Service]
ExecStartPre=/usr/bin/mkdir -p '$NGINX_LOG_PATH'
ExecStartPre=/usr/bin/mkdir -p '$NGINX_VAR_PATH'
ExecStart='$NGINX_EXE' -c '$NGINX_CONFIG'
Type=simple
ExecReload=/bin/kill -HUP $$MAINPID
KillSignal=SIGQUIT
KillMode=mixed
END
