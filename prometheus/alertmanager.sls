{% from "prometheus/map.jinja" import alertmanager with context %}
{%- if alertmanager.enabled %}

{%- if pillar.docker is defined and pillar.docker.host is defined %}

{{alertmanager.dir.config}}/alertmanager.yml:
  file.managed:
  - source: salt://prometheus/files/alertmanager.yml
  - template: jinja

{%- endif %}
{%- endif %}
