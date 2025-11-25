#!/bin/sh

#chmod +x /tmp/install_and_update.sh && /tmp/install_and_update.sh

# Добавляем задание на выполнение скрипта каждый день в 4часа 10минут
cronTask="*/10 * * * * sh <(wget -q -O - https://raw.githubusercontent.com/WebMaster/Routers_3000/refs/heads/main/install_and_update.sh) 2>&1 | tee /root/run.log"
#cronTask="10 4 * * * sh <(wget -q -O - https://raw.githubusercontent.com/WebMaster/Routers_3000/refs/heads/main/install_and_update.sh) 2>&1 | tee /root/run.log"
str=$(grep -i "\*\/10 \* \* \* \* sh \<\(wget -q -O - https:\/\/raw\.githubusercontent\.com\/WebMaster\/Routers_3000\/refs\/heads\/main\/install_and_update\.sh\) 2\>\&1 \| tee \/root\/run\.log" /etc/crontabs/root)
#str=$(grep -i "10 4 \* \* \* sh \<\(wget -q -O - https://raw.githubusercontent.com/WebMaster/Routers_3000/refs/heads/main/install_and_update.sh\) 2\>&1 \| tee /root/run.log" /etc/crontabs/root)
if [ -z "$str" ] 
then
    echo "Add cron task auto run script install_and_update.sh"
    echo "$cronTask" >> /etc/crontabs/root
fi

echo "Complete"
wget --no-check-certificate -O /tmp/install_and_update.sh https://raw.githubusercontent.com/WebMaster/Routers_3000/refs/heads/main/install_and_update.sh && chmod +x /tmp/install_and_update.sh && /tmp/install_and_update.sh