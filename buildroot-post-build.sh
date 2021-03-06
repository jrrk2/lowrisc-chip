echo EXECUTING POST_BUILD SCRIPT
echo BUILD_DIR $TARGET_DIR
cd $TARGET_DIR/etc/systemd/system/getty.target.wants
ls -l
rm console-getty.service
cd $TARGET_DIR/etc/systemd/system/getty.target.wants
ln -s /usr/lib/systemd/system/timedatectl.service .
ln -s /usr/lib/systemd/system/hciattach.service .
# Do not use below because it will cause duplicate gettys if console is on ttyS0
# ln -s /usr/lib/systemd/system/serial-getty@.service serial-getty@ttyS0.service
echo FINISHED POST_BUILD SCRIPT
