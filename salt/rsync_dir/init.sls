# 按sync_file_method来判断使用哪种同步文件的方式，第一种是salt自带第二种需要安装rsync
{% if pillar['sync_file_method']=='salt'%}
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
    - exclude_pat: E@(\.svn($|/))|(\.git($|/))
    - show_changes: False
{% elif pillar['sync_file_method']=='rsync' %}
{% if not salt.file.directory_exists(pillar['mkdir_path']) %}
mkdir_name_path:
  file.directory:
    - name: {{pillar['mkdir_path']}}
    - makedirs: True
    {% if grains['os']=='Windows' %}
    - win_owner: Administrators
    - win_inheritance: False
    {% endif %}
{% endif %}
rsync_dir:
  cmd.run:
    - name: |
        rsync -rvtD --exclude '.svn' --exclude '.git' rsync://{{pillar['rsync_ip']}}:{{pillar['rsync_port']}}/svn/{{pillar['source_path']}}/ {{pillar['name_path']}}/ {% if 'sync_file_style' in pillar and pillar['sync_file_style']=='check_file' %}--delete{% endif %}
    - env:
      - LC_ALL: 'zh_CN.UTF-8'
    {% if not salt.file.directory_exists(pillar['mkdir_path']) %}
    - require:
      - file: mkdir_name_path
    {% endif %}
{% if grains['os']=='CentOS' and pillar['user']!='root' %}
chown_dir:
  file.directory:
    - name: {{pillar['mkdir_path']}}
    - user: {{ pillar['user'] }}
    - group: {{ pillar['user'] }}
    - recurse:
      - user
      - group
    - require:
      - cmd: rsync_dir
{% endif %}
{% endif %}
