ACCEL_HOME := $(shell pwd)
SYSTEM := $(shell uname -s)

ifeq ($(SYSTEM),Linux)
	ifeq ($(shell grep Ubuntu /etc/issue),Ubuntu)
		DISTRO := Ubuntu
	else ($(shell grep Centos /etc/issue),Ubuntu)
		DISTRO := Centos
	endif
endif

MYSQL_INCDIR := "/usr/include/mysql/"
YAML_LIBDIR := "/usr/lib/x86_64-linux-gnu"

default: ready

ready: deps ngx_openresty/nginx/sbin/nginx $(HOME)/.luarocks/bin/pinky $(HOME)/.luarocks/bin/moonc copy_rocks
	@./build
	@luarocks make --local

pinky-server: ngx_openresty/nginx/sbin/nginx $(HOME)/.luarocks/bin/pinky $(HOME)/.luarocks/bin/moonc restart
	@./build
	@luarocks make --local

deps: deps_$(SYSTEM)
	@true

restart:
	@./nginx/stop; ./nginx/start

submodule:
	@git submodule update --init --recursive

deps_Centos:
	@sudo yum install -y readline-devel memcached-devel mysql-devel openssl-devel pcre-devel perl luarocks lua lua-devel

deps_Ubuntu:
	@sudo aptitude install -y libreadline-dev libncurses5-dev libpcre3-dev libssl-dev perl luarocks luajit lua5.1 libmemcached-dev libsasl2-dev libyaml-0-2 libmysqlclient-dev

deps_Linux: deps_$(DISTRO)

deps_Darwin:
	@true

ngx_openresty/nginx/sbin/nginx:
	@cd vendor/projects/ngx_openresty && PATH="/sbin:$(PATH)" ./configure --prefix=$(ACCEL_HOME)/ngx_openresty --with-luajit --with-ld-opt=-L$(HOME)/local/lib --with-ld-opt=-L/usr/local/Cellar/pcre/8.32/lib --with-debug
	@cd vendor/projects/ngx_openresty && make
	@cd vendor/projects/ngx_openresty && make install

$(HOME)/.luarocks/bin/moonc:
	@luarocks build --local vendor/projects/moonscript-0.2.3-2.rockspec

$(HOME)/.luarocks/bin/pinky: submodule
	@cd vendor/projects/pinky && luarocks make MYSQL_INCDIR=$(MYSQL_INCDIR) YAML_LIBDIR=$(YAML_LIBDIR) --local pinky-0.1-0.rockspec

copy_rocks: $(HOME)/.luarocks/bin/pinky
	@rsync -av $(HOME)/.luarocks/ $(ACCEL_HOME)/.luarocks

test: ready
	@nginx/start
