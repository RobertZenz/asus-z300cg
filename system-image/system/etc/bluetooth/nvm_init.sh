#!/system/bin/sh

LOG_TAG="nvm_init.sh"

bddata="00A400C5AEBC000080BA8C01FFFE0FFEDBFF7B870140FA1A200A080808050707070A080804060AA40AB8CC0A040001F907001C00ED001E00B80B6419C8AFA861D00704000B5A86860443B37C00000000"
bddatatmp="000080BA8C01FFFE0FFEDBFF7B870140FA1A200A080808050707070A080804060AA40AB8CC0A040001F907001C00ED001E00B80B6419C8AFA861D00704000B5A86860443B37C00000000"

logi () {
    /system/bin/log -t $LOG_TAG -p i "$LOG_NAME $@"
}

GenerateRandomBDADDR() {
logi "====== GenerateRandomBDADDR() ======"
RANGE=255
number=$RANDOM
numbera=$RANDOM
numberb=$RANDOM
let "number %= $RANGE"
let "numbera %= $RANGE"
let "numberb %= $RANGE"
octeta=$(busybox printf "%02X" $number)
octetb=$(busybox printf "%02X" $numbera)
octetc=$(busybox printf "%02X" $numberb)
bddata=${bddata/00A400/$octeta$octetb$octetc}
echo $bddata > /nvm_fs_partition/bluetooth/bddata
}

logi "====== Entering NVM Partition ======"
if [ -e /nvm_fs_partition/bluetooth/bddata ]
then
    logi "====== File Present in NVM Partition ======"
    chown bluetooth.bluetooth /nvm_fs_partition/bluetooth/bddata
    chmod 0664 /nvm_fs_partition/bluetooth/bddata
else
    logi "====== File Not Present in NVM Partition ======"
    GenerateRandomBDADDR
    chown bluetooth.bluetooth /nvm_fs_partition/bluetooth/bddata
    chmod 0664 /nvm_fs_partition/bluetooth/bddata
fi

btmac=`cat /nvm_fs_partition/bluetooth/bddata`
addr6=${btmac:0:2}
addr5=${btmac:2:2}
addr4=${btmac:4:2}
addr3=${btmac:6:2}
addr2=${btmac:8:2}
addr1=${btmac:10:2}
logi "====== btmac ======"
logi "$addr1$addr2$addr3$addr4$addr5$addr6"

setprop sys.btmac $addr1$addr2$addr3$addr4$addr5$addr6

if [ -e /nvm_fs_partition/bluetooth/.btnvm ]
then
    echo "File Present in NVM Partition"
    chown bluetooth.bluetooth /nvm_fs_partition/bluetooth/.btnvm
    chmod 0664 /nvm_fs_partition/bluetooth/.btnvm
else
    echo "File Not Present in NVM Partition"
    cp /system/etc/bluetooth/.btnvm /nvm_fs_partition/bluetooth/.btnvm
    chown bluetooth.bluetooth /nvm_fs_partition/bluetooth/.btnvm
    chmod 0664 /nvm_fs_partition/bluetooth/.btnvm
fi
