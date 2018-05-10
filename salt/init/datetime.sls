# 设置系统默认时区
datetime_set:
  timezone.system:
    - name: Asia/Shanghai
    - utc: True

# 添加定时任务同步时间这个要按实际的来，正常就是类似下面这个：
#rsync_date:
#  cron.present:
#    - name: ntpdate pool.ntp.ory &> /dev/null
#    - user: root
#    - hour: 4
