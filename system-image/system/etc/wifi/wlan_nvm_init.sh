#!/system/bin/sh

LOG_TAG=wlan_nvm_init
#record all parameters in logcat log and $LOG_FILE
logi () {
  /system/bin/log -t $LOG_TAG -p i "$@"
}

logd () {
  /system/bin/log -t $LOG_TAG -p d "$@"
}

loge () {
  /system/bin/log -t $LOG_TAG -p e "ERROR: $@"
}


DEFAULT_NVM_FILE="/system/etc/wifi/nvmDataDefault"

NVM_FILE_PATH="/nvm_fs_partition/wlan"
#from factory
NVM_FILE="$NVM_FILE_PATH/nvmData"
#real use
NVM_FILE_REAL="$NVM_FILE_PATH/nvmData_real"
#
NVM_FILE_LINK="/system/vendor/firmware/nvmData"

#####################################
logi "Entering WLAN NVM Partition"

if [ ! -d $NVM_FILE_PATH ]
then
	loge "making directory $NVM_FILE_PATH"
	mkdir -p $NVM_FILE_PATH
fi

logi "change owner/permission for $NVM_FILE_PATH"
chown wifi:wifi $NVM_FILE_PATH
chmod 0670 $NVM_FILE_PATH

if [ -f "${NVM_FILE}" ]
then
	logi "NVM file present in production partition"
else
	loge "NVM file Not present in production partition"
	cp "${DEFAULT_NVM_FILE}" "${NVM_FILE}"
fi

logi "change owner/permission for ${NVM_FILE}"
chown wifi:wifi "${NVM_FILE}"
chmod 0670 "${NVM_FILE}"

#####################################
#merge regulatory data from system
logi "Merge regulatory data from system"

TMP_PATH="/data/wifi_nvm_tmp"
TMP_NVM_FILE="$TMP_PATH/nvmData"
TMP_NVM_VALID="0"


rm -rf $TMP_PATH
mkdir -p $TMP_PATH

#merge regulatory
busybox_wifi split -b 1048 "$NVM_FILE" "$TMP_PATH/A"
busybox_wifi split -b 434 "$TMP_PATH/Aab" "$TMP_PATH/B"
busybox_wifi split -b 1048 "$DEFAULT_NVM_FILE" "$TMP_PATH/C"
busybox_wifi split -b 434 "$TMP_PATH/Cab" "$TMP_PATH/D"
cat "$TMP_PATH/Aaa" "$TMP_PATH/Daa" "$TMP_PATH/Bab" "$TMP_PATH/Bac" "$TMP_PATH/Aac" "$TMP_PATH/Aad" "$TMP_PATH/Aae" "$TMP_PATH/Aaf" "$TMP_PATH/Aag" "$TMP_PATH/Aah" "$TMP_PATH/Aai" > "$TMP_NVM_FILE"

#check
ori_nvm_size=`ls -l $NVM_FILE | busybox_wifi awk '{print $4}'`
tmp_nvm_size=`ls -l $TMP_NVM_FILE | busybox_wifi awk '{print $4}'`
real_nvm_size=`ls -l $NVM_FILE_REAL | busybox_wifi awk '{print $4}'`

logd "ori_nmv_size=$ori_nvm_size"
logd "tmp_nmv_size=$tmp_nvm_size"
logd "real_nvm_size=$real_nvm_size"

if [ $tmp_nvm_size -gt 8500 ] && [ $tmp_nvm_size -eq $ori_nvm_size ]
then
	logi "$TMP_NVM_FILE is valid! size=$tmp_nvm_size"
	
	if [ -e $NVM_FILE_REAL ] && [ "$tmp_nmv_size" == "$real_nvm_size" ] && [ "`busybox_wifi diff $NVM_FILE_REAL $TMP_NVM_FILE | grep differ`" == "" ] 
	then
		logi "$NVM_FILE_REAL exist, same as $TMP_NVM_FILE, do nothing"
	else
		loge "Update $NVM_FILE_REAL from $TMP_NVM_FILE"
		rm -rf $NVM_FILE_REAL
		cp $TMP_NVM_FILE $NVM_FILE_REAL
	fi
else
	logi "$TMP_NVM_FILE is invalid! size=$tmp_nvm_size"
	
	if [ -e $NVM_FILE_REAL ] && [ "$ori_nvm_size" == "$real_nvm_size" ] && [ "`busybox_wifi diff $NVM_FILE_REAL $NVM_FILE | grep differ`" == "" ]
	then
		logi "$NVM_FILE_REAL exist, same as $NVM_FILE, do nothing"
	else
		loge "Update $NVM_FILE_REAL from $NVM_FILE"
		rm -rf $NVM_FILE_REAL
		cp $NVM_FILE $NVM_FILE_REAL
	fi
fi

logi "change owner/permission for ${NVM_FILE_REAL}"
chown wifi:wifi "${NVM_FILE_REAL}"
chmod 0670 "${NVM_FILE_REAL}"

