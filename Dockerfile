FROM debian:bookworm

# Set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="[Mollomm1 Mod] Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="mollomm1"

ARG DEBIAN_FRONTEND="noninteractive"

# Install dependencies for KasmVNC and desktop environments
RUN \
  echo "**** install base dependencies ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
  wget \
  curl \
  jq \
  gnupg \
  ca-certificates \
  x11vnc \
  xvfb \
  openbox \
  xterm \
  sudo \
  neofetch && \
  echo "**** install desktop environments ****" && \
  apt-get install -y --no-install-recommends \
  task-gnome-desktop \
  i3 \
  xfce4 \
  kde-plasma-desktop \
  cinnamon && \
  apt-get autoclean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create user 'Agar' with UID 1000 and home directory
RUN \
  echo "**** create user Agar ****" && \
  useradd -u 1000 -m -s /bin/bash Agar && \
  usermod -aG sudo Agar && \
  echo "Agar ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/Agar

# Install Google Chrome
RUN \
  echo "**** install Google Chrome ****" && \
  wget -q -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
  apt-get update && \
  apt-get install -y /tmp/google-chrome.deb && \
  rm /tmp/google-chrome.deb && \
  apt-get autoclean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy specific files from /root/
COPY /root/ /root/

# Copy options.json (if needed for KasmVNC configuration)
COPY options.json /

# Download and set wallpaper for all desktop environments
RUN \
  echo "**** set wallpaper ****" && \
  mkdir -p /home/Agar/Pictures && \
  curl -o /home/Agar/Pictures/AGAR.png https://raw.githubusercontent.com/kk123121/wallpaper/refs/heads/main/AGAR.png && \
  chmod 644 /home/Agar/Pictures/AGAR.png && \
  # GNOME (using dconf) \
  mkdir -p /home/Agar/.config/dconf && \
  echo "[org/gnome/desktop/background]" > /home/Agar/.config/dconf/user && \
  echo "picture-uri='file:///home/Agar/Pictures/AGAR.png'" >> /home/Agar/.config/dconf/user && \
  echo "picture-options='zoom'" >> /home/Agar/.config/dconf/user && \
  echo "color-shading-type='solid'" >> /home/Agar/.config/dconf/user && \
  echo "primary-color='#000000000000'" >> /home/Agar/.config/dconf/user && \
  echo "secondary-color='#000000000000'" >> /home/Agar/.config/dconf/user && \
  # XFCE (using xfconf) \
  mkdir -p /home/Agar/.config/xfce4/xfconf/xfce-perchannel-xml && \
  echo '<?xml version="1.0" encoding="UTF-8"?>' > /home/Agar/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml && \
  echo '<channel name="xfce4-desktop" version="1.0">' >> /home/Agar/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml && \
  echo '  <property name="backdrop" type="empty">' >> /home/Agar/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml && \
  echo '    <property name="screen0" type="empty">' >> /home/Agar/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml && \
  echo '      <property name="monitor0" type="empty">' >> /home/Agar/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml && \
  echo '        <property name="workspace0" type="empty">' >> /home/Agar/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml && \
  echo '          <property name="last-image" type="string" value="/home/Agar/Pictures/AGAR.png"/>' >> /home/Agar/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml && \
  echo '          <property name="image-style" type="int" value="5"/>' >> /home/Agar/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml && \
  echo '        </property>' >> /home/Agar/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml && \
  echo '      </property>' >> /home/Agar/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml && \
  echo '    </property>' >> /home/Agar/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml && \
  echo '  </property>' >> /home/Agar/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml && \
  echo '</channel>' >> /home/Agar/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml && \
  # KDE (using plasma desktop configuration) \
  mkdir -p /home/Agar/.config && \
  echo "[Containments][1][Wallpaper][org.kde.image][General]" > /home/Agar/.config/plasma-org.kde.plasma.desktop-appletsrc && \
  echo "Image=file:///home/Agar/Pictures/AGAR.png" >> /home/Agar/.config/plasma-org.kde.plasma.desktop-appletsrc && \
  echo "FillMode=2" >> /home/Agar/.config/plasma-org.kde.plasma.desktop-appletsrc && \
  # Cinnamon (using dconf) \
  mkdir -p /home/Agar/.config/dconf && \
  echo "[org/cinnamon/desktop/background]" >> /home/Agar/.config/dconf/user && \
  echo "picture-uri='file:///home/Agar/Pictures/AGAR.png'" >> /home/Agar/.config/dconf/user && \
  echo "picture-options='zoom'" >> /home/Agar/.config/dconf/user && \
  # i3 (using feh for wallpaper) \
  mkdir -p /home/Agar/.config/i3 && \
  echo "exec --no-startup-id feh --bg-scale /home/Agar/Pictures/AGAR.png" > /home/Agar/.config/i3/config && \
  apt-get update && \
  apt-get install -y --no-install-recommends feh && \
  apt-get autoclean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
  chown -R Agar:Agar /home/Agar/Pictures /home/Agar/.config

# Install custom applications
COPY installapps.sh /installapps.sh
RUN \
  echo "**** run installapps.sh ****" && \
  chmod +x /installapps.sh && \
  su - Agar -c /installapps.sh && \
  rm /installapps.sh

# Install KasmVNC
RUN \
  echo "**** install KasmVNC ****" && \
  wget -qO- https://github.com/kasmtech/KasmVNC/releases/download/v1.3.1/kasmvncserver_debian_bookworm_1.3.1_amd64.deb -O /tmp/kasmvncserver.deb && \
  apt-get update && \
  apt-get install -y /tmp/kasmvncserver.deb && \
  rm /tmp/kasmvncserver.deb && \
  apt-get autoclean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Update system
RUN \
  echo "**** update system ****" && \
  apt-get update && \
  apt-get upgrade -y && \
  apt-get autoclean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set up KasmVNC configuration for user Agar
RUN \
  echo "**** configure KasmVNC for Agar ****" && \
  mkdir -p /home/Agar/.vnc && \
  chown Agar:Agar /home/Agar/.vnc

# Ports and volumes
EXPOSE 3000
VOLUME /home/Agar

# Switch to user Agar and start KasmVNC server
USER Agar
CMD ["/usr/bin/kasmvncserver", "--port", "3000", "--config", "/home/Agar/.vnc"]