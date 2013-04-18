ACCEL_HOME := $(shell pwd)
default: ready

ready: ngx_openresty/nginx/sbin/nginx $(HOME)/.luarocks/bin/moonc
	@./build
	@luarocks make --local

ngx_openresty/nginx/sbin/nginx:
	@cd vendor/projects/ngx_openresty && ./configure --prefix=$(ACCEL_HOME)/ngx_openresty --with-luajit --with-ld-opt=-L$(HOME)/local/lib --with-debug
	@cd vendor/projects/ngx_openresty && make
	@cd vendor/projects/ngx_openresty && make install

$(HOME)/.luarocks/bin/moonc:
	@luarocks build --local vendor/projects/moonscript-0.2.3-2.rockspec

test: ready
	@nginx/start
