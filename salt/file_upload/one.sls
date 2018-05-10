file_upload:
  file.managed:
    - name: /tmp/foo.conf
    - source: salt://files/foo.conf
    - user: root
    - group: root
    - mode: 644
    - backup: minion
