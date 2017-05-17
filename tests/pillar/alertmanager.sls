prometheus:
  alertmanager:
    enabled: true
    dir:
      config: /srv/volumes/prometheus/alertmanager
      data: /srv/volumes/local/prometheus/alertmanager
    bind:
      address: 0.0.0.0
      port: 9093
    external_port: 15011
    config:
      global:
        resolve_timeout: 5m
      route:
        group_by: ['alertname', 'region', 'service']
        group_wait: 60s
        group_interval: 5m
        repeat_interval: 3h
        receiver: HTTP-notification
      inhibit_rules:
        - source_match:
            severity: 'down'
          target_match:
            severity: 'critical'
          equal: ['region', 'service']
        - source_match:
            severity: 'down'
          target_match:
            severity: 'warning'
          equal: ['region', 'service']
        - source_match:
            severity: 'critical'
          target_match:
            severity: 'warning'
          equal: ['alertname', 'region', 'service']
      receivers:
        - name: 'HTTP-notification'
          webhook_configs:
            - url: http://127.0.0.1
              send_resolved: true
docker:
  host:
    enabled: true
    experimental: true
    insecure_registries:
      - 127.0.0.1
    log:
      engine: json-file
      size: 50m
