#!/system/bin/sh

LOGLV=`getprop persist.logtool.gps.loglv`
gnss_dir=/data/gnss
ptest_mode=0
while [ $# -gt 0 ]
do
       # LBSD runs in ptest mode.
       case "$1" in
              -e)     gnss_dir=/nvm_fs_partition/gnss
                       echo "Let's ptest."
                       ptest_mode=1;;
       esac
       shift
done


# Copy GNSS default configuration if any of the configuration file is missing
#if [ ! -f $gnss_dir/LbsConfig.cfg ] 
#	then
#    	cp /system/etc/LbsConfig.cfg $gnss_dir/LbsConfig.cfg
#fi

#if [ ! -f $gnss_dir/LbsConfig_agnss.cfg ]
#	then
#	cp /system/etc/LbsConfig_agnss.cfg $gnss_dir/LbsConfig_agnss.cfg
#fi

#if [ ! -f $gnss_dir/LbsLogConfig.cfg ] 
#	then
#	cp /system/etc/LbsLogConfig.cfg $gnss_dir/LbsLogConfig.cfg
#	chmod 644 $gnss_dir/LbsLogConfig.cfg
#fi

#if [ ! -f $gnss_dir/LbsPltConfig.cfg ] 
#	then
#	cp /system/etc/LbsPltConfig.cfg $gnss_dir/LbsPltConfig.cfg
#fi
cp /system/etc/LbsConfig.cfg $gnss_dir/LbsConfig.cfg
cp /system/etc/LbsConfig_agnss.cfg $gnss_dir/LbsConfig_agnss.cfg
cp /system/etc/LbsPltConfig.cfg $gnss_dir/LbsPltConfig.cfg

# add by Gavin: for log debug level
if [ "$LOGLV" == "2" ] ; then
       cp /system/etc/LbsLogConfig_aplog.cfg $gnss_dir/LbsLogConfig.cfg
       chmod 644 $gnss_dir/LbsLogConfig.cfg
fi

if [ "$LOGLV" == "1" ] ; then
       cp /system/etc/LbsLogConfig_file.cfg $gnss_dir/LbsLogConfig.cfg
       chmod 644 $gnss_dir/LbsLogConfig.cfg
fi

if [ "$LOGLV" == "0" ] ; then
       cp /system/etc/LbsLogConfig_user.cfg $gnss_dir/LbsLogConfig.cfg
       chmod 644 $gnss_dir/LbsLogConfig.cfg
fi

# Execute the lbsd daemon
if [ $ptest_mode -eq 1 ]
then
       /system/bin/lbsd -p -e "$@"
else
       /system/bin/lbsd -p "$@"
fi
