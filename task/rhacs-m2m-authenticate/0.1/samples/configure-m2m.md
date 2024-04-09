## Configure RHACS Central to trust the OIDC ID tokens

The first step is to configure RHACS to trust tokens issued by the OIDC provider
and mapping claims to specific roles within Central.

Here is a sample configuration for a GCP cluster:

```
curl -u "admin:<password>" https://<CENTRAL-ENDPOINT>/v1/auth/m2m -d @- << EOF
{
  "config": {
    "type": "GENERIC",
    "tokenExpirationDuration": "5m",
    "mappings": [
      {
        "key": "sub",
        "valueExpression": "system:serviceaccount:default:build-bot",
        "role": "Continuous integration"
      }
    ]
    "issuer": "https://storage.googleapis.com/rhacs-tekton-task-demo-oidc"
  }
}
EOF
```

In the above example, the `build-bot` service account in the `default` namespace
of the `rhacs-tekton-task-demo` cluster is granted the `Continuous Integration`
role. The tokens issued by Central for this service account are valid for 5
minutes.

Looking in deeper details at the fields of this configuration:
- `"type": "GENERIC"` : The configuration type is for a generic OIDC provider.
- `"issuer": "https://storage.googleapis.com/rhacs-tekton-task-demo-oidc"` : The
configuration will issue short lived tokens for OIDC tokens issued by
"https://storage.googleapis.com/rhacs-tekton-task-demo-oidc".
- `"tokenExpirationDuration": "5m"` : The issued tokens will be valid for a
duration of 5 minutes.
- each entry in the `"mappings"` section is a matching rule applied to the
presented OIDC token, mapping token claim key-value pairs with RHACS roles.
Here, when the ID token received by Central has
`system:serviceaccount:default:build-bot` as subject, the issued token will have
the `Continuous Integration` role.

The `mappings` section can do more advanced JWT token field to RHACS role
mapping. See the [documentation](https://docs.openshift.com/acs/4.4/operating/manage-user-access/configure-short-lived-access.html#configure-short-lived-access_configure-short-lived-access)
for more details.
