#安装nginx依赖
nginx_pkg:
  pkg.installed:
    - pkgs:
      - gcc
      - gcc-c++
      - autoconf
      - automake
      - openssl
      - openssl-devel
      - pcre-devel
      - zlib
      - zlib-devel
      - zip
      - unzip
      - patch

#传送nginx安装包并解压
nginx_src:
  file.managed:
    - name: /usr/local/src/nginx-1.10.3.tar.gz
    - user: root
    - group: root
    - makedirs: True
    - source: salt://nginx/files/nginx-1.10.3.tar.gz
    - unless: test -e /usr/local/src/nginx-1.10.3.tar.gz

nginx_tar:
  cmd.run:
    - cwd: /usr/local/src
    - unless: test -d nginx-1.10.3
    - name: tar -xf nginx-1.10.3.tar.gz
    - require:
      - file: nginx_src

#传送nginx第三方模块nginx_upstream_check_module-master并解压并打补丁呵呵
nginx_upstream_check_module-master:
  file.managed:
    - name: /usr/local/src/nginx_upstream_check_module-master.zip
    - user: root
    - group: root
    - makedirs: True
    - source: salt://nginx/files/nginx_upstream_check_module-master.zip
    - unless: test -e /usr/local/src/nginx_upstream_check_module-master.zip

nginx_upstream_check_module-master_unzip:
  cmd.run:
    - cwd: /usr/local/src
    - unless: test -d nginx_upstream_check_module-master
    - name: unzip nginx_upstream_check_module-master.zip
    - require:
      - file: nginx_upstream_check_module-master

nginx_upstream_check_module-master_patch:
  cmd.run:
    - name: patch -p0 < /usr/local/src/nginx_upstream_check_module-master/check_1.11.1+.patch
    - cwd: /usr/local/src/nginx-1.10.3
    - onchanges:
      - cmd: nginx_upstream_check_module-master_unzip
      - cmd: nginx_tar

#传送nginx第三方模块ngx_cache_purge
nginx_ngx_cache_purge:
  file.managed:
    - name: /usr/local/src/ngx_cache_purge-2.3.tar.gz
    - user: root
    - group: root
    - makedirs: True
    - source: salt://nginx/files/ngx_cache_purge-2.3.tar.gz
    - unless: test -e /usr/local/src/ngx_cache_purge-2.3.tar.gz

nginx_ngx_cache_purge_tar:
  cmd.run:
    - cwd: /usr/local/src
    - unless: test -d ngx_cache_purge-2.3
    - name: tar -xf ngx_cache_purge-2.3.tar.gz
    - require:
      - file: nginx_ngx_cache_purge

#创建nginx用户 后来决定用系统自带的nobody
#nginx_user:
#  user.present:
#    - name: www
#    - createhome: False
#    - gid_from_name: True
#    - shell: /sbin/nologin
    

#编译安装nginx,添加了一个可选的安装目录，方便以后需要自定义目录可以从pillar传过来
nginx_configure:
  cmd.run:
    - cwd: /usr/local/src/nginx-1.10.3
    - names:
      - ./configure --prefix={{ pillar.get('nginx_path','/usr/local/nginx') }} --with-http_stub_status_module --with-http_ssl_module --with-http_realip_module --add-module=/usr/local/src/ngx_cache_purge-2.3  --add-module=/usr/local/src/nginx_upstream_check_module-master&&make&&make install
    - unless: test -d {{ pillar.get('nginx_path','/usr/local/nginx') }}
    - require:
      - cmd: nginx_tar
      - pkg: nginx_pkg
      - cmd: nginx_ngx_cache_purge_tar
      - cmd: nginx_upstream_check_module-master_patch


#创建web目录（可选，如果做lnmp使用的话要）
#create_data:
#  cmd.run:
#    - name: /bin/mkdir -p /data/www&&chown -R www.www /data/www
#    - unless: test -d /data/www
#    - require:
#      - user: nginx_user

#创建vhosts目录
create_vhosts:
  cmd.run:
    - name: /bin/mkdir -p {{ pillar.get('nginx_path','/usr/local/nginx') }}/conf/vhosts
    - onlyif: test -d {{ pillar.get('nginx_path','/usr/local/nginx') }}/conf
    - unless: test -d {{ pillar.get('nginx_path','/usr/local/nginx') }}/conf/vhosts
