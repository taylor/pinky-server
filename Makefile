ACCEL_HOME := $(shell pwd)
SYSTEM := $(shell uname -s)

ifeq ($(SYSTEM),Linux)
	ifeq ($(shell grep -ic Ubuntu /etc/issue),1)
		DISTRO := Ubuntu
		YAML_LIBDIR := "/usr/lib/x86_64-linux-gnu"
		MYSQL_INCDIR := "/usr/include/mysql/"
	else ifeq ($(shell grep -ic Centos /etc/issue),1)
		DISTRO := Centos
		YAML_LIBDIR := "/usr/lib64"
		MYSQL_INCDIR := "/usr/include/mysql/"
		MYSQL_LIBDIR := "/usr/lib64/mysql/"
	else ifeq ($([[ -f /etc/inittab ]] && shell grep -ic Gentoo /etc/inittab),3)
		DISTRO := Gentoo
		YAML_LIBDIR := "/usr/lib64"
		MYSQL_INCDIR := "/usr/include/mysql/"
		MYSQL_LIBDIR := "/usr/lib64/mysql/"
	else ifeq ($(shell grep -ic DISTRIB_ID=Arch /etc/lsb-release),1)
		DISTRO := Arch
		YAML_LIBDIR := "/usr/lib"
		MYSQL_INCDIR := "/usr/include/mysql/"
		MYSQL_LIBDIR := "/usr/lib"
	endif
endif

default: ready

ready: deps ngx_openresty/nginx/sbin/nginx $(HOME)/.luarocks/bin/pinky copy_rocks
	@luarocks make --local

pinky-server: ngx_openresty/nginx/sbin/nginx $(HOME)/.luarocks/bin/pinky restart
	@luarocks make --local

deps: deps_$(SYSTEM)
	@true

restart:
	@./nginx/stop; ./nginx/start

submodule:
	@git submodule update --init --recursive

deps_Centos:
	@sudo yum install -y readline-devel memcached-devel mysql-devel openssl-devel pcre-devel perl luarocks lua lua-devel ncurses-devel mysql libyaml-devel

deps_Gentoo:
	@sudo emerge dev-libs/libyaml

deps_Ubuntu:
	@sudo apt-get install -y libreadline-dev libncurses5-dev libpcre3-dev libssl-dev perl luarocks luajit lua5.1 libmemcached-dev libsasl2-dev libyaml-0-2 libmysqlclient-dev

deps_Arch:
	@sudo pacman -S libmysqlclient libyaml libmemcached readline lua luarocks ncurses openssl

deps_Linux: deps_$(DISTRO)

deps_Darwin:
	@true

ngx_openresty/nginx/sbin/nginx:
	@cd vendor/projects/ngx_openresty && PATH="/sbin:$(PATH)" ./configure --prefix=$(ACCEL_HOME)/ngx_openresty --with-luajit --with-ld-opt=-L$(HOME)/local/lib --with-ld-opt=-L/usr/local/Cellar/pcre/8.32/lib --with-debug
	@cd vendor/projects/ngx_openresty && make
	@cd vendor/projects/ngx_openresty && make install

$(HOME)/.luarocks/bin/pinky: submodule
	@cd vendor/projects/pinky && luarocks make MYSQL_LIBDIR=$(MYSQL_LIBDIR) MYSQL_INCDIR=$(MYSQL_INCDIR) YAML_LIBDIR=$(YAML_LIBDIR) --local pinky-0.1-0.rockspec

copy_rocks: $(HOME)/.luarocks/bin/pinky
	@rsync -av $(HOME)/.luarocks/ $(ACCEL_HOME)/.luarocks

test: ready
	@nginx/start
