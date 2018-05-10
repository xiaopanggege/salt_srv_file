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
    - exclude_pat: E@\.svn($|/)
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
  rsync.synchronized:
    #- source: rsync://svn@{{pillar['rsync_ip']}}:{{pillar['rsync_port']}}/svn/{{pillar['source_path']}}/
    - source: rsync://{{pillar['rsync_ip']}}:{{pillar['rsync_port']}}/svn/{{pillar['source_path']}}/
    - name: {{pillar['name_path']}}/
    # 由于windows的密码文件无法修改权限为600所以暂时不认证
    #{% if grains['os']=='CentOS' %}
    #- passwordfile: /etc/rsyncd/rsyncd.secret
    #{% elif grains['os']=='Windows' %}
    #- passwordfile: /cygdrive/c/rsync_pwd/rsync_passwd.passwd
    #- passwordfile: /cygdrive/c/Users/Administrator/Desktop/cwRsync_5.5.0_x86_Free/cwRsync_5.5.0_x86_Free/etc/rsync_passwd.passwd
    #{% endif %}
    - prepare: True
    {% if 'sync_file_style' in pillar and pillar['sync_file_style']=='not_check_file' %}
    - delete: False
    {% else %}
    - delete: True
    {% endif %}
    - exclude: .svn/
    # salt-2018.3.0版本新增参数,可以代入更多rsync参数，比如--port自定义服务端端口
    #- additional_opts: 
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
      - rsync: rsync_dir
{% endif %}
{% endif %}
