{% from "prometheus/map.jinja" import server with context %}
{%- if server.enabled %}

{%- if pillar.docker is defined and pillar.docker.host is defined %}

{{server.dir.config}}/prometheus.yml:
  file.managed:
  - source: salt://prometheus/files/prometheus.yml
  - template: jinja
  - makedirs: True

{{server.dir.config}}/alerts.yml:
  file.managed:
  - source: salt://prometheus/files/alerts.yml
  - template: jinja
  - makedirs: True

{%- endif %}
{%- endif %}
