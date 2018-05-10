# include按顺序执行一个个sls
include:
  - nginx.install
  - nginx.config
