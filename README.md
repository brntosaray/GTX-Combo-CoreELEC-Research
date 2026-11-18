# GTMedia GTX Combo — CoreELEC DVB community research

**Community:** [Discussions](https://github.com/brntosaray/GTX-Combo-CoreELEC-Research/discussions) · [Welcome topic (ready to publish)](docs/COMMUNITY_WELCOME.md) · [Issues](https://github.com/brntosaray/GTX-Combo-CoreELEC-Research/issues)


**Community technical evidence • GTMedia GTX Combo (Amlogic S905X3) • CoreELEC 22 Piers RC1 / Linux 5.15.196**

> **Status (17 November 2026): DVB-S/S2 reception confirmed on one operator-owned GTX Combo in a SAT-only test configuration. DVB-T/T2 support is NOT claimed. This is not an official CoreELEC release or a universal installer.**

## Why this repository exists

Publish observed, testable results about the GTMedia **GTX Combo** for upstream DVB/CoreELEC developers. **GT Combo** and **GTX Combo** must not be assumed interchangeable. The evidence is based on operator-supplied console output and observations, not independent laboratory retesting.

## Verified results (7–8 November 2026, UTC+03)

| Checkpoint | Finding | Confidence |
| --- | --- | --- |
| DVB-S/S2 frontend | `/dev/dvb/adapter0/frontend0` registered as `Montage m88rs6060` | Operator console |
| Frontend lock | FE lock on a satellite test transponder | Operator console |
| Before CIMaX initialization | 0-byte MPEG-TS direct capture despite FE lock | Operator console |
| CIMaX recovery | USB `1b0d:2f00` appeared; firmware/config sequence completed | Operator console |
| After intervention | 83,361,792-byte MPEG-TS capture with 188-byte sync | Operator console |
| TVHeadend | Operator confirmed satellite channels working | Operator confirmation |
| Reboot | Channels worked after one reboot following `wait-frontend.conf` change, without manual service restart | Operator confirmation |
| Cold power cycle / other GTX units | Not verified | Untested |
| Terrestrial DVB-T/T2 | Not validated by SAT-only configuration | Pending |

## Technical summary

- SAT-only DTB SHA-256 `18e39eceb9bfc62646c76922c948ac5a738a956421e0c3cc6c271aecd046f812`; binary **not distributed**.
- M88RS6060 on TS1 parallel, `ts1_control=0x800`.
- CIMaX USB `1b0d:2f00`, observed boot `bcdDevice=0001`, operational `0000` after loading existing local firmware.
- Effective routing: `source=dmx0`, `demux0_source=ts1`, `demux1_source=ts0`.
- A systemd drop-in addressed a race: frontend node not ready when startup service first ran.

Read [the dated recovery notes](docs/RECOVERY_2026-11-08.md), [artifact hashes](docs/ARTIFACT_MANIFEST.md), [script review](docs/SCRIPT_REVIEW.md), and [upstream questions](docs/UPSTREAM_HELP_REQUEST.md).

## Review-only source references

`reference/gtx-cimax-rc1.sh`, `reference/gtx-cimax-rc1.service`, `reference/wait-frontend.conf` are experimental single-device source files **for engineering review, not general installation**. The script can unbind an SD controller, toggle a GPIO through a separate helper, load firmware, and change live DVB routing. **Do not execute without independent hardware validation.** Required proprietary files are intentionally excluded.

## Limits and rights

No vendor firmware, binary kernel drivers, proprietary executable tools, device images, transport-stream captures, personal credentials or internal backups are distributed. Artifact hashes are for identification only and do not grant redistribution rights. No claim of upstream integration, official support, repeatable cold boot, working terrestrial tuner or safety on a different board is made.

This repository is independent of GTMedia/CoreELEC and strictly separate from the operator's private engineering repository and the [OpenATV research](https://github.com/brntosaray/GTX-Combo-OpenATV-Research).

Contributions welcome: reproducible driver/DTB/TS analysis, sanitized evidence, upstream-compatible source patches. **No project-wide license selected yet**; do not assume rights to redistribute third-party materials.
