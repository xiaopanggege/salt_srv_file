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
    - name: /usr/local/src/nginx-1.14.1.tar.gz
    - user: root
    - group: root
    - makedirs: True
    - source: salt://nginx/files/nginx-1.14.1.tar.gz
    - unless: test -e /usr/local/src/nginx-1.14.1.tar.gz

nginx_tar:
  cmd.run:
    - cwd: /usr/local/src
    - unless: test -d nginx-1.14.1
    - name: tar -xf nginx-1.14.1.tar.gz
    - require:
      - file: nginx_src

#传送nginx第三方模块ngx_cache_purge
nginx-module-vts:
  file.managed:
    - name: /usr/local/src/nginx-module-vts.tar.gz  
    - user: root
    - group: root
    - makedirs: True
    - source: salt://nginx/files/nginx-module-vts.tar.gz  
    - unless: test -e /usr/local/src/nginx-module-vts.tar.gz  
  cmd.run:
    - cwd: /usr/local/src
    - unless: test -d nginx-module-vts
    - name: tar -xf nginx-module-vts.tar.gz
    - require:
      - file: nginx-module-vts

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
    - cwd: /usr/local/src/nginx-1.14.1
    - names:
      - ./configure --prefix={{ pillar.get('nginx_path','/usr/local/nginx') }} --with-http_stub_status_module --with-http_ssl_module --with-http_realip_module --with-stream --add-module=/usr/local/src/nginx-module-vts&&make&&make install
    - unless: test -d {{ pillar.get('nginx_path','/usr/local/nginx') }}
    - require:
      - cmd: nginx_tar
      - pkg: nginx_pkg
      - cmd: nginx-module-vts


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


#创建log目录，因为我配置把日志文件单独存放了不在安装目录下
create_log_dir:
  cmd.run:
    - name: /bin/mkdir -p /data/logs/nginx
    - unless: test -d /data/logs/nginx
    - require:
      - cmd: create_vhosts
