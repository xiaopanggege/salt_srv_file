#这是一个后期可以支持多实例mysql的部署state
#数据目录设置为/data/mysql3306/data 以端口号来区分多实例的数据目录的上层目录
#my.cnf和pid还有sock等都放在/data/mysql3306/下，数据相关的如日志logs，临时文件都放在/data/mysql3306/data/下

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
    - source: salt://mysql/files/mysql-5.7.19-linux-glibc2.12-x86_64.tar.gz
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
    - name: mkdir -p /data/mysql3306/data&&mkdir -p /data/mysql3306/logs/binlog&&touch /data/mysql3306/logs/error.log&&chown -R mysql:mysql  /data/mysql3306
    - unless:
      - test -d /data/mysql3306/data
      - test -d /data/mysql3306/logs
    - require:
      - cmd: mysql_tar


#添加配置文件
mysql_cnf:
  file.managed:
    - name: /data/mysql3306/my.cnf
    - user: mysql
    - group: mysql
    - makedirs: True
    - source: salt://mysql/files/my.cnf
    - unless: test -e /data/mysql3306/my.cnf
    - require:
      - cmd: create_data

#初始化
mysql_install:
  cmd.run:
    - cwd: /usr/local/mysql
    - name: ./bin/mysqld --initialize-insecure  --user=mysql --basedir=/usr/local/mysql --datadir=/data/mysql3306/data --explicit_defaults_for_timestamp
    - onchanges:
      - file: mysql_cnf

#添加软连接
mysql_ln:
  cmd.run:
    - name: ln -s /usr/local/mysql/bin/mysql /usr/bin/mysql
    - unless: test -e /usr/bin/mysql
    - require:
      - cmd: mysql_install


#添加启动项
mysql_server:
  file.managed:
    - name: /etc/init.d/mysqld3306
    - source: salt://mysql/files/mysqld3306
    - mode: 755
    - unless: test -e /etc/init.d/mysqld3306
    - require:
      - cmd: mysql_ln

  
    
