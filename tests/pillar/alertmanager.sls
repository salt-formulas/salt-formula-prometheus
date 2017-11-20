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
      inhibit_rule:
        InhibitCriticalWhenDown:
          enabled: true
          source_match:
            severity: 'down'
          target_match:
            severity: 'critical'
          equal: ['region', 'service']
        InhibitWarningWhenDown:
          enabled: true
          source_match:
            severity: 'down'
          target_match:
            severity: 'warning'
          equal: ['region', 'service']
        InhibitWarningWhenCritical:
          enabled: true
          source_match:
            severity: 'critical'
          target_match:
            severity: 'warning'
          equal: ['region', 'service']
      receiver:
        HTTP-notification:
          webhook_configs:
            webhook_example:
              url: http://127.0.0.1
              send_resolved: true
        HTTP-slack:
          slack_configs:
            slack_example:
              api_url: http://127.0.0.1/slack
              send_resolved: true
        smtp:
          email_configs:
            email_example:
              to: test@example.com
              from: test@example.com
              smarthost: example.com
              auth_username: username
              auth_password: password
              send_resolved: true
        Multi-receiver:
          webhook_configs:
            webhook:
              url: http://127.0.0.1
              send_resolved: true
          slack_configs:
            slack:
              api_url: http://127.0.0.1/slack
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
