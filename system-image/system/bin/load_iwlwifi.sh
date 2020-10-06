LOG_TAG=load_iwlwifi

loge () {
    echo "$LOG_TAG: $@"
    /system/bin/log -t $LOG_TAG -p e "$@"
}


if [ $1 == "--ptest-boot" ]; then
IS_PTEST_BOOT="true"
fi

while [ ! -f /nvm_fs_partition/wlan/nvmData_real ] || [ "`getprop init.svc.init_wlan_nvm`" != "stopped" ]
do
	loge "wait for /nvm_fs_partition/wlan/nvmData_real and service init_wlan_nvm stopped"
	sleep 1
done
sleep 2

loge "/nvm_fs_partition/wlan/nvmData exist"

if [ $IS_PTEST_BOOT == "true" ]; then
	loge "mode: ptest"
	insmod system/lib/modules/compat_compat.ko
	insmod system/lib/modules/compat_cfg80211.ko
	insmod system/lib/modules/compat_mac80211.ko
	insmod system/lib/modules/compat_iwlwifi.ko nvm_file=nvmData xvt_default_mode=1
	insmod system/lib/modules/compat_iwlxvt.ko
else
	loge "mode: normal"
	insmod system/lib/modules/compat_compat.ko
	insmod system/lib/modules/compat_cfg80211.ko
	insmod system/lib/modules/compat_mac80211.ko
	insmod system/lib/modules/compat_iwlwifi.ko nvm_file=nvmData
	insmod system/lib/modules/iwlmvm.ko
	# set driver wifi driver property so hal will know that it is loaded
	setprop wlan.driver.status "ok"
fi
