cop_dir:
  file.recurse:
    - source: salt://files
    - name: /tmp/files
    - makedirs: True
    - backup: minion
    - include_enpty: True
