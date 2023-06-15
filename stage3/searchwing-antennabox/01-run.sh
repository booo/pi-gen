#!/bin/bash -e

on_chroot << EOF
  cd
  git clone https://github.com/mavlink-router/mavlink-router
  cd mavlink-router
  git submodule update --init --recursive
  meson setup build .
  ninja -C build
  sudo ninja -C build install
EOF

install -v -o 1000 -g 1000 -m 644 "rootfs/etc/dhcpcd.conf" "${ROOTFS_DIR}/etc/"

install -v -o 1000 -g 1000 -m 644 "rootfs/etc/dnsmasq.conf" "${ROOTFS_DIR}/etc/"

install -v -o 1000 -g 1000 -m 644 "rootfs/etc/hostapd/hostapd.conf"  "${ROOTFS_DIR}/etc/hostapd/"

install -v -o 1000 -g 1000 -m 755 -d "${ROOTFS_DIR}/etc/mavlink-router"
install -v -o 1000 -g 1000 -m 644 "rootfs/etc/mavlink-router/main.conf"  "${ROOTFS_DIR}/etc/mavlink-router/"

install -v -o 1000 -g 1000 -m 644 "rootfs/etc/systemd/network/br0-member-eth0.network"  "${ROOTFS_DIR}/etc/systemd/network"
install -v -o 1000 -g 1000 -m 644 "rootfs/etc/systemd/network/bridge-br0.netdev"  "${ROOTFS_DIR}/etc/systemd/network"

install -v -o 1000 -g 1000 -m 644 "rootfs/lib/systemd/system/mavlink-router.service"  "${ROOTFS_DIR}/lib/systemd/system/"
install -v -o 1000 -g 1000 -m 644 "rootfs/lib/systemd/system/searchwing-mavproxy.service"  "${ROOTFS_DIR}/lib/systemd/system/"
install -v -o 1000 -g 1000 -m 644 "rootfs/lib/systemd/system/searchwing-gps2udp.service"  "${ROOTFS_DIR}/lib/systemd/system/"

install -v -o 1000 -g 1000 -m 644 "rootfs/etc/udev/rules.d/10-usb-serial.rules"  "${ROOTFS_DIR}/etc/udev/rules.d/"
install -v -o 1000 -g 1000 -m 755 "rootfs/etc/rc.local" "${ROOTFS_DIR}/etc/"

install -v -o 1000 -g 1000 -m 644 "rootfs/etc/ntpsec/ntp.conf" "${ROOTFS_DIR}/etc/ntpsec/"

install -v -o 1000 -g 1000 -m 644 "rootfs/etc/default/gpsd" "${ROOTFS_DIR}/etc/default/"

install -v -m 644 "rootfs/etc/systemd/journald.conf" "${ROOTFS_DIR}/etc/systemd/journald.conf"


on_chroot << EOF
  sudo systemctl enable mavlink-router.service
  sudo systemctl enable searchwing-mavproxy.service
  sudo systemctl enable searchwing-gps2udp.service
  sudo systemctl enable systemd-networkd

  ln -sf /usr/share/zoneinfo/UTC /etc/localtime
EOF

on_chroot << EOF
  pip install git+https://github.com/booo/mavproxy@movinghome-gpsd-searchwing
  pip install gpsdclient
EOF

install -m 644 -o 1000 -g 1000  "rootfs/home/searchwing/eberswalde.geojson" "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/"
install -m 644 -o 1000 -g 1000  "rootfs/home/searchwing/srtm_downloader.py" "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/"
on_chroot << EOF
  pip install tqdm
  python /home/searchwing/srtm_downloader.py /home/searchwing/eberswalde.geojson
EOF