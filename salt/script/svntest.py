#!/usr/bin/env python
#coding:utf8

import sys
import subprocess

#python2需要加下面的编码转换，不然输出中文会报编码错误，python3不需要也没有reload等命令！！
#利用sys.version获取的python版本判断2还是3,因为如果版本2的话字符串开头是2肯定小于3的位子哈哈
if sys.version < '3':
    import sys
    reload(sys)
    sys.setdefaultencoding('utf8')



svn_path = sys.argv[0]
local_path = '/data/svn/test1'
svn_username ='test1'
svn_password = 'Password123'

proc = subprocess.Popen('svn co --non-interactive %s %s --username=%s --password=%s' % (svn_path, local_path, svn_username, svn_password),shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE)

#proc.communicate()
outs,errs = proc.communicate() 
if proc.returncode == 0:
    print(outs.decode())
    #获取更新后的版本，后面拿去存入数据库，作为回滚的时候版本参考的
    svn_version = outs.decode().strip()[-2:-1]
    print('更新到版本:'+svn_version)
else:
    print(errs.decode())
