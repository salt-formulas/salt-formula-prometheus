{%- if pillar.prometheus.get('server', {}).get('enabled', False) or
       pillar.prometheus.get('relay', {}).get('enabled', False) or
       pillar.prometheus.get('alerta', {}).get('enabled', False) or
       pillar.prometheus.alertmanager is defined or
       pillar.prometheus.exporters is defined %}
include:
  {%- if pillar.prometheus.get('server', {}).get('enabled', False) %}
  - prometheus.server
  {%- endif %}
  {%- if pillar.prometheus.get('relay', {}).get('enabled', False) %}
  - prometheus.relay
  {%- endif %}
  {%- if pillar.prometheus.get('alerta', {}).get('enabled', False) %}
  - prometheus.alerta
  {%- endif %}
  {%- if pillar.prometheus.alertmanager is defined %}
  - prometheus.alertmanager
  {%- endif %}
  {%- if pillar.prometheus.exporters is defined %}
  - prometheus.exporters
  {%- endif %}
{%- endif %}
