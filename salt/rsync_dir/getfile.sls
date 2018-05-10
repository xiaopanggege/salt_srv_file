# 自动发布同步svn,注意这里判断系统只判断centos如果linux有其他系统则以后做下改变
rsync_dir:
  file.recurse:
    - source: salt://weixin20171212141158?saltenv=svn
    - name: /usr/local/project_test1
    - include_empty: True
    - clean: True
