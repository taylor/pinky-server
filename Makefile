PINKY_SERVER := $(shell pwd)
MYSQL_INCDIR := "/usr/include/mysql/"
YAML_LIBDIR := "/usr/lib/x86_64-linux-gnu"

default: ready

submodule:
	@git submodule update --init --recursive

ready: ngx_openresty/nginx/sbin/nginx $(HOME)/.luarocks/bin/pinky $(HOME)/.luarocks/share/lua/5.1/accelerator.lua

# build accelerator
$(HOME)/.luarocks/share/lua/5.1/accelerator.lua: submodule
	@cd vendor/projects/accelerator && luarocks make --tree=$(PINKY_SERVER)/vendor/projects/pinky/.luarocks accelerator-1.0-1.rockspec

# build pinky
$(HOME)/.luarocks/bin/pinky: submodule
	@cd vendor/projects/pinky && luarocks make MYSQL_INCDIR=$(MYSQL_INCDIR) YAML_LIBDIR=$(YAML_LIBDIR) --tree=$(PINKY_SERVER)/vendor/projects/pinky/.luarocks pinky-0.1-0.rockspec

# build openresty
ngx_openresty/nginx/sbin/nginx:
	@cd vendor/projects/ngx_openresty && PATH="/sbin:$(PATH)" ./configure --prefix=$(PINKY_SERVER)/ngx_openresty --with-luajit --with-ld-opt=-L$(HOME)/local/lib --with-ld-opt=-L/usr/local/Cellar/pcre/8.32/lib --with-debug
	@cd vendor/projects/ngx_openresty && make
	@cd vendor/projects/ngx_openresty && make install

test: ready
	@nginx/start

pinky-server: ready
	@nginx/stop
	@nginx/start
