ACCEL_HOME := $(shell pwd)
SYSTEM := $(shell uname -s)
default: ready

ready: ngx_openresty/nginx/sbin/nginx $(HOME)/.luarocks/bin/moonc
	@./build
	@luarocks make --local

deps: deps_$(SYSTEM)
	@true

deps_Linux:
	@sudo aptitude install -y libreadline-dev libncurses5-dev libpcre3-dev libssl-dev perl luarocks luajit lua libmemcached-dev libsasl2-dev

deps_Darwin:
	@true

ngx_openresty/nginx/sbin/nginx:
	@cd vendor/projects/ngx_openresty && PATH="/sbin:$(PATH)" ./configure --prefix=$(ACCEL_HOME)/ngx_openresty --with-luajit --with-ld-opt=-L$(HOME)/local/lib --with-debug
	@cd vendor/projects/ngx_openresty && make
	@cd vendor/projects/ngx_openresty && make install

$(HOME)/.luarocks/bin/moonc:
	@luarocks build --local vendor/projects/moonscript-0.2.3-2.rockspec

test: ready
	@nginx/start
