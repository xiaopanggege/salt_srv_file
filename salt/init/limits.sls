# 修改应用程序打开文件数等
/etc/security/limits.conf:
  file.append:
    - text: |
        * soft nproc 65535
        * hard nproc 65535
        * soft nofile 65535
        * hard nofile 65535

# 直接生效，上面的重启才能生效,后来发现这个参数通过salt来改不生效的下面这个命令是当前登录用户shell生效
# 只要上面的配置了断开连接在连上去就会发现生效了，不过不知道如何不重启让所有shell用户生效
#ulimit_operation:
#  cmd.run:
#    - name: ulimit -HSn 65535
