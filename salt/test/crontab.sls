cron_jobs:
  cron.present:
    - name: /usr/sbin/ntpdate times.aliyun.com >>/dev/null
    - user: root
    - minute: '*/5'
