#!/bin/sh
 
#chmod +x /tmp/030.sh && /tmp/030.sh
printf "\033[32;1m--- [Cron] start install or update..\033[0m\n"
cronTask="10 4 * * * sh <(wget --no-check-certificate -q -O - https://raw.githubusercontent.com/WebMaster/Routers_3000/refs/heads/main/030.sh) 2>&1 | tee /root/run.log"
str=$(grep -i "10 4 \* \* \* sh \<\(wget --no-check-certificate -q -O - https://raw.githubusercontent.com/WebMaster/Routers_3000/refs/heads/main/030.sh\) 2\>&1 \| tee /root/run.log" /etc/crontabs/root)
#if [ -z "$str" ] 
#then
    echo "Add cron task auto run script"
    echo "$cronTask" > /etc/crontabs/root
#fi
printf "\033[32;1m--- [Cron] all completed..\033[0m\n"


opkg update

opkg install sing-box-tiny
/etc/init.d/sing-box-tiny stop
cat <<EOF > /etc/sing-box/config.json
{
	"log": {
	"disabled": true,
	"level": "error"
},
"inbounds": [
	{
	"type": "tproxy",
	"listen": "::",
	"listen_port": 1100,
	"sniff": false
	}
],
"outbounds": [
	{
	"type": "http",
	"server": "127.0.0.1",
	"server_port": 18080
	}
],
"route": {
	"auto_detect_interface": true
}
}
EOF

URL="https://raw.githubusercontent.com/WebMaster/Routers_3000/refs/heads/main"


if opkg list-installed | grep -q dnsmasq-full; then
	echo "dnsmasq-full already installed..."
else
	echo "Installed dnsmasq-full..."
	cd /tmp/ && opkg download dnsmasq-full
	opkg remove dnsmasq && opkg install dnsmasq-full --cache /tmp/
	[ -f /etc/config/dhcp-opkg ] && cp /etc/config/dhcp /etc/config/dhcp-old && mv /etc/config/dhcp-opkg /etc/config/dhcp
fi

wget -O "/etc/config/dhcp" "$URL/config_files/dhcp"



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
else
    echo "Opera-proxy install version $INSTALLED_VERSION not need update..."
fi
printf "\033[32;1m--- [Opera-proxy] all completed..\033[0m\n"



#printf "\n\033[32;1m--- [youtubeUnblock] start install or update..\033[0m\n"
#PACKAGE="youtubeUnblock"
#REQUIRED_VERSION="1.1.0-2-2d579d5~2d579d5-r2"
#INSTALLED_VERSION=$(opkg list-installed | grep "^$PACKAGE" | cut -d ' ' -f 3)
#if [ "$INSTALLED_VERSION" != "$REQUIRED_VERSION" ]; then
#    /etc/init.d/$PACKAGE stop
    #opkg remove --force-removal-of-dependent-packages $PACKAGE
#    opkg install kmod-nfnetlink-queue kmod-nft-queue kmod-nf-conntrack
#    DOWNLOAD_DIR="/tmp/d_$PACKAGE"
#    mkdir -p "$DOWNLOAD_DIR"
#    ipk_files="youtubeUnblock-1.1.0-2-2d579d5-aarch64_cortex-a53-openwrt-23.05.ipk
#        luci-app-youtubeUnblock-1.1.0-1-473af29.ipk"
#    for file in $ipk_files
#    do
#        echo "youtubeUnblock download $file..."
#        wget -q -O "$DOWNLOAD_DIR/$file" "$URL/ipk/$PACKAGE/$file"
#        opkg install $DOWNLOAD_DIR/$file
#        rm -f $DOWNLOAD_DIR/$file
#    done
#else
#    echo "youtubeUnblock install version $INSTALLED_VERSION not need update..."
#fi

#echo "youtubeUnblock config update..."
#wget -O "/etc/config/$PACKAGE" "$URL/config_files/youtubeUnblockYouTubeDiscord"

#cronTask="0 4 * * * service youtubeUnblock restart"
#str=$(grep -i "0 4 \* \* \* service youtubeUnblock restart" /etc/crontabs/root)
#if [ -z "$str" ] 
#then
#    echo "Add cron task auto reboot service youtubeUnblock..."
#    echo "$cronTask" >> /etc/crontabs/root
#fi
#printf "\033[32;1m--- [youtubeUnblock] all completed..\033[0m\n"



