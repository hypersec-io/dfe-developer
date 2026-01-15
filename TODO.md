# TODO - DFE Developer Environment

## Completed This Session

- [x] Fix `ai/` directory management for public repos
  - Keep `.git/` intact for manual updates via `git -C ai pull`
  - `/load` uses Glob (no bash approval) to check if `ai/` exists
  - Updated: `.gitignore`, `.claude/commands/load.md`
  - Also fixed in `/projects/ai`: `attach-public.sh`, `README.md`

## Immediate Tasks

### GitHub Issue #1: UI mode fails with D-Bus error when GNOME running

**Status:** Fix implemented, pending test

**Root cause:** `ansible.builtin.command` with `become_user` doesn't inherit the user's D-Bus session environment. The `ui-mode` script uses `dconf` which requires `DBUS_SESSION_BUS_ADDRESS`.

**Fix:** Get `DBUS_SESSION_BUS_ADDRESS` from gnome-shell's /proc environment and pass it to the command.

**Files modified:**

- `ansible/roles/dfe_developer/tasks/gnome_winlike.yml`
- `ansible/roles/dfe_developer/tasks/gnome_maclike.yml`

## Platform Support

## Testing

## Documentation

## Future Enhancements

## Code Quality

## Security

---

**Note:** Completed tasks are documented in STATE.md and CHANGELOG.md
