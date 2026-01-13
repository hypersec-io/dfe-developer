# TODO - DFE Developer Environment

## Immediate Tasks

### GNOME RDP CPU Usage - Pending Verification

**Status:** Fix applied, pending VM restart

VM 1000 was configured with `vga: virtio` (2D only) instead of `vga: virtio-gl` (VirGL 3D). Fix applied via `qm set 1000 -vga virtio-gl,memory=256`.

**Next action:** Restart VM 1000 to verify VirGL is active and CPU usage drops.

**H.264 GPU Encoding Note:** VirGL will help desktop rendering, but H.264 RDP encoding will remain CPU-based until QEMU merges VA-API H.264 patches.

### VSCode Wayland Fullscreen Bug - Monitor Upstream

**Status:** Documented, upstream bug, cannot fix locally

**Full Documentation:** [docs/VSCODE-WAYLAND.md](docs/VSCODE-WAYLAND.md)

**Future Work:**

- [ ] Monitor GNOME 49/50 for Mutter fixes
- [ ] Test upcoming Electron versions
- [ ] Investigate gnome-shell extensions that may help
- [ ] File consolidated bug on GNOME GitLab if not tracked

## Platform Support

## Testing

## Documentation

## Future Enhancements

## Code Quality

## Security

---

**Note:** Completed tasks are documented in STATE.md and CHANGELOG.md
