# 系统内核基本优化
sysctl_conf:
  file.managed:
    - name: /etc/sysctl.conf
    - user: root
    - group: root
    - makedirs: True
    - source: salt://init/files/sysctl.conf
    - template: jinja
    - defaults:
      {% if grains.osmajorrelease == 7 %}
        rp_filter: 2
      {% else %}
        rp_filter: 1
      {% endif %}
        shmmax: {{grains.mem_total*1024*800}}
        shmall: {{grains.mem_total*200}}
