# 修改配置文件，重启才能生效
disabled_selinux:
  file.replace:
    - name: /etc/selinux/config
    - pattern: SELINUX=enforcing
    - repl: SELINUX=disabled
# 命令设置不重启临时修改selinux为permissive模式 临时关闭
set_selinux_permissive:
  cmd.run:
    - name: setenforce 0
    - unless: test $(getenforce) != Enforcing