#printf "\n\033[32;1m--- [Zapret] start install or update..\033[0m\n"
#/etc/init.d/zapret stop
#opkg remove --force-removal-of-dependent-packages "zapret" "luci-app-zapret"
#NAME="zapret"
#DOWNLOAD_DIR="/tmp/d_$NAME"
#/etc/init.d/$NAME stop
#mkdir -p "$DOWNLOAD_DIR"
#ipk_files="zapret_72.20251122_aarch64_cortex-a53.ipk
#    luci-app-zapret_72.20251122-r1_all.ipk"
#for file in $ipk_files
#do
#	echo "Download $file..."
#	wget -q -O "$DOWNLOAD_DIR/$file" "$URL/ipk/$NAME/$file"
#    opkg install $DOWNLOAD_DIR/$file
#    rm -f $DOWNLOAD_DIR/$file
#done
#wget -O "/etc/config/$NAME" "$URL/config_files/$NAME"
#wget -O "/opt/zapret/init.d/openwrt/custom.d/50-script.sh" "$URL/config_files/50-script.sh"
#chmod +x "/opt/zapret/init.d/openwrt/custom.d/50-script.sh"
#wget -O "/opt/zapret/ipset/zapret-hosts-google.txt" "$URL/config_files/zapret-hosts-google.txt"
#wget -O "/opt/zapret/ipset/zapret-hosts-user-exclude.txt" "$URL/config_files/zapret-hosts-user-exclude.txt"
#wget -O "/opt/zapret/ipset/zapret-ip-exclude.txt" "$URL/config_files/zapret-ip-exclude.txt"
#cronTask="0 4 * * * service zapret restart"
#str=$(grep -i "0 4 \* \* \* service zapret restart" /etc/crontabs/root)
#if [ -z "$str" ] 
#then
    #echo "Add cron task auto reboot service zapret..."
    #echo "$cronTask" >> /etc/crontabs/root
#fi
#printf "\033[32;1m--- [Zapret] all completed..\033[0m\n"
/etc/init.d/zapret disable
/etc/init.d/zapret stop


printf "\n\033[32;1m--- [Dns-failsafe-proxy] start install or update..\033[0m\n"
PACKAGE="luci-app-dns-failsafe-proxy"
REQUIRED_VERSION="1.0.6"
INSTALLED_VERSION=$(opkg list-installed | grep "^$PACKAGE" | cut -d ' ' -f 3)
if [ "$INSTALLED_VERSION" != "$REQUIRED_VERSION" ]; then
    /etc/init.d/$PACKAGE stop
    #opkg remove --force-removal-of-dependent-packages $PACKAGE
    DOWNLOAD_DIR="/tmp/d_$PACKAGE"
    mkdir -p "$DOWNLOAD_DIR"
    ipk_files="luci-app-dns-failsafe-proxy_1.0.6_all.ipk"
    for file in $ipk_files
    do
        echo "Dns-failsafe-proxy download $file..."
        wget -q -O "$DOWNLOAD_DIR/$file" "$URL/ipk/dns-failsafe-proxy/$file"
        opkg install $DOWNLOAD_DIR/$file
        rm -f $DOWNLOAD_DIR/$file
    done
    wget -O "/etc/config/dns-failsafe-proxy" "$URL/config_files/dns-failsafe-proxy"
else
    echo "Dns-failsafe-proxy install version $INSTALLED_VERSION not need update..."
    echo "Dns-failsafe-proxy config update..."
    wget -O "/etc/config/dns-failsafe-proxy" "$URL/config_files/dns-failsafe-proxy"
fi
printf "\033[32;1m--- [Dns-failsafe-proxy] all completed..\033[0m\n"



printf "\n\033[32;1m--- [Stubby] start install or update..\033[0m\n"
PACKAGE="stubby"
REQUIRED_VERSION="0.4.3-r1"
INSTALLED_VERSION=$(opkg list-installed | grep "^$PACKAGE" | cut -d ' ' -f 3)
if [ "$INSTALLED_VERSION" != "$REQUIRED_VERSION" ]; then
    /etc/init.d/$PACKAGE stop
    #opkg remove --force-removal-of-dependent-packages $PACKAGE
    DOWNLOAD_DIR="/tmp/d_$PACKAGE"
    mkdir -p "$DOWNLOAD_DIR"
    ipk_files="luci-app-stubby_0.9.6-r1_all.ipk
        luci-i18n-stubby-ru_25.303.53302~de7e901_all.ipk"
    for file in $ipk_files
    do
        echo "Stubby download $file..."
        wget -q -O "$DOWNLOAD_DIR/$file" "$URL/ipk/$PACKAGE/$file"
        opkg install $DOWNLOAD_DIR/$file
        rm -f $DOWNLOAD_DIR/$file
    done
    wget -O "/etc/config/$PACKAGE" "$URL/config_files/$PACKAGE"
