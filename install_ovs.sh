#!/bin/bash

echo "Install OVS"

# Install pre-requisites

sudo apt-get install gcc clang libcap-ng-dev libssl-dev autoconf automake libtool python-pyftpdlib wget curl netcat \
                     python-tftpy net-tools python-pip
sudo -H pip install six

./boot.sh
./configure --with-linux=/lib/modules/$(uname -r)/build --enable-Werror --enable-coverage
make
sudo make install
sudo ldconfig
export PATH=$PATH:/usr/local/share/openvswitch/scripts
sudo mkdir -p /usr/local/etc/openvswitch
sudo mkdir -p /usr/local/var/log/openvswitch
sudo ovsdb-tool create /usr/local/etc/openvswitch/conf.db \
    vswitchd/vswitch.ovsschema
sudo chown -R $USER:$USER /usr/local/etc/openvswitch/conf.db
sudo mkdir -p /usr/local/var/run/openvswitch
sudo ovsdb-server --remote=punix:/usr/local/var/run/openvswitch/db.sock \
    --remote=db:Open_vSwitch,Open_vSwitch,manager_options \
    --private-key=db:Open_vSwitch,SSL,private_key \
    --certificate=db:Open_vSwitch,SSL,certificate  \
    --bootstrap-ca-cert=db:Open_vSwitch,SSL,ca_cert  \
    --pidfile --detach --log-file
sudo chown -R $USER:$USER /usr/local/var/run/openvswitch/db.sock
sudo find . -iname "*.gcda" -user root | xargs sudo chown $USER:$USER
sudo  ovs-vsctl --no-wait init
sudo ovs-vswitchd --pidfile --detach --log-file
sudo ovs-vsctl add-br br0
sudo ovs-vsctl list-br
