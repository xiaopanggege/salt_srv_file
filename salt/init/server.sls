# 禁用iptables或者firewalld,如果还有其他需要只要加入列表即可
{% set server_list = ['firewalld', 'iptables', ]%}
{% for server in server_list %}
{% if salt['service.available'](server) %}
{{ server }}:
    service.dead:
      - enable: False
{% endif %}
{% endfor %}    
    
