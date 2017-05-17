{% from "prometheus/map.jinja" import alertmanager with context %}
{%- if alertmanager.enabled %}

{%- if pillar.docker is defined and pillar.docker.host is defined %}

{{alertmanager.dir.config}}:
  file.directory:
    - makedirs: True

# prometheus user is available inside docker container not on docker host
# in dockerfile for alertmanager we ensure that it will have 999 uid
{{alertmanager.dir.data}}:
  file.directory:
    - makedirs: True
    - mode: 755
    - user: {{alertmanager.user}}

{{alertmanager.dir.config}}/alertmanager.yml:
  file.managed:
  - source: salt://prometheus/files/alertmanager.yml
  - template: jinja
  - require:
    - file: {{alertmanager.dir.config}}

{%- endif %}
{%- endif %}
