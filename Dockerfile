FROM ghcr.io/linuxserver/baseimage-kasmvnc:ubuntujammy

# Set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="[Mollomm1 Mod] Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="mollomm1"

ARG DEBIAN_FRONTEND="noninteractive"

# Prevent Ubuntu's firefox stub from being installed
COPY /root/etc/apt/preferences.d/firefox-no-snap /etc/apt/preferences.d/firefox-no-snap
COPY options.json /

# Copy specific files from /root/
COPY /root/ /

# Update system
RUN \
  echo "**** update system ****" && \
  set -e && \
  apt-get update && \
  apt-get upgrade -y

# Install neofetch for the dweebs that like to flex their chromebooks that have celerons 😂
RUN \
  echo "**** install neofetch ****" && \
  apt-get install -y neofetch

# Install packages and run install-de.sh
RUN \
  echo "**** install packages ****" && \
  add-apt-repository -y ppa:mozillateam/ppa && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y firefox jq wget curl && \
  chmod +x /install-de.sh && \
  /install-de.sh

# Download wallpaper and set it for GNOME desktop
RUN \
  echo "**** download and set wallpaper ****" && \
  mkdir -p /config/Pictures && \
  curl -o /config/Pictures/AGAR.png https://raw.githubusercontent.com/kk123121/wallpaper/refs/heads/main/AGAR.png && \
  chmod 644 /config/Pictures/AGAR.png && \
  mkdir -p /config/.config/dconf && \
  echo "[org/gnome/desktop/background]" > /config/.config/dconf/user && \
  echo "picture-uri='file:///config/Pictures/AGAR.png'" >> /config/.config/dconf/user && \
  echo "picture-options='zoom'" >> /config/.config/dconf/user && \
  echo "color-shading-type='solid'" >> /config/.config/dconf/user && \
  echo "primary-color='#000000000000'" >> /config/.config/dconf/user && \
  echo "secondary-color='#000000000000'" >> /config/.config/dconf/user && \
  chown -R 1000:1000 /config/Pictures /config/.config

# Update system
RUN \
  echo "**** update system ****" && \
  set -e && \
  apt-get update && \
  apt-get upgrade -y

# Run installapps.sh
RUN \
  chmod +x /installapps.sh && \
  /installapps.sh && \
  rm /installapps.sh

# Cleanup
RUN \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
  /config/.cache \
  /var/lib/apt/lists/* \
  /var/tmp/* \
  /tmp/*

# Ports and volumes
EXPOSE 3000
VOLUME /config
