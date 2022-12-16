# {{ resource.metadata.name }}

{{ resource.spec.description }}

## Install the {{ resource.kind.capitalize() }}

```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/{{ resource.kind.lower() }}/{{ resource.metadata.name }}/{{ resource.metadata.labels["app.kubernetes.io/version"] }}/raw
```

{% for section in ["params", "workspaces", "results"] %}{% if section in resource.spec %}
## {{ section.capitalize() }}
{% for item in resource["spec"][section] %}
* **{{ item.name }}**: {{ item.description }}{% if item.default %} (_default:_ `{{ item.default }}`){% endif %}
{% endfor %}
{% endif %}{% endfor %}
