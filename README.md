#Nginx Accelerator

Drop-in page caching using nginx, lua, and memcached.

##Features

* Listens to Cache-Control max-age header
* The memcached key is the URI (easy to expire on demand)
* Really, really fast

##Requirements

Nginx build with the following modules:

* [LuaJIT](http://wiki.nginx.org/HttpLuaModule)
* [MemcNginxModule](http://wiki.nginx.org/HttpMemcModule)
* [LuaRestyMemcachedLibrary](https://github.com/agentzh/lua-resty-memcached)

See the [Building OpenResty](#building-openresty) section below for instructions.

##Install

    luarocks install nginx-accelerator

##Usage

Drop the following line in any `location` directive within `nginx.conf`:

    access_by_lua "require('accelerator').access()";

For example:

    http {
      server {
        listen 8080;

        location = / {
          access_by_lua "require('accelerator').access()";
        }
      }
    }

The TTL is based on `Cache-Control: max-age`, but defaults to 10 seconds.

## Building OpenResty

Instructions for building [OpenResty](http://openresty.org) on OS X with [Homebrew](http://mxcl.github.com/homebrew):

###Install PCRE

	brew update
	brew install pcre

###Install nginx

	curl -O http://agentzh.org/misc/nginx/ngx_openresty-1.2.4.9.tar.gz
	tar xzvf ngx_openresty-1.2.4.9.tar.gz
	cd ngx_openresty-1.2.4.9/

Get your PCRE version:

	brew info pcre

Replace **VERSION** below with the PCRE version:

	./configure --with-luajit --with-cc-opt="-I/usr/local/Cellar/pcre/VERSION/include" --with-ld-opt="-L/usr/local/Cellar/pcre/VERSION/lib"
	make
	make install

###Start nginx

	PATH=/usr/local/openresty/nginx/sbin:$PATH
	export PATH
	nginx -p `pwd`/ -c conf/nginx.conf