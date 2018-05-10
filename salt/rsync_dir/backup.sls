rsync_dir:
  file.recurse:
    - source: salt://{{pillar['source_path']}}?saltenv=svn
    - name: {{pillar['name_path']}}
    {% if grains['os']=='CentOS' %}
    - user: {{ pillar['user'] }}
    - group: {{ pillar['user'] }}
    {% endif %}
    - include_empty: True
    {% if 'sync_file_style' in pillar and pillar['sync_file_style']=='not_check_file' %}
    - clean: False
    {% else %}
    - clean: True
    {% endif %}
    - exclude_pat: E@\.svn($|/)
    - show_changes: False

