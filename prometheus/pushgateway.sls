{% from "prometheus/map.jinja" import pushgateway with context %}
{%- if pushgateway.enabled %}

{%- if pillar.docker is defined and pillar.docker.host is defined %}

{{pushgateway.dir.data}}:
  file.directory:
    - makedirs: True
    - mode: 755

{%- endif %}
{%- endif %}
