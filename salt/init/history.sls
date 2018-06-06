# 给history添加时间和操作人,并且记录所有用户bash历史命令到/var/log/bash_history.log
/etc/profile:
  file.append:
    - text: |
        function log2syslog
        {
          export HISTTIMEFORMAT="%F %T `whoami` "
          export PROMPT_COMMAND='\
          if [ -z "$OLD_PWD" ];then
              export OLD_PWD=$(pwd);
          fi;
          if [ ! -z "$LAST_CMD" ] && [ "$(history 1)" != "$LAST_CMD" ]; then
              logger  `who am i`_shell_cmd: "[$OLD_PWD] $(history 1|{ read x y; echo $y; })";
          fi;
          export LAST_CMD="$(history 1)";
          export OLD_PWD=$(pwd);'
        }
        trap log2syslog DEBUG
    - unless: grep log2syslog /etc/profile

# 后面发现加了下面的生效也没用，正在连接的都是要先断开连接再重新连接才能生效，比较这是salt后台运行
#env_source:
#    cmd.run:
#        - name: source /etc/profile
#        - unless: env |grep  HISTTIMEFORMAT
#        - require:
#            - file: /etc/profile
