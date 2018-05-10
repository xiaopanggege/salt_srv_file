#test_cp_file:
#  file.managed:
#    - name: /tmp/foo.conf
#    - source: salt://files/foo.conf
#    - user: root
#    - group: root
#    - makedirs: True
#    - unless: test -e /tmp/foo.conf
#
#
#test_cp_file1:
#  file.managed:
#    - name: /tmp/nginx.conf
#    - source: salt://nginx/files/nginx.conf
#    - user: root
#    - group: root
#    - makedirs: True
#    - watch:
#      - file: /tmp/foo.conf

minion_service:
  service.running:
    - name: salt-minion
    - enable: True