else
    echo "Stubby install version $INSTALLED_VERSION not need update..."
    echo "Stubby config update..."
    wget -O "/etc/config/$PACKAGE" "$URL/config_files/$PACKAGE"
fi
printf "\033[32;1m--- [Stubby] all completed..\033[0m\n"



printf "\n\033[32;1m--- [Doh-proxy] start install or update..\033[0m\n"
PACKAGE="doh-proxy"
REQUIRED_VERSION="2025.07.01-r2"
INSTALLED_VERSION=$(opkg list-installed | grep "^$PACKAGE" | cut -d ' ' -f 3)
if [ "$INSTALLED_VERSION" != "$REQUIRED_VERSION" ]; then
    /etc/init.d/$PACKAGE stop
    #opkg remove --force-removal-of-dependent-packages $PACKAGE
    DOWNLOAD_DIR="/tmp/d_$PACKAGE"
    mkdir -p "$DOWNLOAD_DIR"
    ipk_files="doh-proxy_2025.07.01-r2_aarch64_cortex-a53.ipk
        luci-app-doh-proxy_2025.07.01-r4_all.ipk
        luci-i18n-doh-proxy-ru_25.303.53302~de7e901_all.ipk"
    for file in $ipk_files
    do
        echo "Doh-proxy download $file..."
        wget -q -O "$DOWNLOAD_DIR/$file" "$URL/ipk/$PACKAGE/$file"
        opkg install $DOWNLOAD_DIR/$file
        rm -f $DOWNLOAD_DIR/$file
    done
    wget -O "/etc/config/$PACKAGE" "$URL/config_files/$PACKAGE"
else
    echo "Doh-proxy install version $INSTALLED_VERSION not need update..."
    echo "Doh-proxy config update..."
    wget -O "/etc/config/$PACKAGE" "$URL/config_files/$PACKAGE"
fi
printf "\033[32;1m--- [Doh-proxy] all completed..\033[0m\n"



printf "\n\033[32;1m--- [Podkop] start install or update..\033[0m\n"
PACKAGE="podkop"
REQUIRED_VERSION="v0.7.10-r1"
INSTALLED_VERSION=$(opkg list-installed | grep "^$PACKAGE" | cut -d ' ' -f 3)
if [ "$INSTALLED_VERSION" != "$REQUIRED_VERSION" ]; then
    /etc/init.d/$PACKAGE stop
    #opkg remove --force-removal-of-dependent-packages $PACKAGE
    DOWNLOAD_DIR="/tmp/d_$PACKAGE"
    mkdir -p "$DOWNLOAD_DIR"
    ipk_files="podkop-v0.7.10-r1-all.ipk
        luci-app-podkop-v0.7.10-r1-all.ipk
        luci-i18n-podkop-ru-0.7.10.ipk"
    for file in $ipk_files
    do
        echo "Podkop download $file..."
        wget -q -O "$DOWNLOAD_DIR/$file" "$URL/ipk/$PACKAGE/$file"
        opkg install $DOWNLOAD_DIR/$file
        rm -f $DOWNLOAD_DIR/$file
    done
else
    echo "Podkop install version $INSTALLED_VERSION not need update..."
fi
echo "Podkop config update..."
wget -O "/etc/config/$PACKAGE" "$URL/config_files/podkopProxyYouTubeProxyDiscord"
printf "\033[32;1m--- [Podkop] all completed..\033[0m\n"


nameRule="option name 'Block_UDP_443'"
str=$(grep -i "$nameRule" /etc/config/firewall)
if [ -z "$str" ] 
then
  echo "Add block QUIC..."

  uci add firewall rule # =cfg2492bd
  uci set firewall.@rule[-1].name='Block_UDP_80'
  uci add_list firewall.@rule[-1].proto='udp'
  uci set firewall.@rule[-1].src='lan'
  uci set firewall.@rule[-1].dest='wan'
  uci set firewall.@rule[-1].dest_port='80'
  uci set firewall.@rule[-1].target='REJECT'
  uci add firewall rule # =cfg2592bd
  uci set firewall.@rule[-1].name='Block_UDP_443'
  uci add_list firewall.@rule[-1].proto='udp'
  uci set firewall.@rule[-1].src='lan'
  uci set firewall.@rule[-1].dest='wan'
  uci set firewall.@rule[-1].dest_port='443'
  uci set firewall.@rule[-1].target='REJECT'
  uci commit firewall
fi




printf "\033[32;1mScript run complete...\033[0m\n"
printf "\033[31;1mAUTOREBOOT ROUTER...\033[0m\n"
reboot