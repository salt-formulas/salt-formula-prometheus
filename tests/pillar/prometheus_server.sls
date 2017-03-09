prometheus:
  server:
    enabled: true
    bind:
      port: 9090
      address: 0.0.0.0
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
    alert:
      PrometheusTargetDownKubernetesNodes:
        if: 'up{job="kubernetes-nodes"} != 1'
        labels:
          severity: down
          service: prometheus
        annotations:
          summary: 'Prometheus target down'
