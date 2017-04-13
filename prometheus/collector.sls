{%- set service_grains = {'prometheus': {'server': {'alert': {}, 'recording': [], 'target': {}}}} %}
{%- for service_name, service in pillar.items() %}
  {%- if service.get('_support', {}).get('prometheus', {}).get('enabled', False) %}
    {%- set grains_fragment_file = service_name+'/meta/prometheus.yml' %}
    {%- macro load_grains_file() %}{% include grains_fragment_file ignore missing %}{% endmacro %}
    {%- set grains_yaml = load_grains_file()|load_yaml %}
    {%- if grains_yaml is mapping %}
      {%- set service_grains = salt['grains.filter_by']({'default': service_grains}, merge={'prometheus': grains_yaml}) %}
    {%- endif %}
  {%- endif %}
{%- endfor %}

prometheus_grains_dir:
  file.directory:
  - name: /etc/salt/grains.d
  - mode: 700
  - makedirs: true
  - user: root

prometheus_grain:
  file.managed:
  - name: /etc/salt/grains.d/prometheus
  - source: salt://prometheus/files/prometheus.grain
  - template: jinja
  - mode: 600
  - defaults:
    service_grains: {{ service_grains|yaml }}
  - require:
    - file: prometheus_grains_dir
