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
      enabled: true
      dir:
        config: /srv/volumes/prometheus
        config_in_container: /opt/prometheus/config
      bind:
        port: 9090
        address: 0.0.0.0
      external_port: 15010
      target:
        dns:
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
          api_ip: ${_param:kubernetes_control_address}
          ssl_dir: /opt/prometheus/config
          cert_name: kubelet-client.crt
          key_name: kubelet-client.key
        etcd:
          - host: ${_param:cluster_node01_address}
            port: ${_param:cluster_node01_port}
          - host: ${_param:cluster_node02_address}
            port: ${_param:cluster_node02_port}
          - host: ${_param:cluster_node03_address}
            port: ${_param:cluster_node03_port}
      recording:
        - name: 'instance:fd_utilization'
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

Configure alertmanager
----------------------

.. code-block:: yaml

  prometheus:
    alertmanager:
      enabled: true
      dir:
        config: /srv/volumes/prometheus
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

Configure pushgateway
---------------------

.. code-block:: yaml

  prometheus:
    pushgateway:
      enabled: true
      external_port: 15012

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
