ACCEL_HOME := $(shell pwd)
SYSTEM := $(shell uname -s)
default: ready

ready: deps ngx_openresty/nginx/sbin/nginx $(HOME)/.luarocks/bin/moonc $(HOME)/.luarocks/bin/pinky
	@sudo -u pinky ./build
	@sudo -u pinky luarocks make --local

deps: deps_$(SYSTEM)
	@true

submodule:
	@sudo -u pinky git submodule update --init --recursive

deps_Linux:
	@sudo aptitude install -y libreadline-dev libncurses5-dev libpcre3-dev libssl-dev perl luarocks luajit lua5.1 libmemcached-dev libsasl2-dev libyaml-0-2 libmysqlclient-dev

deps_Darwin:
	@true

ngx_openresty/nginx/sbin/nginx:
	@cd vendor/projects/ngx_openresty && PATH="/sbin:$(PATH)" ./configure --prefix=$(ACCEL_HOME)/ngx_openresty --with-luajit --with-ld-opt=-L$(HOME)/local/lib --with-debug
	@cd vendor/projects/ngx_openresty && sudo -u pinky make
	@cd vendor/projects/ngx_openresty && sudo -u pinky make install

$(HOME)/.luarocks/bin/moonc:
	@sudo -u pinky luarocks build --local vendor/projects/moonscript-0.2.3-2.rockspec

$(HOME)/.luarocks/bin/pinky: submodule
	@cd vendor/projects/pinky && sudo -u pinky luarocks make MYSQL_INCDIR=/usr/include/mysql/ YAML_LIBDIR=/usr/lib/x86_64-linux-gnu --local pinky-0.1-0.rockspec

test: ready
	@nginx/start
