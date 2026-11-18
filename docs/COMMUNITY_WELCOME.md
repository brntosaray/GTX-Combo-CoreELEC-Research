<!-- Discussion topic title: Welcome — GTMedia GTX Combo CoreELEC DVB-S2 progress and developer collaboration -->

# Welcome to GTX Combo CoreELEC research

Hello, I'm **EMO**. We are documenting experimentally observed **GTMedia GTX Combo** support on **CoreELEC 22 Piers RC1 / Linux 5.15.196**. This is independent community research, **not** an official supported image or universal installation kit.

## What worked on one GTX Combo
- `Montage m88rs6060` frontend detected and locked on a SAT-only device-tree configuration.
- Internal CIMaX USB `1b0d:2f00` boot/runtime behavior was observed.
- Before CIMaX initialization, the direct TS capture was **0 bytes** despite frontend lock.
- After local CIMaX initialization and transport routing `dmx0 / ts1 / ts0`, we captured **83,361,792 bytes** of sync-valid MPEG-TS, and the operator confirmed live satellite reception in TVHeadend.
- Satellite reception was confirmed after **one reboot** following a frontend-readiness service change.

**Still unverified:** reliable cold power cycles, another board's hardware layout, and **DVB-T/T2 integration**. This does not prove a universally reproducible setup.

## Where developer help is most useful
Correct physical **terrestrial frontend** identification, device-tree ownership for CIMaX GPIO/SD resources, TS routing and demux initialization, and an upstream-maintainable driver implementation. We welcome source review and sanitized hardware logs.

Please include the exact **GTX versus GT Combo** model, kernel/driver versions, device-tree identity and result evidence.

Read [research overview](../README.md), [dated satellite recovery](RECOVERY_2026-11-08.md), [reference script risks](SCRIPT_REVIEW.md), and [help wanted](UPSTREAM_HELP_REQUEST.md).

Existing technical collaboration: **[Issue #1](https://github.com/brntosaray/GTX-Combo-CoreELEC-Research/issues/1)**. Use Discussions for broader questions and proposals; use Issues for reproducible defects or patches.

**Do not run historical scripts unreviewed.** They can change a live device's GPIO/USB/DVB routing; proprietary binaries are not provided.

— **EMO**
