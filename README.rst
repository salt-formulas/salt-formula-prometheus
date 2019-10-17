=======================
Salt Prometheus formula
=======================

Power your metrics and alerting with a leading open-source monitoring
solution.

Sample pillars
==============

Configure prometheus server
---------------------------

.. code-block:: yaml

  prometheus:
    server:
      version: 2.0
      enabled: true
      dir:
        config: /srv/volumes/prometheus
        data: /srv/volumes/prometheus/server
        config_in_container: /opt/prometheus/config
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
      storage:
        local:
          retention: "360h"
      alertmanager:
        notification_queue_capacity: 10000
      config:
        global:
          scrape_interval: "15s"
          scrape_timeout: "15s"
          evaluation_interval: "1m"
          external_labels:
            region: 'region1'

Configure alertmanager
----------------------

.. code-block:: yaml

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
          group_by: ['region', 'service']
          group_wait: 60s
          group_interval: 5m
          repeat_interval: 3h
          receiver: default
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
              localhost:
                url: http://127.0.0.1
                send_resolved: true
          HTTP-slack:
            slack_configs:
              slack:
                api_url: http://127.0.0.1/slack
                send_resolved: true
          smtp:
            email_configs:
              email:
                to: test@example.com
                from: test@example.com
                smarthost: example.com
                auth_username: username
                auth_password: password
                send_resolved: true
          #Two endpoints in one receiver
          Multi-receiver:
            slack_configs:
              slack:
                api_url: http://127.0.0.1/slack
                send_resolved: true
            webhook_configs:
              webhook:
                url: http://127.0.0.1
                send_resolved: true

Configure pushgateway
---------------------

.. code-block:: yaml

  prometheus:
    pushgateway:
      enabled: true
      external_port: 15012

Install prometheus as service
-------------------------------------

.. code-block:: yaml

parameters:
  prometheus:
    server:
      is_container: false


Documentation and Bugs
======================

To learn how to install and update salt-formulas, consult the documentation
available online at:

    http://salt-formulas.readthedocs.io/

In the unfortunate event that bugs are discovered, they should be reported to
the appropriate issue tracker. Use Github issue tracker for specific salt
formula:

    https://github.com/salt-formulas/salt-formula-logrotate/issues

For feature requests, bug reports or blueprints affecting entire ecosystem,
use Launchpad salt-formulas project:

    https://launchpad.net/salt-formulas

You can also join salt-formulas-users team and subscribe to mailing list:

    https://launchpad.net/~salt-formulas-users

Developers wishing to work on the salt-formulas projects should always base
their work on master branch and submit pull request against specific formula.

    https://github.com/salt-formulas/salt-formula-logrotate

Any questions or feedback is always welcome so feel free to join our IRC
channel:

    #salt-formulas @ irc.freenode.net
