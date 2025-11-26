#!/bin/sh

#chmod +x /tmp/test.sh && /tmp/test.sh
URL="https://raw.githubusercontent.com/WebMaster/Routers_3000/refs/heads/main"


printf "\n\033[32;1m--- [Opera-proxy] start install or update..\033[0m\n"
PACKAGE="opera-proxy"
REQUIRED_VERSION="1.13.1-r1"
INSTALLED_VERSION=$(opkg list-installed | grep "^$PACKAGE" | cut -d ' ' -f 3)
if [ "$INSTALLED_VERSION" != "$REQUIRED_VERSION" ]; then
    /etc/init.d/$PACKAGE stop
    #opkg remove --force-removal-of-dependent-packages $PACKAGE
    DOWNLOAD_DIR="/tmp/d_$PACKAGE"
    mkdir -p "$DOWNLOAD_DIR"
    ipk_files="opera-proxy_1.13.1-r1_aarch64_cortex-a53.ipk"
    for file in $ipk_files
    do
        echo "Opera-proxy download $file..."
        wget -q -O "$DOWNLOAD_DIR/$file" "$URL/ipk/$PACKAGE/$file"
        opkg install $DOWNLOAD_DIR/$file
        rm -f $DOWNLOAD_DIR/$file
    done
    wget -O "/etc/config/$PACKAGE" "$URL/config_files/$PACKAGE"
else
    echo "Opera-proxy install version $INSTALLED_VERSION not need update..."
    echo "Opera-proxy config update..."
    wget -O "/etc/config/$PACKAGE" "$URL/config_files/$PACKAGE"
fi
printf "\033[32;1m--- [Opera-proxy] all completed..\033[0m\n"



printf "\033[32;1m--- [Opera-proxy] start install or update..\033[0m\n"
/etc/init.d/opera-proxy stop
DOWNLOAD_DIR="/tmp/d_opera-proxy"
mkdir -p "$DOWNLOAD_DIR"
ipk_files="opera-proxy_1.13.1-r1_aarch64_cortex-a53.ipk"
for file in $ipk_files
do
	echo "Download $file..."
	wget -q -O "$DOWNLOAD_DIR/$file" "$URL/ipk/opera-proxy/$file"
    opkg install $DOWNLOAD_DIR/$file
    rm -f $DOWNLOAD_DIR/$file
done
printf "\033[32;1m--- [opera-proxy] all completed..\033[0m\n"