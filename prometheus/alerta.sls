{% from "prometheus/map.jinja" import alerta with context %}
{%- if alerta.enabled %}

alerta_config_dir:
  file.directory:
    - name: {{ alerta.config_dir }}
    - makedirs: True
    - mode: 755


alerta_config_file:
  file.managed:
    - name: {{ alerta.config_dir }}/alerta.conf
    - source: salt://prometheus/files/alerta/alerta.conf
    - makedirs: True
    - mode: 755
    - template: jinja
    - require:
      - file: alerta_config_dir

{%- endif %}
