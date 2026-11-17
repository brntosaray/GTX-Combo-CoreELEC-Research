# Reference scripts — safety and reproducibility

Files under `reference/` are **historical, single-device, CoreELEC RC1 SAT-only source references** and not a verified universal installer.

The shell script can temporarily unbind the SD controller `ffe05000.sd`, invoke a helper to reset a CIMaX GPIO line, upload firmware from a local proprietary file, and write DVB routing sysfs attributes. It is state-changing and **must not be run on other hardware without verifying the board circuitry, controllers, pinmux and tuner layout**.

The source checks architecture, kernel `5.15.196`, satellite frontend0, `TS1` parallel mode, eMMC controller identity and an empty SD host. These checks limit some errors but are not general safety guarantees. The systemd drop-in waits for a frontend *device node*; it does not prove tuner lock, demux health, USB readiness or playback.

The pre-existing proprietary CIMaX firmware and helper executables are intentionally not included. There is only one reported reboot success; no cold-start or multi-board acceptance testing.

**Developers:** please consider upstream-compatible GPIO ownership via device-tree, better service readiness checks, TS routing initialization and a maintainable dual-frontend design.
