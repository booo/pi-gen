#!/bin/bash -e

install -v -o 1000 -g 1000 -m 644 "rootfs/etc/dhcpcd.conf" "${ROOTFS_DIR}/etc/"

install -v -o 1000 -g 1000 -m 644 "rootfs/etc/dnsmasq.conf" "${ROOTFS_DIR}/etc/"

install -v -o 1000 -g 1000 -m 644 "rootfs/etc/hostapd/hostapd.conf"  "${ROOTFS_DIR}/etc/hostapd/"

install -v -o 1000 -g 1000 -m 644 -d "${ROOTFS_DIR}/etc/mavlink-router"
install -v -o 1000 -g 1000 -m 644 "rootfs/etc/mavlink-router/main.conf"  "${ROOTFS_DIR}/etc/mavlink-router/"

install -v -o 1000 -g 1000 -m 644 "rootfs/etc/systemd/network/br0-member-eth0.network"  "${ROOTFS_DIR}/etc/systemd/network"
install -v -o 1000 -g 1000 -m 644 "rootfs/etc/systemd/network/bridge-br0.netdev"  "${ROOTFS_DIR}/etc/systemd/network"

install -v -o 1000 -g 1000 -m 644 "rootfs/lib/systemd/system/mavlink-router.service"  "${ROOTFS_DIR}/lib/systemd/system/"
install -v -o 1000 -g 1000 -m 644 "rootfs/lib/systemd/system/searchwing-mavproxy.service"  "${ROOTFS_DIR}/lib/systemd/system/"

install -v -o 1000 -g 1000 -m 644 "rootfs/etc/udev/rules.d/10-usb-serial.rules"  "${ROOTFS_DIR}/etc/udev/rules.d/"

echo "dtoverlay=dwc2,dr_mode=host" >> "${ROOTFS_DIR}/boot/config.txt"

on_chroot << EOF
  sudo systemctl enable mavlink-router.service
  sudo systemctl enable searchwing-mavproxy.service
  sudo systemctl enable systemd-networkd
  sudo systemctl unmask hostapd
  sudo systemctl enable hostapd
  sudo systemctl enable dnsmasq
  sudo rfkill unblock wlan
EOF

on_chroot << EOF
  pip install mavproxy
EOF
