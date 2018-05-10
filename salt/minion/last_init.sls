#利用salt-ssh安装salt-minion到客户机
#有一个问题要注意就是，下面是安装最新版的，所以master要保持更新不然无法控制minion等下哈哈
#之前就发现官网突然更新版本，minion安装的版本比早期安装是master还高，无语

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


#安装repo和gpg-key
#如果安装过的客户端会存在下面unless里的key和repo文件，另外还会安装salt-repo-latest-2.el6.noarch
#所以如果要重装就yum remove salt* 会自动帮你删除repo和key的不需要手动删除
gpg_key:
  cmd.run:
    - name: yum install https://repo.saltstack.com/yum/redhat/salt-repo-latest-2.el{{ grains['osmajorrelease']}}.noarch.rpm -y
    - template: jinja
    - unless: test -e /etc/pki/rpm-gpg/saltstack-signing-key&&test -e /etc/yum.repos.d/salt-latest.repo

#清理下缓存
clear_cache:
  cmd.run:
    - name: yum clean expire-cache
    - onchanges:
      - cmd: gpg_key

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
        sed -i 's/#master: salt/master: 192.168.68.50/g' /etc/salt/minion
        {% if 'minion_id' in pillar %}
        sed -i 's/#id:/id: {{pillar['minion_id']}}/g' /etc/salt/minion
        {% endif %}
    - template: jinja
    - onchanges: 
      - pkg: minion_install

#启动salt-minion
minion_service:
  service.running:
    - name: salt-minion
    - enable: True
    - onchanges:
      - cmd: minion_install
