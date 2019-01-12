#!/system/bin/sh
# SPECTRUM KERNEL MANAGER
# Profile initialization script by nathanchance

# If there is not a persist value, we need to set one
if [ ! -f /data/property/persist.spectrum.profile ]; then
    # diepqunh1501: For fastest initial experience, set performance mode @
    setprop persist.spectrum.profile 1
fi
