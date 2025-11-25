#!/bin/sh

#chmod +x /tmp/iau.sh && /tmp/iau.sh

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


#проверяем установлени ли пакет dnsmasq-full
if opkg list-installed | grep -q dnsmasq-full; then
	echo "dnsmasq-full already installed..."
else
	echo "Installed dnsmasq-full..."
	cd /tmp/ && opkg download dnsmasq-full
	opkg remove dnsmasq && opkg install dnsmasq-full --cache /tmp/
	[ -f /etc/config/dhcp-opkg ] && cp /etc/config/dhcp /etc/config/dhcp-old && mv /etc/config/dhcp-opkg /etc/config/dhcp
fi

wget -O "/etc/config/dhcp" "$URL/config_files/dhcp"

printf "\033[32;1m--- [opera-proxy] start install or update..\033[0m\n"
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


printf "\033[32;1m--- [youtubeUnblock] start install or update..\033[0m\n"
/etc/init.d/youtubeUnblock stop
opkg install kmod-nfnetlink-queue kmod-nft-queue kmod-nf-conntrack
DOWNLOAD_DIR="/tmp/d_youtubeUnblock"
mkdir -p "$DOWNLOAD_DIR"
ipk_files="youtubeUnblock-1.1.0-2-2d579d5-aarch64_cortex-a53-openwrt-23.05.ipk
	luci-app-youtubeUnblock-1.1.0-1-473af29.ipk"
for file in $ipk_files
do
	echo "Download $file..."
	wget -q -O "$DOWNLOAD_DIR/$file" "$URL/ipk/youtubeUnblock/$file"
    opkg install $DOWNLOAD_DIR/$file
    rm -f $DOWNLOAD_DIR/$file
done
wget -O "/etc/config/youtubeUnblock" "$URL/config_files/youtubeUnblock"
/etc/init.d/youtubeUnblock start
cronTask="0 4 * * * service youtubeUnblock restart"
str=$(grep -i "0 4 \* \* \* service youtubeUnblock restart" /etc/crontabs/root)
if [ -z "$str" ] 
then
    echo "Add cron task auto reboot service youtubeUnblock..."
    echo "$cronTask" >> /etc/crontabs/root
fi
printf "\033[32;1m--- [youtubeUnblock] all completed..\033[0m\n"


printf "\033[32;1m--- [Dns-failsafe-proxy] start install or update..\033[0m\n"
NAME="dns-failsafe-proxy"
DOWNLOAD_DIR="/tmp/d_$NAME"
/etc/init.d/$NAME stop
mkdir -p "$DOWNLOAD_DIR"
ipk_files="luci-app-dns-failsafe-proxy_1.0.6_all.ipk"
for file in $ipk_files
do
	echo "Download $file..."
	wget -q -O "$DOWNLOAD_DIR/$file" "$URL/ipk/$NAME/$file"
    opkg install $DOWNLOAD_DIR/$file
    rm -f $DOWNLOAD_DIR/$file
done
wget -O "/etc/config/$NAME" "$URL/config_files/$NAME"
printf "\033[32;1m--- [Dns-failsafe-proxy] all completed..\033[0m\n"


printf "\033[32;1m--- [Stubby] start install or update..\033[0m\n"
/etc/init.d/stubby stop
DOWNLOAD_DIR="/tmp/d_stubby"
mkdir -p "$DOWNLOAD_DIR"
ipk_files="luci-app-stubby_0.9.6-r1_all.ipk
	luci-i18n-stubby-ru_25.303.53302~de7e901_all.ipk"
for file in $ipk_files
do
	echo "Download $file..."
	wget -q -O "$DOWNLOAD_DIR/$file" "$URL/ipk/stubby/$file"
    opkg install $DOWNLOAD_DIR/$file
    rm -f $DOWNLOAD_DIR/$file
done
wget -O "/etc/config/stubby" "$URL/config_files/stubby"
printf "\033[32;1m--- [Stubby] all completed..\033[0m\n"


printf "\033[32;1m--- [Doh-proxy] start install or update..\033[0m\n"
/etc/init.d/doh-proxy stop
DOWNLOAD_DIR="/tmp/d_doh-proxy"
mkdir -p "$DOWNLOAD_DIR"
ipk_files="doh-proxy_2025.07.01-r2_aarch64_cortex-a53.ipk
    luci-app-doh-proxy_2025.07.01-r4_all.ipk
	luci-i18n-doh-proxy-ru_25.303.53302~de7e901_all.ipk"
for file in $ipk_files
do
	echo "Download $file..."
	wget -q -O "$DOWNLOAD_DIR/$file" "$URL/ipk/doh-proxy/$file"
    opkg install $DOWNLOAD_DIR/$file
    rm -f $DOWNLOAD_DIR/$file
done
wget -O "/etc/config/doh-proxy" "$URL/config_files/doh-proxy"
printf "\033[32;1m--- [Doh-proxy] all completed..\033[0m\n"


printf "\033[32;1m--- [Podkop] start install or update..\033[0m\n"
/etc/init.d/podkop stop
DOWNLOAD_DIR="/tmp/d_podkop"
mkdir -p "$DOWNLOAD_DIR"
ipk_files="podkop-v0.7.7-r1-all.ipk
	luci-app-podkop-v0.7.7-r1-all.ipk
	luci-i18n-podkop-ru-0.7.7.ipk"
for file in $ipk_files
do
	echo "Download $file..."
	wget -q -O "$DOWNLOAD_DIR/$file" "$URL/ipk/podkop/$file"
    opkg install $DOWNLOAD_DIR/$file
    rm -f $DOWNLOAD_DIR/$file
done
wget -O "/etc/config/podkop" "$URL/config_files/podkop"
printf "\033[32;1m--- [Podkop] all completed..\033[0m\n"


# Добавляем задание на выполнение скрипта каждый день в 4часа 10минут
#cronTask="*/10 * * * * sh <(wget --no-check-certificate -q -O - https://raw.githubusercontent.com/WebMaster/Routers_3000/refs/heads/main/iau.sh) 2>&1 | tee /root/run.log"
cronTask="10 4 * * * sh <(wget --no-check-certificate -q -O - https://raw.githubusercontent.com/WebMaster/Routers_3000/refs/heads/main/iau.sh) 2>&1 | tee /root/run.log"
str=$(grep -i "\*\/10 \* \* \* \* sh \<\(wget --no-check-certificate -q -O - https:\/\/raw\.githubusercontent\.com\/WebMaster\/Routers_3000\/refs\/heads\/main\/iau\.sh\) 2\>\&1 \| tee \/root\/run\.log" /etc/crontabs/root)
str=$(grep -i "10 4 \* \* \* sh \<\(wget --no-check-certificate -q -O - https://raw.githubusercontent.com/WebMaster/Routers_3000/refs/heads/main/iau.sh\) 2\>&1 \| tee /root/run.log" /etc/crontabs/root)
if [ -z "$str" ] 
then
    echo "Add cron task auto run script iau.sh"
    echo "$cronTask" >> /etc/crontabs/root
fi

printf "\033[32;1mScript run complete...\033[0m\n"
printf "\033[31;1mAUTOREBOOT ROUTER...\033[0m\n"
reboot