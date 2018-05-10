#!/usr/bin/python
#

import os

ip = os.popen(
    "ip addr |grep -w inet |grep -v -w lo |sed -n '1p' |awk '{print $2}' |awk -F/ '{print $1}'").read().strip()


def Format(item, result):
    list = [ip]
    list.append(item)
    list.append(result)
    return list


def IsNullPassword():
    try:
        list = []
        user = [i.strip() for i in os.popen("awk -F: '($2 == NULL){print $1}' /etc/shadow").readlines()]
        if len(user):
            list.append(Format('IsNullPassword', user))
        else:
            list.append(Format('IsNullPassword', 0))
        return list
    except Exception, e:
        print e


def IsComplexPassword():
    try:
        list = []
        args = ['PASS_MAX_DAYS', 'PASS_MIN_DAYS', 'PASS_MIN_LEN']
        for i in args:
            list.append(Format(i, os.popen("grep ^%s /etc/login.defs |awk '{print $2}'" % i).read().strip()))
        return list
    except Exception, e:
        print e


def pam_tally2():
    try:
        list = []
        args = ['deny', 'lock_time', 'unlock_time']
        for i in args:
            list.append(Format(i, os.popen(
                "grep -ro '%s=[[:digit:]]' /etc/pam.d/system-auth |awk -F= '{print $2}'" % i).read().strip()))
        return list
    except Exception, e:
        print e


def IsRunningServices():
    try:
        list = []
        services = ['sshd', 'rsyslog', 'auditd', 'iptables']
        for i in services:
            if "is running" in os.popen("service %s status" % i).read().strip():
                list.append(Format(i, 1))
            else:
                list.append(Format(i, 0))
        list.append(Format('telnet', os.popen("netstat -nltp |grep '\<0.0.0.0:23\>' |wc -l").read().strip()))
        return list
    except Exception, e:
        print e


def FilePremissions():
    try:
        list = []
        files = ['/etc/passwd', '/etc/shadow', '/etc/group', '/etc/rc3.d', '/etc/profile', '/etc/xinet.conf']
        for i in files:
            if os.path.exists(i):
                list.append(Format(i, oct(os.stat(i).st_mode)[-3:]))
        return list
    except Exception, e:
        print e


def main():
    item = []
    item.extend(IsNullPassword())
    item.extend(IsComplexPassword())
    item.extend(IsRunningServices())
    item.extend(pam_tally2())
    item.extend(FilePremissions())
    print(item)


if __name__ == '__main__':
    main()
