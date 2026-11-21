#!/system/bin/sh
# Pull the stock Focaltech FT8725 module from vendor_dlkm.
# Run as root in Android or OrangeFox:
#   adb push extract-stock-touch-module.sh /data/local/tmp/
#   adb shell su -c 'sh /data/local/tmp/extract-stock-touch-module.sh'
#   adb pull /data/local/tmp/stock_focaltech.ko .
set -e
OUT=/data/local/tmp/stock_focaltech.ko
MOD=focaltech_0flash_mmi_v3.ko

if [ -f "/vendor_dlkm/lib/modules/$MOD" ]; then
  cp "/vendor_dlkm/lib/modules/$MOD" "$OUT"
else
  mkdir -p /mnt/vdlkm
  if ! mount -t erofs -o ro /dev/block/dm-6 /mnt/vdlkm 2>/dev/null; then
    mount -t ext4 -o ro /dev/block/dm-6 /mnt/vdlkm
  fi
  cp "/mnt/vdlkm/lib/modules/$MOD" "$OUT"
  umount /mnt/vdlkm 2>/dev/null || true
fi

ls -l "$OUT"
sha256sum "$OUT"
md5sum "$OUT"
