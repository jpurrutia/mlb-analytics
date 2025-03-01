{% macro debug_counts() %}

{% set relations = [] %}
{% for node in graph.nodes.values() | selectattr("resource_type", "equalto", "model") %}
    {% do relations.append(node) %}
{% endfor %}

{% for relation in relations %}
    {% set query %}
        SELECT '{{ relation.name }}' as relation_name, COUNT(*) as row_count 
        FROM {{ relation.schema }}.{{ relation.name }}
    {% endset %}
    {% do run_query(query) %}
{% endfor %}

{% endmacro %}
