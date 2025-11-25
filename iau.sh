#!/bin/sh

#chmod +x /tmp/iau.sh && /tmp/iau.sh

opkg update
opkg install sing-box-tiny

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

echo "--- [opera-proxy] start install or update.."
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
/etc/init.d/opera-proxy start
echo "--- [opera-proxy] all completed.."


echo "--- [youtubeUnblock] start install or update.."
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
echo "--- [youtubeUnblock] all completed.."


echo "--- [Stubby] start install or update.."
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
/etc/init.d/stubby start
echo "--- [Stubby] all completed.."


echo "--- [Doh-proxy] start install or update.."
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
/etc/init.d/doh-proxy start
echo "--- [Doh-proxy] all completed.."


echo "--- [Podkop] start install or update.."
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
/etc/init.d/podkop start
echo "--- [Podkop] all completed.."





# Добавляем задание на выполнение скрипта каждый день в 4часа 10минут
#cronTask="*/10 * * * * sh <(wget --no-check-certificate -q -O - https://raw.githubusercontent.com/WebMaster/Routers_3000/refs/heads/main/install_and_update.sh) 2>&1 | tee /root/run.log"
cronTask="10 4 * * * sh <(wget --no-check-certificate -q -O - https://raw.githubusercontent.com/WebMaster/Routers_3000/refs/heads/main/install_and_update.sh) 2>&1 | tee /root/run.log"
str=$(grep -i "\*\/10 \* \* \* \* sh \<\(wget --no-check-certificate -q -O - https:\/\/raw\.githubusercontent\.com\/WebMaster\/Routers_3000\/refs\/heads\/main\/install_and_update\.sh\) 2\>\&1 \| tee \/root\/run\.log" /etc/crontabs/root)
str=$(grep -i "10 4 \* \* \* sh \<\(wget --no-check-certificate -q -O - https://raw.githubusercontent.com/WebMaster/Routers_3000/refs/heads/main/install_and_update.sh\) 2\>&1 \| tee /root/run.log" /etc/crontabs/root)
if [ -z "$str" ] 
then
    echo "Add cron task auto run script install_and_update.sh"
    echo "$cronTask" >> /etc/crontabs/root
fi

printf "\033[32;1mScript run complete...\033[0m\n"
printf "\033[31;1mAUTOREBOOT ROUTER...\033[0m\n"
reboot