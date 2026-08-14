#!/bin/bash
dnf remove -y tmux
systemctl stop dnf-automatic-install.timer
systemctl disable dnf-automatic-install.timer
systemctl mask dnf-automatic-install.timer

systemctl stop dnf-automatic.timer
systemctl disable dnf-automatic.timer

sed -i 's/^apply_updates.*/apply_updates = no/' /etc/dnf/automatic.conf
sed -i 's/^download_updates.*/download_updates = no/' /etc/dnf/automatic.conf
