{% from "prometheus/map.jinja" import exporters with context %}
{%- for exporter, parameters in exporters.items() %}
  {%- if parameters.get('enabled', False) %}
    {%- if parameters.get('packages', False) %}
{{ exporter }}_exporter_packages:
  pkg.installed:
    - names: {{ parameters.packages }}
    {%- endif %}

{{ exporter }}_exporter_service:
  service.running:
    - name: {{ exporter }}-exporter
    - enable: True
    {%- if grains.get('noservices') %}
    - onlyif: /bin/false
    {%- endif %}
    {%- if parameters.template is defined %}
    - watch:
      - file: {{ exporter }}_exporter_service_config_file
    {%- endif %}

    {%- for svc, svc_parameters in parameters.get('services', {}).items()  %}
      {%- if  svc_parameters.get('enabled', False) %}
        {%- if svc_parameters.template is defined %}
          {%- set jmxbind = svc_parameters.get('jmx_bind', {}) %}
{{ exporter }}_{{ svc }}_exporter_config_file:
  file.managed:
    - name: /etc/exporters/{{ exporter }}_{{ svc }}-running.yml
    - template: jinja
    - source:
      - salt://{{ svc_parameters.template }}
    - context:
      jmxbind: {{ jmxbind }}
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: {{ exporter }}_exporter_packages
    - watch_in:
      - service: {{ exporter }}_exporter_service
        {%- endif %}

        {%- if parameters.template is defined %}
          {%- set template = parameters.template %}
          {%- set bind = svc_parameters.get('bind', {}) %}
{{ exporter }}_exporter_service_config_file:
  file.managed:
    - name: /etc/default/{{ exporter }}-exporter
    - template: jinja
    - source:
      - salt://{{ template }}
    - context:
      bind: {{ bind }}
      cfg_file: /etc/exporters/{{ exporter }}_{{ svc }}-running.yml
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: {{ exporter }}_exporter_packages
    - watch_in:
      - service: {{ exporter }}_exporter_service
        {%- endif %}
      {%- endif %}
    {%- endfor %}
  {%- endif %}
{%- endfor %}
