del cron_jobs:
  cron.absent:
    - name: /usr/sbin/ntpdate times.aliyun.com >>/dev/null
    - identifier: haha
