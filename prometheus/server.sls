{% from "prometheus/map.jinja" import server with context %}
{%- if server.enabled %}

{%- if pillar.docker is defined and pillar.docker.host is defined %}

{{server.dir.config}}:
  file.directory:
    - makedirs: True

{{server.dir.data}}:
  file.directory:
    - makedirs: True
    - mode: 755

{{server.dir.config}}/prometheus.yml:
  file.managed:
  - source: salt://prometheus/files/prometheus.yml
  - template: jinja
  - require:
    - file: {{server.dir.config}}

{{server.dir.config}}/alerts.yml:
  file.managed:
  - source: salt://prometheus/files/alerts.yml
  - template: jinja
  - require:
    - file: {{server.dir.config}}

{%- endif %}
{%- endif %}
