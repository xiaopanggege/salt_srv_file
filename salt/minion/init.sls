#利用salt-ssh安装指定版本2017.7.2的salt-minion到客户机

#官方步骤中为了修复bug添加了重装python-crypto这步骤,麻痹2.16.11版本需要选择2017不需要了！
#如果2017你加了下面的反而有可能报错无法执行，所以注释掉！
#install_pycrypto:
#  cmd.run:
#    - name: rpm -e --nodeps python2-pycryptodomex
#    - onlyif: rpm -qa | grep python2-pycryptodomex
#  pkg.installed:
#    - pkgs:
#      - python-crypto
#    - unless: rpm -qa | grep python-crypto
#    - require:
#      - cmd: install_pycrypto


#导入GPG-KEY
#所以如果要重装就yum remove salt* 会自动帮你删除repo和key的不需要手动删除
gpg_key:
  cmd.run:
    - name: rpm --import https://mirrors.ustc.edu.cn/salt/yum/redhat/{{ grains['osmajorrelease']}}/{{ grains['osarch']}}/archive/2017.7.5/SALTSTACK-GPG-KEY.pub
    - template: jinja

# 添加repo文件
copy_repo:
  file.managed:
    - name: /etc/yum.repos.d/saltstack.repo
    - source: salt://minion/files/saltstack.repo
    - require:
      - cmd: gpg_key


#清理下缓存
clear_cache:
  cmd.run:
    - name: yum clean expire-cache
    - require:
      - file: copy_repo

#yum安装salt-minion，修改配置文件
minion_install:
  pkg.installed:
    - pkgs:
      - salt-minion
    - unless: rpm -qa | grep salt-minion
    - require:
      - cmd: clear_cache 
  cmd.run:
    - name: |
        sed -i 's/#master: salt/master: {{ pillar.get('master','192.168.68.50') }}/g' /etc/salt/minion
        {% if 'minion_id' in pillar and pillar['minion_id'] %}
        sed -i 's/#id:/id: {{pillar['minion_id']}}/g' /etc/salt/minion
        {% endif %}
    - template: jinja
    - onchanges: 
      - pkg: minion_install


# 拷贝特殊文件sitecustomize.py到相应目录解决中文解码问题，注意如果不会用到中文则不需要这步
# 不需要这步的话下面启动的步骤onchanges要记得修改
# 2018.3.0出了py3版本支持中文了，所以可以不需要下面这步了
copy_sitecustomize:
  file.managed:
    - name: /usr/lib/python2.7/site-packages/sitecustomize.py
    - source: salt://minion/files/sitecustomize.py
    - onchanges:
      - cmd: minion_install

#启动salt-minion
minion_service:
  service.running:
    - name: salt-minion
    - enable: True
    - require:
      - file: copy_sitecustomize
    #- onchanges:
    #  - pkg: minion_install
