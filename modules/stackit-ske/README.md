# stackit-ske

A managed Kubernetes cluster on [STACKIT](https://www.stackit.de) (SKE) - the
sovereign EU option: German provider, data stays in `eu01` (Germany), no US
CLOUD Act exposure on the control plane.

Built on the `stackitcloud/stackit` provider (`stackit_ske_cluster`,
`stackit_ske_kubeconfig`).

```hcl
module "ske" {
  source = "git::https://github.com/efekaya-devops/terraform-modules.git//modules/stackit-ske?ref=main"

  project_id = "00000000-0000-0000-0000-000000000000"
  name       = "demo"

  node_pools = [{
    name         = "default"
    machine_type = "g2i.2"
    minimum      = 1
    maximum      = 3
  }]
}
```

| Input | Default | Notes |
|---|---|---|
| `project_id` | - | STACKIT project UUID |
| `name` | - | max 11 chars (SKE limit) |
| `region` | `eu01` | |
| `kubernetes_version_min` | latest | SKE patches within it |
| `node_pools` | 1x `g2i.2`, 1-2 nodes | append new pools at the end |
| `acl_allowed_cidrs` | `[]` (open) | restrict for anything real |
| `dns_zones` | `[]` | enables managed ExternalDNS |
| `hibernation` | null | cron start/end, saves cost |
| `create_kubeconfig` | false | short-lived admin kubeconfig, sensitive |

Auth is the provider's: set `STACKIT_SERVICE_ACCOUNT_KEY_PATH` (and
`STACKIT_PRIVATE_KEY_PATH` if you bring your own key) or use workload
identity federation. Configure the `stackit` provider in the root module.
