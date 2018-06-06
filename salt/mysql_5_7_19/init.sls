#这是一个后期可以支持多实例mysql的部署state
#数据目录设置为/data/mysql/data 以端口号来区分多实例的数据目录的上层目录
#my.cnf和pid还有sock等都放在/data/mysql/下，数据相关的如日志logs，临时文件都放在/data/mysql/data/下

#删除旧的mysql相关文件
mysql_delete:
  cmd.run:
    - name: rpm -ev $(rpm -qa |grep mysql) --nodeps
    - onlyif: rpm -qa |grep mysql

#安装mysql依赖
mysql_pkg:
  pkg.installed:
    - pkgs:
      - libaio
      - perl
      - perl-devel
      - autoconf
    - require:
      - cmd: mysql_delete


#创建mysql用户组
mysql_user:
  user.present:
    - name: mysql
    - createhome: Fales
    - gid_from_name: True
    - shell: /sbin/nologin
    - unless: cat /etc/passwd | grep mysql
    - require:
      - pkg: mysql_pkg


#发送mysql5.6.24二进制安装包、解压、赋权
mysql_src:
  file.managed:
    - name: /tmp/mysql-5.7.19-linux-glibc2.12-x86_64.tar.gz
    - user: root
    - group: root
    - makedirs: True
    - source: salt://mysql_5_7_19/files/mysql-5.7.19-linux-glibc2.12-x86_64.tar.gz
    - unless:
      - test -e /tmp/mysql-5.7.19-linux-glibc2.12-x86_64.tar.gz
    - require:
      - user: mysql_user
mysql_tar:
  cmd.run:
    - cwd: /usr/local
    - unless:
      - test -d /usr/local/mysql
    - name: tar -xf /tmp/mysql-5.7.19-linux-glibc2.12-x86_64.tar.gz&&mv mysql-5.7.19-linux-glibc2.12-x86_64 mysql&&chown -R mysql:mysql  /usr/local/mysql
    - require:
      - file: mysql_src



#创建数据文件夹
create_data:
  cmd.run:
    - name: mkdir -p /data/mysql/data&&mkdir -p /data/logs/mysql&&chown -R mysql:mysql /data/logs/mysql&&chown -R mysql:mysql  /data/mysql
    - unless:
      - test -d /data/mysql/data
      - test -d /data/logs/mysql
    - require:
      - cmd: mysql_tar


#添加配置文件
mysql_cnf:
  file.managed:
    - name: /etc/my.cnf
    - user: mysql
    - group: mysql
    - makedirs: True
    - source: salt://mysql_5_7_19/files/my.cnf
    - unless: test -e /etc/my.cnf
    - require:
      - cmd: create_data

#初始化
mysql_install:
  cmd.run:
    - cwd: /usr/local/mysql
    - name: ./bin/mysqld --initialize-insecure 
    - onchanges:
      - file: mysql_cnf


# 添加环境变量，不需要source /etc/profile因为salt运行没效果
add_mysql_path:
  file.append:
    - name: /etc/profile
    - text: export PATH=$PATH:/usr/local/mysql/bin
    - require:
      - cmd: mysql_install


#添加启动项
{% if grains['osmajorrelease']==6 %}
mysql_server:
  file.managed:
    - name: /etc/init.d/mysqld
    - source: salt://mysql_5_7_19/files/mysqld
    - mode: 755
    - unless: test -e /etc/init.d/mysqld
    - require:
      - file: add_mysql_path
  cmd.run:
    - name: chkconfig --add mysqld
    - onchanges:
      - file: mysql_server
  service.running:
    - name: mysqld
    - enable: true
    - require:
      - cmd: mysql_server
{% elif grains['osmajorrelease']==7 %}
mysql_server:
  file.managed:
    - name: /usr/lib/systemd/system/mysqld.service
    - source: salt://mysql_5_7_19/files/mysqld.service
    - mode: 755
    - unless: test -e /usr/lib/systemd/system/mysqld.service
    - require:
      - file: add_mysql_path
systemd_reload:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:  
      - file: mysql_server
start_service:
  service.running:
    - name: mysqld
    - enable: true
    - require:
      - cmd: systemd_reload
{% endif %} 
    
