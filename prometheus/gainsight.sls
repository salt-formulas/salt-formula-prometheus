{% from "prometheus/map.jinja" import gainsight with context %}
{%- if gainsight.enabled %}

{%- if pillar.docker is defined and pillar.docker.host is defined %}

{{gainsight.dir.config}}:
  file.directory:
    - makedirs: True

{{gainsight.dir.config}}/config.ini:
  file.managed:
  - source: salt://prometheus/files/gainsight.yml
  - template: jinja
  - require:
    - file: {{gainsight.dir.config}}

{%- endif %}
{%- endif %}
