    {%- if exporters is defined %}
      {%- if new_exporters_cfg is defined %}
        {%- do salt['defaults.merge'](exporters, new_exporters_cfg['exporters']) %}
      {%- endif %}
      {%- set host = grains.get('host', "") %}
      {%- set fqdn_ip4_addresses = [] %}
      {%- for addr in grains['fqdn_ip4'] %}
        {%- if not addr.startswith('127.') %}
          {%- do fqdn_ip4_addresses.append(addr) %}
        {%- endif %}
      {%- endfor %}
      {%- set host_ip_address = fqdn_ip4_addresses[0] %}
      {%- load_yaml as svc_configs %}
        {%- for exporter, parameters in exporters.items() %}
          {%- if parameters.get('enabled', False) %}
            {%- for svc, svc_parameters in parameters.get('services', {}).items() %}
              {%- if svc_parameters.get('enabled', False) %}
                {%- if svc_parameters.bind is defined %}
                  {%- if svc_parameters.bind.get('address', '0.0.0.0') == '0.0.0.0' %}
                    {%- set address = host_ip_address %}
                  {%- else %}
                    {%- set address = svc_parameters.bind.address %}
                  {%- endif %}
                {%- endif %}
              {%- endif %}
              {%- if address is defined and svc_parameters.bind.port is defined %}
      {{ exporter }}_{{ svc }}_exporter:
        endpoint:
          - address: {{ address }}
            port: {{ svc_parameters.bind.port }}
                {%- if host is defined and host|length > 0 %}
        metric_relabel:
          - regex: {{ address }}:{{ svc_parameters.bind.port }}
            replacement: {{ host }}
            source_labels: "instance"
            target_label: "host"
        relabel_configs:
          - regex: {{ address }}:{{ svc_parameters.bind.port }}
            replacement: {{ host }}
            source_labels: "__address__"
            target_label: "host"
                {%- endif %}
              {%- endif %}
            {%- endfor %}
          {%- endif %}
        {%- endfor %}
      {%- endload %}
      {%- if svc_configs %}
  target:
    static:
{{ svc_configs|yaml(False)|indent(6, True) }}
      {%- endif %}
    {%- endif %}
