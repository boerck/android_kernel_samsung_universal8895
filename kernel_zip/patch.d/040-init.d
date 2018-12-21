#!/sbin/sh

# Copy all needed files into system
cp -f system/bin/busybox /system/bin/busybox;
cp -f system/bin/install-recovery.sh /system/bin/install-recovery.sh;
cp -rf system/etc/init.d /system/etc;

# Change permissions
chmod 755 /system/bin/busybox;
chmod 755 /system/bin/install-recovery.sh;
chmod -R 755 /system/etc/init.d;