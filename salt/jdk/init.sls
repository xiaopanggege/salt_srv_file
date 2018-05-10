#传输jdk文件
send_jdk_file:
  file.managed:
    - source: salt://jdk/files/jdk-8u152-linux-x64.tar.gz
    - name: /usr/local/java/jdk-8u152-linux-x64.tar.gz
    - user: root
    - group: root
    - makedirs: True
    - unless:
      - test -e /usr/local/java/jdk-8u152-linux-x64.tar.gz

#解压jdk
tar_jdk:
  cmd.run:
    - cwd: /usr/local/java
    - name: tar -xf jdk-8u152-linux-x64.tar.gz
    - unless:
      - test -e /usr/local/java/jdk1.8.0_152
    - require:
      - file: send_jdk_file
#删除压缩包
delete_tar:
  file.absent:
    - name: /usr/local/java/jdk-8u152-linux-x64.tar.gz
    - require:
      - cmd: tar_jdk

#环境变量设置
change_profile:
  file.append:
    - name: /etc/profile
    - text:
      - export JAVA_HOME=/usr/local/java/jdk1.8.0_152
      - export PATH=$JAVA_HOME/bin:$PATH
      - export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/jre/lib/rt.jar
    - require:
      - cmd: tar_jdk

#环境变量生效
source_profile:
  cmd.run:
    - name: source /etc/profile
    - onchanges:
      - file: change_profile
