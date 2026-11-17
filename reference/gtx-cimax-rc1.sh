# HISTORICAL REFERENCE ONLY. NOT A UNIVERSAL INSTALLER. REVIEW HARDWARE BEFORE USE.
#!/bin/sh
# GTMedia GT/GTX Combo: CIMaX init & satellite TS1 routing, CoreELEC 22 RC1.
# Requires matching hardware, earlier tested SAT-only DTB, and existing AVL driver.
set -u
DIR=/storage/GTX_CIMAX_RC1
BIN="$DIR/bin"
LOG="$DIR/startup.log"
mkdir -p "$DIR" || exit 1
exec >> "$LOG" 2>&1
printf '\n===== CIMaX RC1 startup =====\n'
date
uname -a
fail() { echo "ERROR: $*"; exit 1; }

[ "$(uname -m)" = aarch64 ] || fail 'Not an aarch64 device'
[ "$(uname -r)" = '5.15.196' ] || fail 'Kernel is not verified 5.15.196'
for x in cimax_gpio_pulse_v2 cimax_fw_upload cimax_cfg_tool; do
    [ -x "$BIN/$x" ] || fail "Missing $BIN/$x"
done
[ -f "$BIN/cimax+_usbdvb.bin" ] || fail 'Missing CIMaX firmware'
[ -e /dev/dvb/adapter0/frontend0 ] || fail 'SAT-only frontend0 missing; RC1 AVL overlay did not attach'
dmesg | grep -Fq 'registering adapter 0 frontend 0 (Montage m88rs6060)' || fail 'Frontend0 is not verified Montage M88RS6060'

# Ensure we target the SD-card controller and never the actual eMMC controller.
EMMC=$(readlink -f /sys/block/mmcblk0/device 2>/dev/null || true)
case "$EMMC" in
  */ffe07000.emmc/*) echo "Verified eMMC controller: $EMMC" ;;
  *) fail "eMMC controller layout unknown: $EMMC" ;;
esac

# Require the intended TS mode, not merely a recognized board.
if [ -r /sys/class/stb/hw_setting ]; then
    grep -Eq 'ts1 parallel control: 0x800' /sys/class/stb/hw_setting || fail 'TS1 parallel 0x800 not active'
else
    fail 'No Amlogic hw_setting to validate TS1'
fi

# A fresh sysfs scan is used instead of hardcoding USB bus/device numbers.
CIMAX_SYS=''
CIMAX_BCD=''
find_cimax() {
    CIMAX_SYS=''
    CIMAX_BCD=''
    for p in /sys/bus/usb/devices/*; do
        [ -r "$p/idVendor" ] || continue
        [ "$(cat "$p/idVendor" 2>/dev/null)" = 1b0d ] || continue
        [ "$(cat "$p/idProduct" 2>/dev/null)" = 2f00 ] || continue
        CIMAX_SYS=$p
        CIMAX_BCD=$(cat "$p/bcdDevice" 2>/dev/null)
        return 0
    done
    return 1
}
wait_cimax() {
    want=$1
    n=0
    while [ "$n" -lt 25 ]; do
        find_cimax || true
        [ "$CIMAX_BCD" = "$want" ] && return 0
        sleep 1
        n=$((n+1))
    done
    return 1
}
usbnode() {
    b=$(cat "$CIMAX_SYS/busnum") || return 1
    d=$(cat "$CIMAX_SYS/devnum") || return 1
    printf '/dev/bus/usb/%03d/%03d' "$b" "$d"
}

find_cimax || true
if [ "$CIMAX_BCD" = '0000' ]; then
    echo 'CIMaX already operational; skipping GPIO reset and firmware upload'
else
    if [ "$CIMAX_BCD" != '0001' ]; then
        echo 'CIMaX not enumerated; checking SD controller ownership before GPIO reset'
        if [ -L /sys/bus/platform/drivers/meson-gx-mmc/ffe05000.sd ]; then
            host=$(readlink -f /sys/class/mmc_host/mmc1 2>/dev/null || true)
            case "$host" in
                */ffe05000.sd/mmc_host/mmc1) ;;
                *) fail 'mmc1 is not tied to ffe05000.sd as expected' ;;
            esac
            # Never unbind when an SD card is inserted.
            for c in /sys/class/mmc_host/mmc1/mmc1:*; do
                [ -e "$c" ] && fail "mmc1 contains a device: $c"
            done
            echo 'Temporarily unbinding unused SD-card controller ffe05000.sd'
            echo ffe05000.sd > /sys/bus/platform/drivers/meson-gx-mmc/unbind || fail 'SD unbind failed'
        fi
        # Require the matching pinmux line to be explicitly free after unbind.
        line=''
        for p in /sys/kernel/debug/pinctrl/*/pinmux-pins; do
            [ -r "$p" ] || continue
            found=$(grep -F 'pin 47 (GPIOC_5)' "$p" || true)
            [ -n "$found" ] && line=$found
        done
        case "$line" in *'pin 47 (GPIOC_5): UNCLAIMED'*) ;;
             *) fail "GPIOC_5 pinmux not verified free: $line" ;;
        esac
        echo 'Resetting CIMaX on GPIOC_5 only'
        "$BIN/cimax_gpio_pulse_v2" || fail 'GPIO reset failed'
        wait_cimax 0001 || fail 'CIMaX BootROM did not enumerate'
    fi
    [ "$CIMAX_BCD" = 0001 ] || fail "Unexpected CIMaX USB bcdDevice: $CIMAX_BCD"
    node=$(usbnode) || fail 'Could not resolve CIMaX USB node'
    echo "Loading original firmware to $node"
    "$BIN/cimax_fw_upload" "$node" "$BIN/cimax+_usbdvb.bin" || fail 'Firmware load failed'
    wait_cimax 0000 || fail 'CIMaX failed to enter operational mode'
fi

node=$(usbnode) || fail 'No operational CIMaX USB node'
echo "Applying proven CIMaX configuration to $node"
"$BIN/cimax_cfg_tool" "$node" apply || fail 'CIMaX config failed'

# Do not load/replace kernel modules; RC1 AVL overlay remains in charge.
[ -e /dev/dvb/adapter0/frontend0 ] || fail 'RC1 satellite frontend0 missing'
[ -w /sys/class/stb/source ] || fail 'DVB routing sysfs missing'
[ -w /sys/class/stb/demux0_source ] || fail 'demux0 routing sysfs missing'
[ -w /sys/class/stb/demux1_source ] || fail 'demux1 routing sysfs missing'

echo 'Configuring proven routing: dmx0 / ts1 / ts0'
printf '%s\n' dmx0 > /sys/class/stb/source || fail 'Cannot set DVB source'
printf '%s\n' ts1 > /sys/class/stb/demux0_source || fail 'Cannot set demux0 source'
printf '%s\n' ts0 > /sys/class/stb/demux1_source || fail 'Cannot set demux1 source'
[ "$(cat /sys/class/stb/source)" = dmx0 ] || fail 'Source readback mismatch'
[ "$(cat /sys/class/stb/demux0_source)" = ts1 ] || fail 'Demux0 readback mismatch'
[ "$(cat /sys/class/stb/demux1_source)" = ts0 ] || fail 'Demux1 readback mismatch'
echo '=== CIMAX RC1 STARTUP SUCCESS ==='
exit 0
