{% from "prometheus/map.jinja" import server with context %}
{%- if server.enabled %}

prometheus_server_config_dir:
  file.directory:
    - name: {{ server.dir.config }}
    - makedirs: True

prometheus_server_data_dir:
  file.directory:
    - name: {{ server.dir.data }}
    - makedirs: True
    - mode: 755

prometheus_server_config_file:
  file.managed:
    - name: {{ server.dir.config }}/prometheus.yml
    - source: salt://prometheus/files/server/prometheus.yml
    - template: jinja
    - defaults:
        server: {{ server }}
    - require:
      - file: prometheus_server_config_dir

prometheus_server_alerts_file:
  file.managed:
    - name: {{ server.dir.config }}/alerts.yml
    - source: salt://prometheus/files/server/{{server.version}}/alerts.yml
    - template: jinja
    - defaults:
        server: {{ server }}
    - require:
      - file: prometheus_server_config_dir

{%- if not server.get('is_container', True) %}

prometheus_server_packages:
  pkg.installed:
  - names: {{ server.pkgs }}

prometheus_server_default_file:
  file.managed:
    - name: /etc/default/prometheus
    - source: salt://prometheus/files/server/default
    - template: jinja
    - defaults:
        server: {{ server }}

{%- if grains.get('init') == 'systemd' %}

prometheus_server_systemd_config:
  file.managed:
    - name: /etc/systemd/system/prometheus.service
    - source: salt://prometheus/files/server/service
    - makedirs: true
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - file: prometheus_server_default_file

prometheus_server_restart_systemd:
  module.wait:
  - name: service.systemctl_reload
  - watch:
    - file: prometheus_server_systemd_config
  - watch_in:
    - service: prometheus_server_service

{%- endif %}

prometheus_server_service:
  service.running:
    - name: prometheus
    - enable: True
    {%- if grains.get('noservices') %}
    - onlyif: /bin/false
    {%- endif %}
    - watch:
{%- if grains.get('init') == 'systemd' %}
      - file: prometheus_server_systemd_config
{%- endif %}
      - file: prometheus_server_config_file
      - file: prometheus_server_alerts_file
    - require:
      - file: prometheus_server_data_dir
      - pkg: prometheus_server_packages

{%- endif %}

{%- endif %}
