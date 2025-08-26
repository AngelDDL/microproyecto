global
    log /dev/log    local0
    log /dev/log    local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

defaults
    log     global
    mode    http
    option  httplog
    option  dontlognull
    timeout connect 5000
    timeout client  50000
    timeout server  50000
    errorfile 503 /etc/haproxy/errors/503.html

frontend http_front
   bind *:80

   # ACL para desviar el trafico de /stats
   acl path_stats path_beg /stats
   use_backend stats_backend if path_stats

   # Backend por defecto para todo el resto del trafico
   default_backend app_backend

# Backend para la aplicacion web
backend app_backend
   balance roundrobin
   # La magia de Consul Template sucede aqui
   {{range service "webapp"}}
   server {{.Node}} {{.Address}}:{{.Port}} check
   {{end}}

# Backend para las estadisticas
backend stats_backend
   stats enable
   stats uri /stats
   stats realm "Haproxy Statistics"
   stats auth admin:password
