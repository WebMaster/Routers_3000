#!/bin/sh

#chmod +x /tmp/install_and_update.sh && /tmp/install_and_update.sh

opkg update

#проверяем установлени ли пакет dnsmasq-full
if opkg list-installed | grep -q dnsmasq-full; then
	echo "dnsmasq-full already installed..."
else
	echo "Installed dnsmasq-full..."
	cd /tmp/ && opkg download dnsmasq-full
	opkg remove dnsmasq && opkg install dnsmasq-full --cache /tmp/

	[ -f /etc/config/dhcp-opkg ] && cp /etc/config/dhcp /etc/config/dhcp-old && mv /etc/config/dhcp-opkg /etc/config/dhcp
fi






























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

echo "Script run complete..."