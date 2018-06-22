#这个sls主要操作是拷贝配置文件和启动服务等

nginx_conf:
  file.managed:
    - name: {{ pillar.get('nginx_path','/usr/local/nginx') }}/conf/nginx.conf
    - source: salt://nginx/files/nginx.conf
    - template: jinja
    - defaults:
        num_cpus: {{grains['num_cpus']}}
    - onlyif: test -d {{ pillar.get('nginx_path','/usr/local/nginx') }}/conf
    - backup: minion

nginx_service:
  file.managed:
    - name: /etc/init.d/nginx
    - source: salt://nginx/files/nginx
    - mode: 755
    - unless: test -e /etc/init.d/nginx
  cmd.run:
    - names:
      - chkconfig --add nginx&&chkconfig nginx on
    - unless: chkconfig --list nginx

nginx_run:
  cmd.run:
    - name: /etc/init.d/nginx start
    - require:
      - cmd: nginx_service
