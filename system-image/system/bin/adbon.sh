#!/system/bin/sh

#set -x 
setprop sys.adbon.oneshot 0
state=`getprop sys.usb.state`
adbon=`getprop factory.adbon`
cdrom="/system/etc/cdrom_install.iso"
usbconfig=`getprop persist.sys.usb.config`

case "$adbon" in
	"1")
        setprop sys.usb.config mtp
	echo "enable adbon" > /dev/kmsg
        while [ "mtp" != "$state" ]
        do
        sleep 1
        state=`getprop sys.usb.state`
        done
        setprop sys.usb.config mtp,adb
        setprop sys.adbon.oneshot 1
	;;
	* )
	if [ -f $cdrom ]; then
		setprop persist.service.cdrom.enable 1
		echo "mounting usb cdrom lun0" > /dev/kmsg
		case "$usbconfig" in
		"mtp,adb")
			setprop persist.sys.usb.config mtp,adb,mass_storage
		;;
		"mtp")
			setprop persist.sys.usb.config mtp,mass_storage
		;;
		esac
	else
		setprop persist.service.cdrom.enable 0
		case "$usbconfig" in
		"mtp,adb,mass_storage")
			setprop persist.sys.usb.config mtp,adb
		;;
		"mtp,mass_storage")
			setprop persist.sys.usb.config mtp
		;;
		esac
	fi
	;;
esac
