#!/usr/bin/env python
#-.- coding:utf-8 -.-

import subprocess
start=subprocess.Popen('cd C:\Program Files\PremiumSoft\Navicat Premium && c: && navicat.exe',shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
out,err=start.communicate()
print(out.decode(),errs.decede(),'哈哈')
