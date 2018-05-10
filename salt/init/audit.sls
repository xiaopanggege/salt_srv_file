# 把用户在命令行输入的的记录都记录到/var/log/message上去
/etc/bashrc:
  file.append:
    - text:
      - export PROMPT_COMMAND='{ msg=$(history 1|{ read x y; echo $y; });logger "[euid=$(whoami)]":$(who am i):[`pwd`]"$msg";}'
