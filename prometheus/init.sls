{%- if pillar.prometheus.server is defined or
       pillar.prometheus.alertmanager is defined %}
include:
  {%- if pillar.prometheus.server is defined %}
  - prometheus.server
  {%- endif %}
  {%- if pillar.prometheus.alertmanager is defined %}
  - prometheus.alertmanager
  {%- endif %}
{%- endif %}
