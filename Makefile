PINKY_SERVER := $(shell pwd)
SYSTEM := $(shell uname -s)
MYSQL_INCDIR := "/usr/include/mysql/"
YAML_LIBDIR := "/usr/lib/x86_64-linux-gnu"

default: ready

submodule:
	@git submodule update --init --recursive

ready: deps ngx_openresty/nginx/sbin/nginx $(HOME)/.luarocks/bin/pinky
	@cd vendor/projects/accelerator && luarocks make --tree=$(PINKY_SERVER)/vendor/luarocks accelerator-1.0-1.rockspec

$(HOME)/.luarocks/bin/pinky: submodule
	@cd vendor/projects/pinky && luarocks make MYSQL_INCDIR=$(MYSQL_INCDIR) YAML_LIBDIR=$(YAML_LIBDIR) --tree=$(PINKY_SERVER)/vendor/luarocks pinky-0.1-0.rockspec

ngx_openresty/nginx/sbin/nginx:
	@cd vendor/projects/ngx_openresty && PATH="/sbin:$(PATH)" ./configure --prefix=$(PINKY_SERVER)/ngx_openresty --with-luajit --with-ld-opt=-L$(HOME)/local/lib --with-ld-opt=-L/usr/local/Cellar/pcre/8.32/lib --with-debug
	@cd vendor/projects/ngx_openresty && make
	@cd vendor/projects/ngx_openresty && make install

deps: deps_$(SYSTEM)

deps_Linux:
	@sudo aptitude install -y libreadline-dev libncurses5-dev libpcre3-dev libssl-dev perl luarocks luajit lua5.1 libmemcached-dev libsasl2-dev libyaml-0-2 libmysqlclient-dev

deps_Darwin:
	@true

test: ready
	@nginx/start
