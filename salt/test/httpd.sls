apacheinstall:
  pkg.installed:
    - names:
      - httpd
  service.running:
    - name: httpd
    - enable: True
    - reload: True
    - require:
      - pkg: apacheinstall
    - watch:
      - file: filechange

filechange:
  file.managed:
    - name: /etc/httpd/conf/httpd.conf
    - source: salt://httpd.conf
    - require:
      - pkg: apacheinstall
