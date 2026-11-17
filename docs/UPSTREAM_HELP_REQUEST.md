# Focused upstream help requested

1. Is the observed `GPIOC_5` / `ffe05000.sd` pin ownership conflict best solved in the GTX device tree instead of unbinding the MMC host at runtime? What evidence would establish the correct board mapping?
2. Is there a supported Linux driver/init path for CIMaX USB `1b0d:2f00` without redistributing proprietary firmware?
3. What is the maintainable integration architecture for `M88RS6060` and the Sony terrestrial frontend on this board, with CoreELEC's Linux 5.15.196 DVB environment?
4. Where should `dmx0 / ts1 / ts0` transport routing be set so startup order cannot race with DVB frontend registration?
5. Which additional diagnostics would distinguish a present frontend device node from fully functional MPEG-TS, DVB section filters and stable TVHeadend reception?

Please send source references, device-tree analysis, upstream-friendly patches and **sanitized** logs. State the exact GT versus GTX device and board revision. These are engineering questions, not claims of defects in upstream CoreELEC.
