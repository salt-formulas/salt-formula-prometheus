{% from "prometheus/map.jinja" import relay with context %}
{%- if relay.enabled %}

prometheus_relay_packages:
  pkg.installed:
      - names: {{ relay.pkgs }}

prometheus_relay_default_file:
  file.managed:
    - name: /etc/default/prometheus-relay
    - source: salt://prometheus/files/relay/default
    - template: jinja

{%- if grains.get('init') == 'systemd' %}

prometheus_relay_systemd_config:
  file.managed:
    - name: /etc/systemd/system/prometheus-relay.service
    - source: salt://prometheus/files/relay/service
    - makedirs: true
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - file: prometheus_relay_default_file

prometheus_relay_restart_systemd:
  module.wait:
  - name: service.systemctl_reload
  - watch:
    - file: prometheus_relay_systemd_config
  - watch_in:
    - service: prometheus_relay_service

{%- endif %}

prometheus_relay_service:
  service.running:
    - name: prometheus-relay
    - enable: True
    {%- if grains.get('noservices') %}
    - onlyif: /bin/false
    {%- endif %}
    - watch:
{%- if grains.get('init') == 'systemd' %}
      - file: prometheus_relay_systemd_config
{%- endif %}
      - file: prometheus_relay_default_file
    - require:
      - pkg: prometheus_relay_packages

{%- endif %}
