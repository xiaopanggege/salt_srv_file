# 给history添加时间和操作人
/etc/profile:
  file.append:
    - text:
      - export HISTTIMEFORMAT="%F %T `whoami` "
