#!/bin/bash

# Download the wallpaper to a persistent location
echo "**** downloading wallpaper ****"
mkdir -p /config/Pictures
curl -o /config/Pictures/AGAR.png https://raw.githubusercontent.com/kk123121/wallpaper/refs/heads/main/AGAR.png
chmod 644 /config/Pictures/AGAR.png
chown 1000:1000 /config/Pictures/AGAR.png

apt update

if jq ".DE" "/options.json" | grep -q "KDE Plasma (Heavy)"; then
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y dolphin \
    gwenview \
    kde-config-gtk-style \
    kdialog \
    kfind \
    khotkeys \
    kio-extras \
    knewstuff-dialog \
    konsole \
    ksystemstats \
    kwin-addons \
    kwin-x11 \
    kwrite \
    plasma-desktop \
    plasma-workspace \
    qml-module-qt-labs-platform \
    systemsettings
    sed -i 's/applications:org.kde.discover.desktop,/applications:org.kde.konsole.desktop,/g' /usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/config/main.xml
    cp /startwm-kde.sh /defaults/startwm.sh

    # Set wallpaper for KDE Plasma
    echo "**** setting KDE Plasma wallpaper ****"
    cat << EOF > /config/.config/plasma-org.kde.plasma.desktop-appletsrc
[Containments][1][Wallpaper][org.kde.image][General]
Image=file:///config/Pictures/AGAR.png
FillMode=2
EOF
    chown 1000:1000 /config/.config/plasma-org.kde.plasma.desktop-appletsrc
fi

if jq ".DE" "/options.json" | grep -q "XFCE4 (Lightweight)"; then
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y firefox \
    mousepad \
    xfce4-terminal \
    xfce4 \
    xubuntu-default-settings \
    xubuntu-icon-theme
    rm -f /etc/xdg/autostart/xscreensaver.desktop
    cp /startwm-xfce.sh /defaults/startwm.sh

    # Set wallpaper for XFCE4
    echo "**** setting XFCE4 wallpaper ****"
    mkdir -p /config/.config/xfce4/xfconf/xfce-perchannel-xml
    cat << EOF > /config/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitor0" type="empty">
        <property name="workspace0" type="empty">
          <property name="image-path" type="string" value="/config/Pictures/AGAR.png"/>
          <property name="image-style" type="int" value="5"/> <!-- 5 = Scaled -->
        </property>
      </property>
    </property>
  </property>
</channel>
EOF
    chown -R 1000:1000 /config/.config/xfce4
fi

if jq ".DE" "/options.json" | grep -q "I3 (Very Lightweight)"; then
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends firefox \
    i3 \
    i3-wm \
    stterm \
    feh
    update-alternatives --set x-terminal-emulator /usr/bin/st
    cp /startwm-i3.sh /defaults/startwm.sh

    # Set wallpaper for i3 using feh
    echo "**** setting i3 wallpaper ****"
    mkdir -p /config/.config/i3
    echo "exec --no-startup-id feh --bg-scale /config/Pictures/AGAR.png" >> /config/.config/i3/config
    chown -R 1000:1000 /config/.config/i3
fi

if jq ".DE" "/options.json" | grep -q "GNOME 42 (Very Heavy)"; then
    # most of this is taken from udroid[](https://github.com/RandomCoderOrg/jammy-gnome/)
    DEBIAN_FRONTEND=noninteractive apt-get install -y firefox
    apt-get install -y gnome-shell \
    gnome-shell-* \
    dbus-x11 \
    gnome-terminal \
    gnome-accessibility-themes \
    gnome-calculator \
    gnome-control-center* \
    gnome-desktop3-data \
    gnome-initial-setup \
    gnome-menus \
    gnome-text-editor \
    gnome-themes-extra* \
    gnome-user-docs \
    gnome-video-effects \
    gnome-tweaks \
    gnome-software \
    language-pack-en-base \
    mesa-utils \
    xterm \
    yaru-*

    # Set wallpaper for GNOME
    echo "**** setting GNOME wallpaper ****"
    mkdir -p /config/.config/dconf
    cat << EOF > /config/.config/dconf/user
[org/gnome/desktop/background]
picture-uri='file:///config/Pictures/AGAR.png'
picture-options='zoom'
color-shading-type='solid'
primary-color='#000000000000'
secondary-color='#000000000000'
EOF
    chown -R 1000:1000 /config/.config/dconf

    # Load dconf settings
    if [ -f /jammy.dconf.conf ]; then
        # export dbus session address
        export $(dbus-launch)
        dconf load / < /jammy.dconf.conf || {
            echo -e "\t: dconf load failed.."
        }
    else
        echo -e "\t: dconf file not found.."
    fi

    # Append GNOME wallpaper settings to jammy.dconf.conf if it exists
    if [ -f /jammy.dconf.conf ]; then
        cat /config/.config/dconf/user >> /jammy.dconf.conf
    fi

    for file in $(find /usr -type f -iname "*login1*"); do 
        mv -v $file "$file.back"
    done

    echo "sudo chmod u+s /usr/lib/dbus-1.0/dbus-daemon-launch-helper" >> ~/.bashrc
    echo "sudo chmod u+s /usr/lib/dbus-1.0/dbus-daemon-launch-helper" >> /config/.bashrc

    mv -v /usr/share/applications/gnome-sound-panel.desktop /usr/share/applications/gnome-sound-panel.desktop.back

    echo "export XDG_CURRENT_DESKTOP=GNOME" >> ~/.bashrc
    echo "export XDG_CURRENT_DESKTOP=GNOME" >> /config/.bashrc

    apt-get remove -y \
        gnome-power-manager \
        gnome-bluetooth \
        gnome-software \
        gpaste \
        hijra-applet gnome-shell-extension-hijra \
        mailnag gnome-shell-mailnag \
        gnome-shell-pomodoro gnome-shell-pomodoro-data
    
    cp /startwm-gnome.sh /defaults/startwm.sh
fi

if jq ".DE" "/options.json" | grep -q "Cinnamon"; then
    DEBIAN_FRONTEND=noninteractive apt-get install -y firefox \
    cinnamon
    cp /startwm-cinnamon.sh /defaults/startwm.sh

    # Set wallpaper for Cinnamon
    echo "**** setting Cinnamon wallpaper ****"
    mkdir -p /config/.cinnamon
    cat << EOF > /config/.cinnamon/cinnamon-settings.ini
[desktop]
background=/config/Pictures/AGAR.png
EOF
    chown -R 1000:1000 /config/.cinnamon
fi

if jq ".DE" "/options.json" | grep -q "LXQT"; then
    DEBIAN_FRONTEND=noninteractive apt-get install -y firefox
    apt-get install -y lxqt \
    pcmanfm-qt
    cp /startwm-lxqt.sh /defaults/startwm.sh

    # Set wallpaper for LXQt
    echo "**** setting LXQt wallpaper ****"
    mkdir -p /config/.config/pcmanfm-qt/lxqt
    cat << EOF > /config/.config/pcmanfm-qt/lxqt/desktop.conf
[desktop]
wallpaper=/config/Pictures/AGAR.png
wallpaper_mode=stretch
EOF
    chown -R 1000:1000 /config/.config/pcmanfm-qt
fi

chmod +x /defaults/startwm.sh
rm /startwm-kde.sh /startwm-i3.sh /startwm-xfce.sh