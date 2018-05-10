mkdir_name_path:
  file.directory:
    - name: c:\aatat\哈哈\
    #- name: C:\\aatat\\哈哈\\新建文件夹\\新建文件夹
    - makedirs: True
{% if grains['os']=='Windows' %}
    - win_owner: Administrator
    - win_perms:
        Administrator:
          perms: full_control
    - win_perms_reset: True
{% endif %}
