{% from "prometheus/map.jinja" import exporters with context %}
{%- for exporter, parameters in exporters.iteritems() %}
  {%- if parameters.get('enabled', False) %}
    {%- if parameters.get('packages', False) %}
{{ exporter }}_exporter_packages:
  pkg.installed:
    - names: {{ parameters.packages }}
    {%- endif %}
  {%- endif %}
{%- endfor %}
