copy_dir:
  file.copy:
    - source: {{pillar['source_path']}}
    - name: {{pillar['name_path']}}
    - force: True
    - makedirs: True
    - preserve: True
    - include_empty: True
    - clean: True
