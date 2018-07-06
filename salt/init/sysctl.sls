# 系统内核基本优化
fs.file-max:
  sysctl.present:
    - value: 6553500

fs.inotify.max_user_watches:
  sysctl.present:
    - value: 65536

net.ipv4.conf.default.rp_filter:
  sysctl.present:
{% if grains.osmajorrelease == 7 %}
    - value: 2
{% else %}
    - value: 1
{% endif %}

net.ipv4.conf.default.accept_source_route:
  sysctl.present:
    - value: 0

net.ipv4.tcp_syncookies:
  sysctl.present:
    - value: 1

kernel.msgmnb:
  sysctl.present:
    - value: 65536

kernel.msgmax:
  sysctl.present:
    - value: 65536

# 下面2个参数可以设置为内存的90%这里因为语法问题90%我就把1024改成800来代替
kernel.shmmax:
  sysctl.present:
    - value: {{grains.mem_total*1024*800}}

kernel.shmall:
  sysctl.present:
    - value: {{grains.mem_total*200}}

net.ipv4.tcp_max_tw_buckets:
  sysctl.present:
    - value: 6666

# 默认就是1
net.ipv4.tcp_sack:
  sysctl.present:
    - value: 1

# 默认就是1
net.ipv4.tcp_window_scaling:
  sysctl.present:
    - value: 1


net.ipv4.tcp_rmem:
  sysctl.present:
    - value: 4096 87380 3145728

net.ipv4.tcp_wmem:
  sysctl.present:
    - value: 4096 65535 3145728

net.core.wmem_default:
  sysctl.present:
    - value: 3145728

net.core.rmem_default:
  sysctl.present:
    - value: 3145728

net.core.rmem_max:
  sysctl.present:
    - value: 6291456

net.core.wmem_max:
  sysctl.present:
    - value: 6291456

net.core.netdev_max_backlog:
  sysctl.present:
    - value: 65535

net.core.somaxconn:
  sysctl.present:
    - value: 65535

net.ipv4.tcp_max_orphans:
  sysctl.present:
    - value: 131072

net.ipv4.tcp_orphan_retries:
  sysctl.present:
    - value: 1

net.ipv4.tcp_max_syn_backlog:
  sysctl.present:
    - value: 65535

net.ipv4.tcp_retries2:
  sysctl.present:
    - value: 3

net.ipv4.tcp_synack_retries:
  sysctl.present:
    - value: 2

net.ipv4.tcp_syn_retries:
  sysctl.present:
    - value: 2

# 默认就是0,开启会提高性能但对个别情况有影响
net.ipv4.tcp_tw_recycle:
  sysctl.present:
    - value: 0

net.ipv4.tcp_timestamps:
  sysctl.present:
    - value: 0

net.ipv4.tcp_tw_reuse:
  sysctl.present:
    - value: 1

net.ipv4.tcp_fin_timeout:
  sysctl.present:
    - value: 30

net.ipv4.tcp_keepalive_time:
  sysctl.present:
    - value: 1800

net.ipv4.ip_local_port_range:
  sysctl.present:
    - value: 12000 65000
