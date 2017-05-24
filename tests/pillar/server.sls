prometheus:
  server:
    enabled: true
    dir:
      config: /srv/volumes/prometheus/server
      data: /srv/volumes/local/prometheus/server
    bind:
      port: 9090
      address: 0.0.0.0
    external_port: 15010
    target:
      dns:
        enabled: true
        endpoint:
          - name: 'pushgateway'
            domain:
            - 'tasks.prometheus_pushgateway'
            type: A
            port: 9091
          - name: 'prometheus'
            domain:
            - 'tasks.prometheus_server'
            type: A
            port: 9090
      kubernetes:
        enabled: true
        api_ip: 127.0.0.1
        ssl_dir: /opt/prometheus/config
        cert_name: prometheus-server.crt
        key_name: prometheus-server.key
      etcd:
        endpoint:
          scheme: https
          ssl_dir: /opt/prometheus/config
          cert_name: prometheus-server.crt
          key_name: prometheus-server.key
          member:
            - host: ${_param:cluster_node01_address}
              port: ${_param:cluster_node01_port}
            - host: ${_param:cluster_node02_address}
              port: ${_param:cluster_node02_port}
            - host: ${_param:cluster_node03_address}
              port: ${_param:cluster_node03_port}
    recording:
      instance:fd_utilization:
        query: >-
          process_open_fds / process_max_fds
    alert:
      PrometheusTargetDown:
        if: 'up != 1'
        labels:
          severity: down
        annotations:
          summary: 'Prometheus target down'
    storage:
      local:
        engine: "persisted"
        retention: "360h"
        memory_chunks: 1048576
        max_chunks_to_persist: 524288
        num_fingerprint_mutexes: 4096
    alertmanager:
      notification_queue_capacity: 10000
    config:
      global:
        scrape_interval: "15s"
        scrape_timeout: "15s"
        evaluation_interval: "1m"
        external_labels:
          region: 'region1'
      alertmanager:
        docker_swarm_alertmanager:
          enabled: true
          dns_sd_configs:
            domain:
              - tasks.monitoring_alertmanager
            type: A
            port: 9093
docker:
  host:
    enabled: true
    experimental: true
    insecure_registries:
      - 127.0.0.1
    log:
      engine: json-file
      size: 50m
