prometheus:
  alertmanager:
    enabled: true
    bind:
      address: 0.0.0.0
      port: 9093
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
