#!/sbin/sh

. "$env";

cd "$tmp" && [ "$(ls)" ] || exit 0;

# Copy all needed files into system
cp -f system/bin/busybox /system/bin/busybox;
cp -f system/bin/sysinit_cm /system/bin/sysinit_cm;
cp -rf system/etc/init.d /system/etc;

# Change permissions
chmod 755 /system/bin/busybox;
chmod 755 /system/bin/sysinit_cm;
chmod -R 755 /system/etc/init.d;

exit 0;