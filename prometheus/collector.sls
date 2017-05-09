{%- if pillar.prometheus.collector.get('enabled', True) %}

{#-
  Grains are now managed from salt.minion.grains so we will just include it
#}

include:
  - salt.minion.grains

{%- endif %}
