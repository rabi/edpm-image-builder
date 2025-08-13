Configures cloud-init to prefer NetworkManager for network configuration.

This element writes a drop-in at `/etc/cloud/cloud.cfg.d/90-network-manager-renderer.cfg` with:

```yaml
system_info:
  network:
    renderers: ['network-manager', 'sysconfig', 'eni', 'netplan', 'networkd']
```

This ensures cloud-init uses NetworkManager when available, with `sysconfig` and `netplan` as fallbacks.
